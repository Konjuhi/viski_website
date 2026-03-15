import '../features/orders/domain/create_order_request.dart';

abstract class OrderRepository {
  Future<void> createOrder(CreateOrderRequest request);
}
