import 'package:test/test.dart';
import 'package:swift_shop/features/orders/domain/create_order_request.dart';
import 'package:swift_shop/features/orders/domain/create_order_item_request.dart';

void main() {
  group('CreateOrderItemRequest.toJson', () {
    test('uses product_id key', () {
      const item = CreateOrderItemRequest(productId: 'prod-1', quantity: 3);
      expect(item.toJson(), {'product_id': 'prod-1', 'quantity': 3});
    });
  });

  group('CreateOrderRequest.toJson', () {
    test('uses _input suffix keys', () {
      const req = CreateOrderRequest(
        customerName: 'Jane',
        phone: '12345678',
        address: '5 Park Ave',
        items: [],
      );
      final json = req.toJson();
      expect(json['customer_name_input'], 'Jane');
      expect(json['phone_input'], '12345678');
      expect(json['address_input'], '5 Park Ave');
      expect(json['items_input'], isEmpty);
    });

    test('serializes nested items correctly', () {
      const req = CreateOrderRequest(
        customerName: 'Jane',
        phone: '12345678',
        address: '5 Park Ave',
        items: [
          CreateOrderItemRequest(productId: 'p1', quantity: 2),
          CreateOrderItemRequest(productId: 'p2', quantity: 1),
        ],
      );
      final items = req.toJson()['items_input'] as List;
      expect(items.length, 2);
      expect(items[0], {'product_id': 'p1', 'quantity': 2});
      expect(items[1], {'product_id': 'p2', 'quantity': 1});
    });
  });
}
