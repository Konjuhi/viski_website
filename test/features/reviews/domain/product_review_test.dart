import 'package:test/test.dart';
import 'package:swift_shop/features/reviews/domain/product_review.dart';
import 'package:swift_shop/features/reviews/domain/create_product_review_request.dart';

void main() {
  group('ProductReview.fromJson', () {
    final fullJson = {
      'id': 'rev-1',
      'product_id': 'prod-1',
      'customer_name': 'Alice',
      'rating': 5,
      'review_text': 'Amazing product!',
      'approved': true,
      'created_at': '2024-02-10T08:00:00.000Z',
    };

    test('parses all fields correctly', () {
      final r = ProductReview.fromJson(fullJson);
      expect(r.id, 'rev-1');
      expect(r.productId, 'prod-1');
      expect(r.customerName, 'Alice');
      expect(r.rating, 5);
      expect(r.reviewText, 'Amazing product!');
      expect(r.approved, true);
      expect(r.createdAt, DateTime.parse('2024-02-10T08:00:00.000Z'));
    });

    test('converts num rating to int', () {
      final r = ProductReview.fromJson({...fullJson, 'rating': 4.0});
      expect(r.rating, isA<int>());
      expect(r.rating, 4);
    });

    test('converts int id to string', () {
      final r = ProductReview.fromJson({...fullJson, 'id': 10});
      expect(r.id, '10');
    });

    test('defaults missing fields to safe values', () {
      final r = ProductReview.fromJson({'id': 'x', 'product_id': 'y'});
      expect(r.customerName, '');
      expect(r.rating, 0);
      expect(r.reviewText, '');
      expect(r.approved, false);
      expect(r.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('falls back to epoch on invalid created_at', () {
      final r = ProductReview.fromJson({...fullJson, 'created_at': 'bad'});
      expect(r.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
    });
  });

  group('CreateProductReviewRequest.toJson', () {
    test('serializes all fields with correct keys', () {
      const req = CreateProductReviewRequest(
        productId: 'prod-1',
        customerName: 'Bob',
        rating: 4,
        reviewText: 'Good stuff',
      );
      final json = req.toJson();
      expect(json['product_id'], 'prod-1');
      expect(json['customer_name'], 'Bob');
      expect(json['rating'], 4);
      expect(json['review_text'], 'Good stuff');
    });
  });

  group('Review average rating calculation', () {
    test('single review returns its own rating', () {
      final reviews = [
        ProductReview.fromJson({'id': '1', 'product_id': 'p', 'rating': 5, 'created_at': '2024-01-01T00:00:00Z'}),
      ];
      final avg = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
      expect(avg, 5.0);
    });

    test('multiple reviews average correctly', () {
      final reviews = [
        ProductReview.fromJson({'id': '1', 'product_id': 'p', 'rating': 4, 'created_at': '2024-01-01T00:00:00Z'}),
        ProductReview.fromJson({'id': '2', 'product_id': 'p', 'rating': 5, 'created_at': '2024-01-01T00:00:00Z'}),
        ProductReview.fromJson({'id': '3', 'product_id': 'p', 'rating': 3, 'created_at': '2024-01-01T00:00:00Z'}),
      ];
      final avg = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
      expect(avg, closeTo(4.0, 0.001));
    });
  });
}
