import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../repositories/order_repository.dart';
import '../../../../services/supabase_service.dart';
import '../../data/supabase_order_repository.dart';
import '../../domain/create_order_request.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseOrderRepository(client);
});

final orderSubmissionControllerProvider =
    AsyncNotifierProvider.autoDispose<OrderSubmissionController, void>(
      OrderSubmissionController.new,
    );

class OrderSubmissionController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submitOrder(CreateOrderRequest request) async {
    final repository = ref.read(orderRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.createOrder(request);
    });
  }
}
