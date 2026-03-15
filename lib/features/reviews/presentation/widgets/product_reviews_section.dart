import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/domain/product.dart';
import '../../domain/product_review.dart';
import '../providers/review_providers.dart';

class ProductReviewsSection extends ConsumerWidget {
  const ProductReviewsSection({
    super.key,
    required this.product,
    required this.isDesktop,
    required this.onWriteReview,
  });

  final Product product;
  final bool isDesktop;
  final VoidCallback onWriteReview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reviewsAsync = ref.watch(productReviewsProvider(product.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Customer reviews',
                style: theme.textTheme.headlineMedium,
              ),
            ),
            SizedBox(
              width: isDesktop ? 180 : 150,
              child: FilledButton(
                onPressed: onWriteReview,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                child: const Text('Write a review'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        reviewsAsync.when(
          data: (reviews) {
            final average = reviews.isEmpty
                ? 0.0
                : reviews
                        .map((review) => review.rating)
                        .reduce((sum, rating) => sum + rating) /
                    reviews.length;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (reviews.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF2B100),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          average.toStringAsFixed(1),
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${reviews.length} review${reviews.length == 1 ? '' : 's'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (reviews.isEmpty)
                    Text(
                      'No reviews yet. Be the first customer to share one.',
                      style: theme.textTheme.bodyLarge,
                    )
                  else
                    for (var index = 0; index < reviews.length; index++) ...[
                      _ReviewCard(review: reviews[index]),
                      if (index != reviews.length - 1)
                        const SizedBox(height: 14),
                    ],
                ],
              ),
            );
          },
          loading: () => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Text('Unable to load reviews: $error'),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ProductReview review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3EC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.customerName,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              Text(
                _formatReviewDate(review.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var index = 1; index <= 5; index++)
                Icon(
                  index <= review.rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: const Color(0xFFF2B100),
                  size: 18,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(review.reviewText, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

String _formatReviewDate(DateTime value) {
  final local = value.toLocal();
  final month = switch (local.month) {
    1 => 'Jan',
    2 => 'Feb',
    3 => 'Mar',
    4 => 'Apr',
    5 => 'May',
    6 => 'Jun',
    7 => 'Jul',
    8 => 'Aug',
    9 => 'Sep',
    10 => 'Oct',
    11 => 'Nov',
    _ => 'Dec',
  };
  return '$month ${local.day}, ${local.year}';
}
