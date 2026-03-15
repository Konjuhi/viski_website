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

alter table public.products
  alter column active set default true;

alter table public.orders
  add column if not exists status_new public.order_status;

update public.orders
set status_new = case
  when status::text = 'pending_confirmation' then 'pending'::public.order_status
  when status::text = 'confirmed' then 'processing'::public.order_status
  when status::text = 'cancelled' then 'cancelled'::public.order_status
  when status::text = 'delivered' then 'delivered'::public.order_status
  when status::text = 'pending' then 'pending'::public.order_status
  when status::text = 'processing' then 'processing'::public.order_status
  when status::text = 'shipped' then 'shipped'::public.order_status
  else 'pending'::public.order_status
end
where status_new is null;

alter table public.orders
  drop column if exists status;

alter table public.orders
  rename column status_new to status;

alter table public.orders
  alter column status set default 'pending';

alter table public.orders
  alter column status set not null;

alter table public.orders
  add column if not exists search_vector tsvector
  generated always as (
    to_tsvector(
      'simple',
      coalesce(customer_name, '') || ' ' || coalesce(phone, '')
    )
  ) stored;

create index if not exists orders_search_vector_idx
  on public.orders using gin (search_vector);

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
as $fn$
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
$fn$;

grant execute on function public.create_order_with_items(text, text, text, jsonb)
  to anon, authenticated;
