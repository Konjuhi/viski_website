update public.products
set image_urls = array[
  'https://ugoqoapwzuxrhofzmyqq.supabase.co/storage/v1/object/public/product-images/areon-main.jpg'
]
where name = 'Areon Quality Perfume';

update public.products
set image_urls = array[
  'https://ugoqoapwzuxrhofzmyqq.supabase.co/storage/v1/object/public/product-images/dummy-1.jpg'
]
where name = 'Car Air Freshener';

update public.products
set image_urls = array[
  'https://ugoqoapwzuxrhofzmyqq.supabase.co/storage/v1/object/public/product-images/dummy-2.jpg'
]
where name = 'Ocean Breeze Scent';

update public.products
set image_urls = array[
  'https://ugoqoapwzuxrhofzmyqq.supabase.co/storage/v1/object/public/product-images/dummy-3.jpg'
]
where name = 'Vanilla Drive';

update public.products
set image_urls = array[
  'https://ugoqoapwzuxrhofzmyqq.supabase.co/storage/v1/object/public/product-images/dummy-4.jpg'
]
where name = 'New Car Classic';
