import '../features/reviews/domain/create_product_review_request.dart';
import '../features/reviews/domain/product_review.dart';

abstract class ReviewRepository {
  Future<List<ProductReview>> fetchApprovedReviews(String productId);

  Future<void> submitReview(CreateProductReviewRequest request);
}
