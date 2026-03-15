import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../repositories/review_repository.dart';
import '../../../../services/supabase_service.dart';
import '../../data/supabase_review_repository.dart';
import '../../domain/create_product_review_request.dart';
import '../../domain/product_review.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseReviewRepository(client);
});

final productReviewsProvider =
    FutureProvider.family<List<ProductReview>, String>((ref, productId) async {
      final repository = ref.watch(reviewRepositoryProvider);
      return repository.fetchApprovedReviews(productId);
    });

final reviewSubmissionControllerProvider =
    AsyncNotifierProvider<ReviewSubmissionController, void>(
      ReviewSubmissionController.new,
    );

class ReviewSubmissionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submitReview(CreateProductReviewRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(reviewRepositoryProvider);
      await repository.submitReview(request);
      ref.invalidate(productReviewsProvider(request.productId));
    });
  }
}
