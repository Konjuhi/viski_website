create table if not exists public.product_reviews (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  customer_name text not null,
  rating integer not null check (rating between 1 and 5),
  review_text text not null,
  approved boolean not null default true,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists product_reviews_product_id_created_at_idx
  on public.product_reviews (product_id, created_at desc);

alter table public.product_reviews enable row level security;

drop policy if exists "Public can read approved product reviews" on public.product_reviews;
create policy "Public can read approved product reviews"
on public.product_reviews
for select
to anon, authenticated
using (approved = true);

drop policy if exists "Public can insert product reviews" on public.product_reviews;
create policy "Public can insert product reviews"
on public.product_reviews
for insert
to anon, authenticated
with check (
  rating between 1 and 5
  and char_length(trim(customer_name)) >= 2
  and char_length(trim(review_text)) >= 6
);
