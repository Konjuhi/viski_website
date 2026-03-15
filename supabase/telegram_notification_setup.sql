drop trigger if exists notify_telegram_on_order_created on public.orders;

create trigger notify_telegram_on_order_created
after insert on public.orders
for each row
execute function supabase_functions.http_request(
  'https://YOUR_PROJECT_REF.supabase.co/functions/v1/telegram-order-notify',
  'POST',
  '{"Content-Type":"application/json","Authorization":"Bearer YOUR_SUPABASE_ANON_KEY","x-webhook-secret":"YOUR_FUNCTION_WEBHOOK_SECRET"}',
  '{}',
  '1000'
);
