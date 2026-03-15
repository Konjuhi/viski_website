class CreateProductReviewRequest {
  const CreateProductReviewRequest({
    required this.productId,
    required this.customerName,
    required this.rating,
    required this.reviewText,
  });

  final String productId;
  final String customerName;
  final int rating;
  final String reviewText;

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'customer_name': customerName,
      'rating': rating,
      'review_text': reviewText,
    };
  }
}
