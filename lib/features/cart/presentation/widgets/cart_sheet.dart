import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../cart/domain/cart_item.dart';
import '../../../products/domain/product.dart';
import '../../../products/presentation/widgets/quantity_selector.dart';

class CartSheet extends StatelessComponent {
  const CartSheet({
    super.key,
    required this.cart,
    required this.productsById,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onCheckout,
    required this.onClose,
  });

  final List<CartItem> cart;
  final Map<String, Product> productsById;
  final void Function(String productId) onIncrement;
  final void Function(String productId) onDecrement;
  final void Function(String productId) onRemove;
  final void Function() onCheckout;
  final void Function() onClose;

  @override
  Component build(BuildContext context) {
    final subtotal = cart.fold<double>(0, (sum, item) {
      final product = productsById[item.productId];
      return sum + (product?.price ?? 0) * item.quantity;
    });

    return div(
      [
        div([
          p([Component.text('Your Bag')], classes: 'modal-title'),
          button(
            [Component.text('✕')],
            classes: 'modal-close',
            events: {'click': (_) => onClose()},
          ),
        ], classes: 'modal-header-row'),
        if (cart.isEmpty)
          div([
            p([Component.text('Your bag is empty')], classes: 'section-title'),
            p(
              [Component.text('Add products from the catalog before checking out.')],
              classes: 'product-description',
            ),
          ], classes: 'cart-empty')
        else ...[
          div(
            cart.map((item) {
              final product = productsById[item.productId];
              final imageUrl =
                  product != null && product.imageUrls.isNotEmpty
                      ? product.imageUrls.first
                      : '';
              return div(
                [
                  if (imageUrl.isNotEmpty)
                    img(src: imageUrl, alt: product!.name, classes: 'cart-item-img'),
                  div(
                    [
                      p(
                        [Component.text(product?.name ?? 'Unavailable product')],
                        classes: 'cart-item-name',
                      ),
                      p(
                        [Component.text(formatPrice((product?.price ?? 0) * item.quantity))],
                        classes: 'cart-item-price',
                      ),
                      div(
                        [
                          QuantitySelector(
                            quantity: item.quantity,
                            onIncrement: () => onIncrement(item.productId),
                            onDecrement: () => onDecrement(item.productId),
                          ),
                          button(
                            [Component.text('Remove')],
                            classes: 'cart-remove-btn',
                            events: {'click': (_) => onRemove(item.productId)},
                          ),
                        ],
                        classes: 'cart-item-controls',
                      ),
                    ],
                    classes: 'cart-item-details',
                  ),
                ],
                classes: 'cart-item',
              );
            }).toList(),
          ),
          div(
            [
              span([Component.text('Bag total')], classes: 'cart-subtotal-label'),
              span([Component.text(formatPrice(subtotal))], classes: 'cart-subtotal-value'),
            ],
            classes: 'cart-subtotal',
          ),
          button(
            [Component.text('Proceed to checkout')],
            classes: 'btn-primary',
            events: {'click': (_) => onCheckout()},
          ),
        ],
      ],
      classes: 'modal-shell',
      events: {'click': (e) => e.stopPropagation()},
    );
  }
}
