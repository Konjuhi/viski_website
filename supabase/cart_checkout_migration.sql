create extension if not exists "pgcrypto";

do $$
begin
  if not exists (
    select 1
    from pg_type
    where typname = 'order_status'
  ) then
    create type public.order_status as enum (
      'pending',
      'processing',
      'shipped',
      'delivered',
      'cancelled'
    );
  end if;
end $$;

do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'orders'
      and column_name = 'product_id'
  ) then
    if not exists (
      select 1
      from information_schema.tables
      where table_schema = 'public'
        and table_name = 'orders_legacy'
    ) then
      alter table public.orders rename to orders_legacy;
    end if;
  end if;
end $$;

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null,
  phone text not null,
  address text not null,
  status public.order_status not null default 'pending',
  search_vector tsvector generated always as (
    to_tsvector(
      'simple',
      coalesce(customer_name, '') || ' ' || coalesce(phone, '')
    )
  ) stored,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete restrict,
  quantity integer not null check (quantity > 0),
  unit_price numeric(10, 2) not null check (unit_price >= 0),
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists orders_created_at_idx
  on public.orders (created_at desc);

create index if not exists orders_search_vector_idx
  on public.orders using gin (search_vector);

create index if not exists order_items_order_id_idx
  on public.order_items (order_id);

create index if not exists order_items_product_id_idx
  on public.order_items (product_id);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

drop policy if exists "Public can insert orders" on public.orders;
drop policy if exists "Public can read orders" on public.orders;
drop policy if exists "Public can insert order items" on public.order_items;
drop policy if exists "Public can read order items" on public.order_items;

alter table public.orders
  alter column status drop default;

do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'orders'
      and column_name = 'status'
      and udt_name <> 'order_status'
  ) then
    alter table public.orders
      alter column status type public.order_status
      using (
        case status::text
          when 'pending_confirmation' then 'pending'::public.order_status
          when 'confirmed' then 'processing'::public.order_status
          when 'cancelled' then 'cancelled'::public.order_status
          when 'delivered' then 'delivered'::public.order_status
          when 'pending' then 'pending'::public.order_status
          when 'processing' then 'processing'::public.order_status
          when 'shipped' then 'shipped'::public.order_status
          else 'pending'::public.order_status
        end
      );
  end if;
end $$;

alter table public.orders
  alter column status set default 'pending';

create or replace function public.create_order_with_items(
  customer_name_input text,
  phone_input text,
  address_input text,
  items_input jsonb
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  new_order_id uuid;
  item jsonb;
  item_product_id uuid;
  item_quantity integer;
  item_unit_price numeric(10, 2);
begin
  if char_length(trim(customer_name_input)) < 2 then
    raise exception 'Customer name is required';
  end if;

  if char_length(trim(phone_input)) < 8 then
    raise exception 'Phone number is required';
  end if;

  if char_length(trim(address_input)) < 8 then
    raise exception 'Address is required';
  end if;

  if jsonb_typeof(items_input) <> 'array' or jsonb_array_length(items_input) = 0 then
    raise exception 'At least one cart item is required';
  end if;

  insert into public.orders (
    customer_name,
    phone,
    address,
    status
  ) values (
    trim(customer_name_input),
    trim(phone_input),
    trim(address_input),
    'pending'
  )
  returning id into new_order_id;

  for item in
    select value
    from jsonb_array_elements(items_input)
  loop
    item_product_id := (item ->> 'product_id')::uuid;
    item_quantity := (item ->> 'quantity')::integer;

    if item_quantity is null or item_quantity <= 0 then
      raise exception 'Invalid quantity supplied';
    end if;

    select price
      into item_unit_price
    from public.products
    where id = item_product_id
      and active = true;

    if item_unit_price is null then
      raise exception 'Product % is not available', item_product_id;
    end if;

    insert into public.order_items (
      order_id,
      product_id,
      quantity,
      unit_price
    ) values (
      new_order_id,
      item_product_id,
      item_quantity,
      item_unit_price
    );
  end loop;

  return new_order_id;
end;
$$;

grant execute on function public.create_order_with_items(text, text, text, jsonb)
  to anon, authenticated;

create or replace view public.order_details_view as
select
  oi.id,
  oi.order_id,
  o.customer_name,
  o.phone,
  o.address,
  o.status::text as order_status,
  o.created_at as ordered_at,
  p.name as product_name,
  p.image_urls[1] as primary_image_url,
  oi.quantity,
  oi.unit_price,
  (oi.quantity * oi.unit_price) as line_total
from public.order_items as oi
join public.orders as o
  on o.id = oi.order_id
join public.products as p
  on p.id = oi.product_id;

create or replace view public.order_summaries_view as
select
  o.id as order_id,
  o.customer_name,
  o.phone,
  o.address,
  o.status::text as order_status,
  o.created_at,
  sum(oi.quantity) as total_items,
  sum(oi.quantity * oi.unit_price) as total_amount
from public.orders as o
join public.order_items as oi
  on oi.order_id = o.id
group by
  o.id,
  o.customer_name,
  o.phone,
  o.address,
  o.status,
  o.created_at;

do $$
begin
  if exists (
    select 1
    from information_schema.tables
    where table_schema = 'public'
      and table_name = 'orders_legacy'
  ) then
    insert into public.orders (
      id,
      customer_name,
      phone,
      address,
      status,
      created_at
    )
    select
      id,
      customer_name,
      phone,
      address,
      case status::text
        when 'pending_confirmation' then 'pending'::public.order_status
        when 'confirmed' then 'processing'::public.order_status
        when 'cancelled' then 'cancelled'::public.order_status
        when 'delivered' then 'delivered'::public.order_status
        when 'pending' then 'pending'::public.order_status
        when 'processing' then 'processing'::public.order_status
        when 'shipped' then 'shipped'::public.order_status
        else 'pending'::public.order_status
      end,
      created_at
    from public.orders_legacy
    on conflict (id) do nothing;

    insert into public.order_items (
      order_id,
      product_id,
      quantity,
      unit_price,
      created_at
    )
    select
      legacy.id,
      legacy.product_id,
      legacy.quantity,
      coalesce(products.price, 0),
      legacy.created_at
    from public.orders_legacy as legacy
    left join public.products as products
      on products.id = legacy.product_id
    where legacy.product_id is not null
    on conflict do nothing;
  end if;
end $$;
