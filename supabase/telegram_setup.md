# Telegram Order Notifications

## 1. Create a Telegram bot

1. Open Telegram and search for `@BotFather`.
2. Send `/newbot`.
3. Follow the prompts.
4. Save the bot token that BotFather returns.

## 2. Get your chat ID

1. Open a chat with your new bot.
2. Send it any message, for example: `hi`
3. Open this URL in your browser, replacing `YOUR_BOT_TOKEN`:

```text
https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates
```

4. Find your chat ID in the JSON response under `message.chat.id`.

## 3. Add Supabase function secrets

In Supabase Dashboard:

1. Open `Edge Functions`
2. Open `Secrets`
3. Add these secrets:

- `TELEGRAM_BOT_TOKEN`
- `TELEGRAM_CHAT_ID`
- `TELEGRAM_WEBHOOK_SECRET`
- `SUPABASE_SERVICE_ROLE_KEY`

`SUPABASE_URL` is usually available automatically in Supabase Edge Functions.

## 4. Deploy the Edge Function

Create an Edge Function named `telegram-order-notify` and use the code from:

[functions/telegram-order-notify/index.ts](/Users/arditkonjuhi/StudioProjects/swift_shop/supabase/functions/telegram-order-notify/index.ts)

## 5. Connect the database trigger

Open:

[telegram_notification_setup.sql](/Users/arditkonjuhi/StudioProjects/swift_shop/supabase/telegram_notification_setup.sql)

Replace:

- `YOUR_PROJECT_REF`
- `YOUR_SUPABASE_ANON_KEY`
- `YOUR_FUNCTION_WEBHOOK_SECRET`

Then run that SQL in Supabase `SQL Editor`.

## 6. Test

1. Place a new order from the app.
2. Check Telegram.
3. You should receive a message with:

- customer name
- phone
- address
- ordered items
- total amount
- order ID

## Disable Later

If you want to stop notifications later, run:

[telegram_notification_cleanup.sql](/Users/arditkonjuhi/StudioProjects/swift_shop/supabase/telegram_notification_cleanup.sql)
