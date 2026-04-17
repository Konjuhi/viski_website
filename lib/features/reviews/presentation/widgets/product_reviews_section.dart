import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

import '../../../products/domain/product.dart';
import '../../domain/product_review.dart';

class ProductReviewsSection extends StatelessComponent {
  const ProductReviewsSection({
    super.key,
    required this.product,
    required this.reviews,
    required this.onWriteReview,
  });

  final Product product;
  final List<ProductReview> reviews;
  final void Function() onWriteReview;

  @override
  Component build(BuildContext context) {
    final avg = reviews.isNotEmpty
        ? (reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                reviews.length)
            .toStringAsFixed(1)
        : null;

    return section([
      div([
        h2([Component.text('Customer reviews')], classes: 'section-title'),
        button(
          [Component.text('Write a review')],
          classes: 'btn-secondary',
          styles: Styles(raw: {'width': 'auto', 'padding': '10px 20px'}),
          events: {'click': (_) => onWriteReview()},
        ),
      ], classes: 'reviews-header'),
      if (reviews.isNotEmpty)
        div([
          span([Component.text('★ $avg')], classes: 'reviews-avg'),
          span(
            [Component.text('${reviews.length} review${reviews.length == 1 ? '' : 's'}')],
            classes: 'reviews-count',
          ),
        ], classes: 'reviews-summary'),
      if (reviews.isEmpty)
        p(
          [Component.text('No reviews yet. Be the first to share one.')],
          classes: 'reviews-empty',
        )
      else
        div(reviews.map(_reviewCard).toList(), classes: 'review-list'),
    ], classes: 'reviews-section');
  }

  Component _reviewCard(ProductReview review) {
    final stars = List.generate(
      5,
      (i) => span(
        [Component.text('★')],
        classes: i < review.rating ? 'star-filled' : 'star-empty',
      ),
    );

    return div(
      [
        div(
          [
            span([Component.text(review.customerName)], classes: 'review-author'),
            span([Component.text(_formatDate(review.createdAt))], classes: 'review-date'),
          ],
          classes: 'review-card-header',
        ),
        div(stars, classes: 'stars'),
        p([Component.text(review.reviewText)], classes: 'review-text'),
      ],
      classes: 'review-card',
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }
}
