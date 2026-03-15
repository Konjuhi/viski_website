import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../repositories/order_repository.dart';
import '../domain/create_order_request.dart';

class SupabaseOrderRepository implements OrderRepository {
  const SupabaseOrderRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> createOrder(CreateOrderRequest request) async {
    await _client.rpc('create_order_with_items', params: request.toJson());
  }
}
