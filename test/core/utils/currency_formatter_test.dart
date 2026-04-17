import 'package:test/test.dart';
import 'package:swift_shop/core/utils/currency_formatter.dart';

void main() {
  group('formatPrice', () {
    test('formats zero', () {
      expect(formatPrice(0), '\$0.00');
    });

    test('formats a typical price', () {
      expect(formatPrice(1.99), '\$1.99');
    });

    test('formats a whole number with two decimal places', () {
      expect(formatPrice(10), '\$10.00');
    });

    test('rounds to two decimal places', () {
      expect(formatPrice(1.999), '\$2.00');
      expect(formatPrice(1.994), '\$1.99');
    });

    test('formats large price', () {
      expect(formatPrice(1000.50), '\$1000.50');
    });

    test('formats a single decimal digit price', () {
      expect(formatPrice(5.5), '\$5.50');
    });
  });
}
