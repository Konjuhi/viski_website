import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../widgets/brand_header.dart';
import '../../../../widgets/feature_highlight_card.dart';
import '../../../../widgets/storefront_modal_shell.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../cart/presentation/widgets/cart_sheet.dart';
import '../../../reviews/domain/product_review.dart';
import '../../../reviews/presentation/providers/review_providers.dart';
import '../../../reviews/presentation/widgets/product_reviews_section.dart';
import '../../../reviews/presentation/widgets/review_form_sheet.dart';
import '../../domain/product.dart';
import '../providers/product_providers.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/product_selector_list.dart';
import '../widgets/quantity_selector.dart';

class StorefrontScreen extends ConsumerWidget {
  const StorefrontScreen({super.key});

  static const _featureItems = [
    (
      'Phone Confirmation',
      'When you place an order, the owner receives an SMS notification and will contact you as soon as possible to confirm it.',
    ),
    (
      'Local Bag Privacy',
      'Each visitor keeps a separate bag on their own browser or device without seeing anybody else\'s items.',
    ),
    (
      'Ready For Growth',
      'The app now separates products, bag state, and checkout so categories and payments can be added later.',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(activeProductsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE7E0D3), Color(0xFFF5F2EB), Color(0xFFD8E0E5)],
          ),
        ),
        child: SafeArea(
          child: productsAsync.when(
            data: (products) {
              if (products.isEmpty) {
                return const _CenteredState(
                  title: 'No active products',
                  message:
                      'Add rows to the products table in Supabase and set active = true.',
                );
              }

              final selectedProduct = ref.watch(selectedProductProvider);
              if (selectedProduct == null) {
                return const SizedBox.shrink();
              }

              final quantity = ref.watch(productQuantityProvider);
              final cartCount = ref.watch(cartItemCountProvider);
              final reviewsAsync = ref.watch(
                productReviewsProvider(selectedProduct.id),
              );
              final productsById = {
                for (final product in products) product.id: product,
              };

              final scaffoldContext = context;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 960;
                  final sidePadding = isDesktop ? 40.0 : 20.0;

                  Future<void> openBag() async {
                    final result = await _openCartSheet(
                      scaffoldContext,
                      productsById,
                      isDesktop: isDesktop,
                    );

                    if (result == true && scaffoldContext.mounted) {
                      _showSuccessDialog(scaffoldContext);
                    }
                  }

                  Future<void> openReviewForm() async {
                    await _openReviewSheet(
                      scaffoldContext,
                      selectedProduct,
                      isDesktop: isDesktop,
                    );
                  }

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      sidePadding,
                      24,
                      sidePadding,
                      32,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1240),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BrandHeader(
                              cartCount: cartCount,
                              onCartTap: openBag,
                            ),
                            const SizedBox(height: 28),
                            _ProductHero(
                              product: selectedProduct,
                              reviewsAsync: reviewsAsync,
                              quantity: quantity,
                              isDesktop: isDesktop,
                              onIncrement: () {
                                ref
                                    .read(productQuantityProvider.notifier)
                                    .increment();
                              },
                              onDecrement: () {
                                ref
                                    .read(productQuantityProvider.notifier)
                                    .decrement();
                              },
                              onAddToBag: () async {
                                await ref
                                    .read(cartControllerProvider.notifier)
                                    .addItem(
                                      productId: selectedProduct.id,
                                      quantity: quantity,
                                    );

                                if (scaffoldContext.mounted) {
                                  final messenger = ScaffoldMessenger.of(
                                    scaffoldContext,
                                  );
                                  messenger
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        elevation: 0,
                                        backgroundColor: Colors.transparent,
                                        margin: EdgeInsets.fromLTRB(
                                          24,
                                          0,
                                          24,
                                          isDesktop ? 28 : 18,
                                        ),
                                        content: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: const Color(0x1A000000),
                                            ),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color(0x14000000),
                                                blurRadius: 28,
                                                offset: Offset(0, 14),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 38,
                                                height: 38,
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFF6F3EC,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Icon(
                                                  Icons.check,
                                                  size: 18,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Text(
                                                  '${selectedProduct.name} added to your bag.',
                                                  style: Theme.of(
                                                    scaffoldContext,
                                                  ).textTheme.titleMedium,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              TextButton(
                                                onPressed: () {
                                                  messenger
                                                      .hideCurrentSnackBar();
                                                  openBag();
                                                },
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.black,
                                                  padding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                                ),
                                                child: const Text(
                                                  'View Bag',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                }
                              },
                              onViewBag: openBag,
                              onWriteReview: openReviewForm,
                            ),
                            const SizedBox(height: 28),
                            Text(
                              'Browse products',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 16),
                            ProductSelectorList(
                              products: products,
                              selectedProductId: selectedProduct.id,
                              onProductSelected: (product) {
                                ref
                                    .read(selectedProductIdProvider.notifier)
                                    .select(product.id);
                                ref
                                    .read(productQuantityProvider.notifier)
                                    .reset();
                              },
                            ),
                            const SizedBox(height: 28),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: isDesktop ? 3 : 1,
                                    crossAxisSpacing: 18,
                                    mainAxisSpacing: 18,
                                    mainAxisExtent: 150,
                                  ),
                              itemCount: _featureItems.length,
                              itemBuilder: (context, index) {
                                final item = _featureItems[index];
                                return FeatureHighlightCard(
                                  title: item.$1,
                                  description: item.$2,
                                );
                              },
                            ),
                            const SizedBox(height: 28),
                            ProductReviewsSection(
                              product: selectedProduct,
                              isDesktop: isDesktop,
                              onWriteReview: openReviewForm,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const _CenteredState(
              title: 'Loading catalog',
              message: 'Fetching products from Supabase.',
              showLoader: true,
            ),
            error: (error, _) => _CenteredState(
              title: 'Unable to load products',
              message: '$error',
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _openCartSheet(
    BuildContext context,
    Map<String, Product> productsById, {
    required bool isDesktop,
  }) {
    if (isDesktop) {
      return showDialog<bool>(
        context: context,
        builder: (context) {
          return StorefrontModalShell(
            maxWidth: 640,
            child: CartSheet(productsById: productsById, isDesktop: true),
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
        return CartSheet(productsById: productsById, isDesktop: false);
      },
    );
  }

  Future<bool?> _openReviewSheet(
    BuildContext context,
    Product product, {
    required bool isDesktop,
  }) {
    if (isDesktop) {
      return showDialog<bool>(
        context: context,
        builder: (context) {
          return StorefrontModalShell(
            maxWidth: 560,
            child: ReviewFormSheet(product: product),
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
        return ReviewFormSheet(product: product);
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);

        return StorefrontModalShell(
          maxWidth: 620,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(36, 36, 36, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Order request sent',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontSize: 34,
                  ),
                ),
                const SizedBox(height: 18),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Text(
                    'Your order request was submitted successfully. '
                    'The business owner will contact you as soon as possible to confirm it.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProductHero extends StatelessWidget {
  const _ProductHero({
    required this.product,
    required this.reviewsAsync,
    required this.quantity,
    required this.isDesktop,
    required this.onIncrement,
    required this.onDecrement,
    required this.onAddToBag,
    required this.onViewBag,
    required this.onWriteReview,
  });

  final Product product;
  final AsyncValue<List<ProductReview>> reviewsAsync;
  final int quantity;
  final bool isDesktop;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onAddToBag;
  final VoidCallback onViewBag;
  final VoidCallback onWriteReview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final infoPanel = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
          ),
          child: _ReviewPill(reviewsAsync: reviewsAsync),
        ),
        const SizedBox(height: 18),
        Text(product.name, style: theme.textTheme.displaySmall),
        const SizedBox(height: 10),
        Text(
          formatPrice(product.price),
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 18),
        Text(
          product.description,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 28),
        Text('Quantity', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        QuantitySelector(
          quantity: quantity,
          onDecrement: onDecrement,
          onIncrement: onIncrement,
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: onAddToBag,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          child: const Text('Add to Bag'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onViewBag,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            side: const BorderSide(color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          child: const Text('View Bag'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onWriteReview,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            side: const BorderSide(color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          child: const Text('Write a review'),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            _MetaStat(
              label: 'Shipping',
              value: 'Owner confirms delivery by phone',
            ),
            _MetaStat(label: 'Bag', value: 'Private to this browser or device'),
          ],
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(36),
      ),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: ProductImageGallery(
                    key: ValueKey(product.id),
                    product: product,
                    height: 560,
                  ),
                ),
                const SizedBox(width: 28),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 18,
                    ),
                    child: infoPanel,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductImageGallery(
                  key: ValueKey(product.id),
                  product: product,
                  height: 340,
                ),
                const SizedBox(height: 24),
                infoPanel,
              ],
            ),
    );
  }
}

class _ReviewPill extends StatelessWidget {
  const _ReviewPill({required this.reviewsAsync});

  final AsyncValue<List<ProductReview>> reviewsAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_outline_rounded,
                color: Color(0xFFF2B100),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text('No reviews yet', style: theme.textTheme.bodySmall),
            ],
          );
        }

        final average = reviews
                .map((review) => review.rating)
                .reduce((sum, rating) => sum + rating) /
            reviews.length;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star_rounded,
              color: Color(0xFFF2B100),
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              '${average.toStringAsFixed(1)} (${reviews.length} review${reviews.length == 1 ? '' : 's'})',
              style: theme.textTheme.bodySmall,
            ),
          ],
        );
      },
      loading: () => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text('Loading reviews', style: theme.textTheme.bodySmall),
        ],
      ),
      error: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_outline_rounded,
            color: Color(0xFFF2B100),
            size: 18,
          ),
          const SizedBox(width: 6),
          Text('Reviews unavailable', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _MetaStat extends StatelessWidget {
  const _MetaStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              letterSpacing: 0.8,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.title,
    required this.message,
    this.showLoader = false,
  });

  final String title;
  final String message;
  final bool showLoader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showLoader) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                  ],
                  Text(title, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
