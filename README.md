# SwiftShop

 SwiftShop is a responsive Flutter Web + Mobile storefront backed by Supabase. It fetches products from the `products` table, keeps a per-device bag locally in the app, and writes confirmed checkouts into `orders` and `order_items` in Supabase for phone confirmation.

## Stack

- Flutter
- Supabase
- Riverpod
- Clean Architecture inspired folder split

## Run

1. For a fresh project, apply [supabase/schema.sql](supabase/schema.sql) in the Supabase SQL Editor.
2. If you already created the old single-product `orders` table, run [supabase/cart_checkout_migration.sql](supabase/cart_checkout_migration.sql) instead.
3. If you want a more admin-friendly Supabase experience, run [supabase/admin_panel_improvements.sql](supabase/admin_panel_improvements.sql) after the checkout schema is in place.
4. If your existing project already has products and orders set up, run [supabase/reviews_setup.sql](supabase/reviews_setup.sql) to enable customer reviews.
5. Add products in the Supabase dashboard, including public image URLs.
6. Run the app with your project credentials:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

## Structure

```text
lib/
  core/
  services/
  repositories/
  features/
    cart/
    products/
    orders/
  presentation/
  widgets/
```

## Notes

- Product ratings and review counts now come from the `product_reviews` table in Supabase.
- The bag is stored locally with `shared_preferences`, so each browser/device sees only its own bag until checkout.
- `order_details_view` and `order_summaries_view` are included to make the Supabase Table Editor easier for the owner to use.
- Admin management happens directly inside the Supabase dashboard.
- The repository boundaries are set up so categories, Stripe payments, accounts, and delivery tracking can be added without rewriting the UI layer.
