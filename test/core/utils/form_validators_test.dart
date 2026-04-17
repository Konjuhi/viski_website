import 'package:test/test.dart';
import 'package:swift_shop/core/utils/form_validators.dart';

void main() {
  group('validateOrderForm', () {
    test('returns no errors when all fields are valid', () {
      final e = validateOrderForm(name: 'John Doe', phone: '12345678', address: '123 Main Street');
      expect(e.isValid, true);
      expect(e.name, isNull);
      expect(e.phone, isNull);
      expect(e.address, isNull);
    });

    group('name validation', () {
      test('empty name returns error', () {
        final e = validateOrderForm(name: '', phone: '12345678', address: '123 Main Street');
        expect(e.name, 'Enter your full name.');
      });

      test('single character name returns error', () {
        final e = validateOrderForm(name: 'A', phone: '12345678', address: '123 Main Street');
        expect(e.name, 'Enter your full name.');
      });

      test('two character name is valid', () {
        final e = validateOrderForm(name: 'Jo', phone: '12345678', address: '123 Main Street');
        expect(e.name, isNull);
      });

      test('whitespace-only name returns error', () {
        final e = validateOrderForm(name: '   ', phone: '12345678', address: '123 Main Street');
        expect(e.name, 'Enter your full name.');
      });

      test('name with surrounding spaces is trimmed before check', () {
        final e = validateOrderForm(name: ' J ', phone: '12345678', address: '123 Main Street');
        expect(e.name, 'Enter your full name.');
      });
    });

    group('phone validation', () {
      test('phone shorter than 8 chars returns error', () {
        final e = validateOrderForm(name: 'John', phone: '1234567', address: '123 Main Street');
        expect(e.phone, 'Enter a valid phone number.');
      });

      test('phone with exactly 8 chars is valid', () {
        final e = validateOrderForm(name: 'John', phone: '12345678', address: '123 Main Street');
        expect(e.phone, isNull);
      });

      test('empty phone returns error', () {
        final e = validateOrderForm(name: 'John', phone: '', address: '123 Main Street');
        expect(e.phone, 'Enter a valid phone number.');
      });
    });

    group('address validation', () {
      test('address shorter than 8 chars returns error', () {
        final e = validateOrderForm(name: 'John', phone: '12345678', address: '5 St');
        expect(e.address, 'Enter a delivery address.');
      });

      test('address with exactly 8 chars is valid', () {
        final e = validateOrderForm(name: 'John', phone: '12345678', address: '12345678');
        expect(e.address, isNull);
      });

      test('empty address returns error', () {
        final e = validateOrderForm(name: 'John', phone: '12345678', address: '');
        expect(e.address, 'Enter a delivery address.');
      });
    });

    test('all fields invalid returns all errors', () {
      final e = validateOrderForm(name: '', phone: '', address: '');
      expect(e.isValid, false);
      expect(e.name, isNotNull);
      expect(e.phone, isNotNull);
      expect(e.address, isNotNull);
    });
  });

  group('validateReviewForm', () {
    test('returns no errors when all fields are valid', () {
      final e = validateReviewForm(name: 'Alice', reviewText: 'Great product!');
      expect(e.isValid, true);
      expect(e.name, isNull);
      expect(e.reviewText, isNull);
    });

    group('name validation', () {
      test('empty name returns error', () {
        final e = validateReviewForm(name: '', reviewText: 'Great product!');
        expect(e.name, 'Enter your name.');
      });

      test('single character name returns error', () {
        final e = validateReviewForm(name: 'A', reviewText: 'Great product!');
        expect(e.name, 'Enter your name.');
      });

      test('two character name is valid', () {
        final e = validateReviewForm(name: 'Al', reviewText: 'Great product!');
        expect(e.name, isNull);
      });

      test('whitespace-only name returns error', () {
        final e = validateReviewForm(name: '  ', reviewText: 'Great product!');
        expect(e.name, 'Enter your name.');
      });
    });

    group('review text validation', () {
      test('review shorter than 6 chars returns error', () {
        final e = validateReviewForm(name: 'Alice', reviewText: 'Good');
        expect(e.reviewText, 'Write a short review.');
      });

      test('review with exactly 6 chars is valid', () {
        final e = validateReviewForm(name: 'Alice', reviewText: 'Loved!');
        expect(e.reviewText, isNull);
      });

      test('empty review returns error', () {
        final e = validateReviewForm(name: 'Alice', reviewText: '');
        expect(e.reviewText, 'Write a short review.');
      });

      test('whitespace-only review returns error', () {
        final e = validateReviewForm(name: 'Alice', reviewText: '      ');
        expect(e.reviewText, 'Write a short review.');
      });
    });

    test('both fields invalid returns all errors', () {
      final e = validateReviewForm(name: '', reviewText: '');
      expect(e.isValid, false);
      expect(e.name, isNotNull);
      expect(e.reviewText, isNotNull);
    });
  });
}
