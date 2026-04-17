import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

class BrandHeader extends StatelessComponent {
  const BrandHeader({
    super.key,
    required this.cartCount,
    required this.onCartTap,
  });

  final int cartCount;
  final void Function() onCartTap;

  @override
  Component build(BuildContext context) {
    return header([
      span([Component.text('SWIFTSHOP')], classes: 'brand-logo'),
      button(
        [
          Component.text('Bag'),
          if (cartCount > 0) span([Component.text('$cartCount')], classes: 'cart-badge'),
        ],
        classes: 'cart-btn',
        events: {'click': (_) => onCartTap()},
      ),
    ], classes: 'header');
  }
}
