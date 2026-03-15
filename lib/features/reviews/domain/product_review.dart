class ProductReview {
  const ProductReview({
    required this.id,
    required this.productId,
    required this.customerName,
    required this.rating,
    required this.reviewText,
    required this.approved,
    required this.createdAt,
  });

  final String id;
  final String productId;
  final String customerName;
  final int rating;
  final String reviewText;
  final bool approved;
  final DateTime createdAt;

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'].toString(),
      productId: json['product_id'].toString(),
      customerName: json['customer_name'] as String? ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      reviewText: json['review_text'] as String? ?? '',
      approved: json['approved'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
