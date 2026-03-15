  drop trigger if exists notify_telegram_on_order_created on public.orders;

  create trigger notify_telegram_on_order_created
  after insert on public.orders
  for each row
  execute function supabase_functions.http_request(
    'https://ugoqoapwzuxrhofzmyqq.supabase.co/functions/v1/hyper-futelegram-order-notifynction',
    'POST',
    '{"Content-Type":"application/json","Authorization":"Bearer
  eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVnb3FvYXB3enV4cmhvZnpteXFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1NzExMjIsImV4cCI6MjA4OTE0NzEyMn0.DighTEKml0Tr5pISF5e1EL-du3bqJSseDaClGuMroIE","x-webhook-
  secret":"swiftshop_telegram_hook_2026_03_15"}',
    '{}',
    '1000'
  );
