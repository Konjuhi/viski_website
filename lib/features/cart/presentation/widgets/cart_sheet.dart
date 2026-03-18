import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../widgets/storefront_modal_shell.dart';
import '../../../orders/presentation/widgets/order_form_sheet.dart';
import '../../../products/domain/product.dart';
import '../../../products/presentation/widgets/quantity_selector.dart';
import '../../domain/cart_item.dart';
import '../providers/cart_providers.dart';

const _summarySurfaceColor = Color(0xFFF6F3EC);

class CartSheet extends ConsumerWidget {
  const CartSheet({
    super.key,
    required this.productsById,
    required this.isDesktop,
  });

  final Map<String, Product> productsById;
  final bool isDesktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cartAsync = ref.watch(cartControllerProvider);

    return SafeArea(
      child: cartAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24, isDesktop ? 24 : 0, 24, 44),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Your bag',
                          style: theme.textTheme.headlineMedium,
                        ),
                      ),
                      _CloseButton(
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your bag is empty',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontSize: 34,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Text(
                      'Add products from the catalog before checking out.',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          final subtotal = items.fold<double>(0, (sum, item) {
            final product = productsById[item.productId];
            if (product == null) {
              return sum;
            }
            return sum + product.price * item.quantity;
          });

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              24 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Your bag',
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                    _CloseButton(
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This bag is stored only on this browser or device.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                for (final item in items) ...[
                  _CartItemTile(
                    item: item,
                    product: productsById[item.productId],
                    onIncrement: () {
                      ref
                          .read(cartControllerProvider.notifier)
                          .increment(item.productId);
                    },
                    onDecrement: () {
                      ref
                          .read(cartControllerProvider.notifier)
                          .decrement(item.productId);
                    },
                    onRemove: () {
                      ref
                          .read(cartControllerProvider.notifier)
                          .remove(item.productId);
                    },
                  ),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _summarySurfaceColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Bag total', style: theme.textTheme.titleMedium),
                      Text(
                        formatPrice(subtotal),
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () async {
                    final result = await _openCheckoutSheet(
                      context,
                      items,
                      productsById,
                    );

                    if (result == true && context.mounted) {
                      Navigator.of(context).pop(true);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  child: const Text('Proceed to checkout'),
                ),
              ],
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Unable to load bag: $error'),
        ),
      ),
    );
  }

  Future<bool?> _openCheckoutSheet(
    BuildContext context,
    List<CartItem> items,
    Map<String, Product> productsById,
  ) {
    if (isDesktop) {
      return showDialog<bool>(
        context: context,
        builder: (context) {
          return StorefrontModalShell(
            maxWidth: 560,
            child: OrderFormSheet(items: items, productsById: productsById),
          );
        },
      );
    }

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return OrderFormSheet(items: items, productsById: productsById);
      },
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black),
        ),
        child: const Icon(Icons.close, size: 20, color: Colors.black),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.product,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartItem item;
  final Product? product;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = product == null || product!.imageUrls.isEmpty
        ? null
        : product!.imageUrls.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F1E8),
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl == null
                    ? const Icon(Icons.inventory_2_outlined)
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const Icon(Icons.broken_image_outlined);
                        },
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.name ?? 'Unavailable product',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product?.description ??
                          'This product is no longer active.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      formatPrice((product?.price ?? 0) * item.quantity),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              QuantitySelector(
                quantity: item.quantity,
                onDecrement: onDecrement,
                onIncrement: onIncrement,
              ),
              const Spacer(),
              TextButton(
                onPressed: onRemove,
                style: TextButton.styleFrom(foregroundColor: Colors.black),
                child: const Text('Remove'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
