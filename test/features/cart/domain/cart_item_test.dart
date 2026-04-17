import 'package:test/test.dart';
import 'package:swift_shop/features/cart/domain/cart_item.dart';

void main() {
  group('CartItem.fromJson', () {
    test('parses all fields correctly', () {
      final item = CartItem.fromJson({'product_id': 'prod-1', 'quantity': 3});
      expect(item.productId, 'prod-1');
      expect(item.quantity, 3);
    });

    test('defaults product_id to empty string when missing', () {
      final item = CartItem.fromJson({'quantity': 2});
      expect(item.productId, '');
    });

    test('defaults quantity to 1 when missing', () {
      final item = CartItem.fromJson({'product_id': 'prod-1'});
      expect(item.quantity, 1);
    });

    test('defaults both fields when json is empty', () {
      final item = CartItem.fromJson({});
      expect(item.productId, '');
      expect(item.quantity, 1);
    });
  });

  group('CartItem.toJson', () {
    test('serializes correctly', () {
      const item = CartItem(productId: 'prod-1', quantity: 2);
      expect(item.toJson(), {'product_id': 'prod-1', 'quantity': 2});
    });

    test('round-trip produces identical object', () {
      const original = CartItem(productId: 'prod-abc', quantity: 5);
      final restored = CartItem.fromJson(original.toJson());
      expect(restored.productId, original.productId);
      expect(restored.quantity, original.quantity);
    });
  });

  group('CartItem.copyWith', () {
    const item = CartItem(productId: 'prod-1', quantity: 2);

    test('copies with new productId', () {
      final copy = item.copyWith(productId: 'prod-2');
      expect(copy.productId, 'prod-2');
      expect(copy.quantity, 2);
    });

    test('copies with new quantity', () {
      final copy = item.copyWith(quantity: 10);
      expect(copy.productId, 'prod-1');
      expect(copy.quantity, 10);
    });

    test('preserves all fields when no overrides', () {
      final copy = item.copyWith();
      expect(copy.productId, item.productId);
      expect(copy.quantity, item.quantity);
    });
  });

  group('Cart subtotal calculation', () {
    test('empty cart totals zero', () {
      final cart = <CartItem>[];
      final subtotal = cart.fold<double>(0, (sum, _) => sum);
      expect(subtotal, 0.0);
    });

    test('single item: price × quantity', () {
      const item = CartItem(productId: 'p1', quantity: 3);
      const price = 1.99;
      final subtotal = price * item.quantity;
      expect(subtotal, closeTo(5.97, 0.001));
    });

    test('multiple items sum correctly', () {
      final prices = {'p1': 1.99, 'p2': 4.50};
      final cart = [
        const CartItem(productId: 'p1', quantity: 2),
        const CartItem(productId: 'p2', quantity: 1),
      ];
      final subtotal = cart.fold<double>(
        0,
        (sum, item) => sum + (prices[item.productId] ?? 0) * item.quantity,
      );
      expect(subtotal, closeTo(8.48, 0.001));
    });

    test('missing product uses 0 for price', () {
      const item = CartItem(productId: 'unknown', quantity: 5);
      final prices = <String, double>{};
      final subtotal = (prices[item.productId] ?? 0) * item.quantity;
      expect(subtotal, 0.0);
    });
  });
}
