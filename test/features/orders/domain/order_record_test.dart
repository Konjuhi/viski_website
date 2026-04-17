import 'package:test/test.dart';
import 'package:swift_shop/features/orders/domain/order_record.dart';

void main() {
  group('OrderRecord.fromJson', () {
    final fullJson = {
      'id': 'ord-1',
      'product_id': 'prod-1',
      'customer_name': 'John Doe',
      'phone': '12345678',
      'address': '123 Main St',
      'quantity': 2,
      'status': 'confirmed',
      'created_at': '2024-03-01T09:00:00.000Z',
    };

    test('parses all fields correctly', () {
      final o = OrderRecord.fromJson(fullJson);
      expect(o.id, 'ord-1');
      expect(o.productId, 'prod-1');
      expect(o.customerName, 'John Doe');
      expect(o.phone, '12345678');
      expect(o.address, '123 Main St');
      expect(o.quantity, 2);
      expect(o.status, 'confirmed');
      expect(o.createdAt, DateTime.parse('2024-03-01T09:00:00.000Z'));
    });

    test('converts int id to string', () {
      final o = OrderRecord.fromJson({...fullJson, 'id': 99});
      expect(o.id, '99');
    });

    test('converts int product_id to string', () {
      final o = OrderRecord.fromJson({...fullJson, 'product_id': 7});
      expect(o.productId, '7');
    });

    test('defaults status to pending_confirmation when missing', () {
      final o = OrderRecord.fromJson({...fullJson, 'status': null});
      expect(o.status, 'pending_confirmation');
    });

    test('defaults missing string fields to empty string', () {
      final o = OrderRecord.fromJson({'id': 'x', 'product_id': 'y'});
      expect(o.customerName, '');
      expect(o.phone, '');
      expect(o.address, '');
    });

    test('defaults quantity to 1 when missing', () {
      final o = OrderRecord.fromJson({'id': 'x', 'product_id': 'y'});
      expect(o.quantity, 1);
    });

    test('falls back to epoch on invalid created_at', () {
      final o = OrderRecord.fromJson({...fullJson, 'created_at': 'bad-date'});
      expect(o.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
    });
  });

  group('OrderRecord.toJson', () {
    final order = OrderRecord(
      id: 'ord-1',
      productId: 'prod-1',
      customerName: 'John Doe',
      phone: '12345678',
      address: '123 Main St',
      quantity: 2,
      status: 'confirmed',
      createdAt: DateTime.parse('2024-03-01T09:00:00.000Z'),
    );

    test('serializes all fields with correct keys', () {
      final json = order.toJson();
      expect(json['id'], 'ord-1');
      expect(json['product_id'], 'prod-1');
      expect(json['customer_name'], 'John Doe');
      expect(json['phone'], '12345678');
      expect(json['address'], '123 Main St');
      expect(json['quantity'], 2);
      expect(json['status'], 'confirmed');
    });
  });
}
