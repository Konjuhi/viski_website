import 'package:supabase/supabase.dart';

import '../../../repositories/review_repository.dart';
import '../domain/create_product_review_request.dart';
import '../domain/product_review.dart';

class SupabaseReviewRepository implements ReviewRepository {
  const SupabaseReviewRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ProductReview>> fetchApprovedReviews(String productId) async {
    final response = await _client
        .from('product_reviews')
        .select()
        .eq('product_id', productId)
        .eq('approved', true)
        .order('created_at', ascending: false);

    final data = (response as List).cast<Map<String, dynamic>>();
    return data.map(ProductReview.fromJson).toList();
  }

  @override
  Future<void> submitReview(CreateProductReviewRequest request) async {
    await _client.from('product_reviews').insert(request.toJson());
  }
}
