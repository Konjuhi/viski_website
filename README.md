# SwiftShop

A responsive web storefront for ordering products online, built with **Jaspr** and **Supabase**. Customers can browse products, manage their bag, and place orders — the owner receives the details and follows up by phone to confirm.

🌐 **Live site:** [https://konjuhi.github.io/viski_website/](https://konjuhi.github.io/viski_website/)

---

## Stack

| Layer | Technology |
|---|---|
| UI framework | [Jaspr](https://docs.page/schultek/jaspr) — Dart web framework rendering real HTML |
| Backend | [Supabase](https://supabase.com) — database, storage, real-time |
| State management | Jaspr `StatefulComponent` + `setState` (no extra packages) |
| Cart persistence | Browser `localStorage` via `dart:html` |
| Deployment | GitHub Pages via GitHub Actions |

---

## Features

- Browse products fetched live from Supabase
- Add to bag, adjust quantities, remove items
- Per-device bag stored in `localStorage` — no login required
- Place an order with name, phone, and delivery address
- Write and read customer reviews with star ratings
- Owner manages everything from the Supabase dashboard

---

## Local development

1. Apply the database schema in your Supabase SQL Editor:

```
supabase/schema.sql
```

2. Add your credentials to `lib/core/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const url = 'https://YOUR_PROJECT.supabase.co';
  static const anonKey = 'YOUR_ANON_KEY';
}
```

3. Run the app:

```bash
flutter run -d chrome
```

---

## Tests

```bash
dart test test/core/ test/features/
```

Covers domain model serialization, form validation rules, cart subtotal math, and currency formatting.

---

## Project structure

```
lib/
  core/
    config/          # Supabase credentials
    utils/           # formatPrice, form validators
  services/          # SupabaseClient singleton
  features/
    products/        # Product model, repository, gallery, selector
    cart/            # CartItem model, localStorage repository, cart sheet
    orders/          # Order models, order form sheet
    reviews/         # ProductReview model, review form sheet
  widgets/           # BrandHeader, FeatureHighlightCard
  app.dart           # Root Jaspr component
  main.dart          # Entry point — runApp()
web/
  index.html
  styles.css
test/
  core/
  features/
```

---

## Notes

- Bag state is isolated per browser — each visitor sees only their own items.
- Admin management (products, orders, reviews) happens directly in the Supabase dashboard.
- The architecture is structured so categories, payments, and delivery tracking can be added later without rewriting the UI.
