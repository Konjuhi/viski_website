import 'package:test/test.dart';
import 'package:swift_shop/features/products/domain/product.dart';

void main() {
  group('Product.fromJson', () {
    final fullJson = {
      'id': 'abc',
      'name': 'Areon Perfume',
      'description': 'A nice scent',
      'price': 1.99,
      'image_urls': ['https://example.com/img.jpg', 'https://example.com/img2.jpg'],
      'active': true,
      'created_at': '2024-01-15T10:00:00.000Z',
    };

    test('parses all fields correctly', () {
      final p = Product.fromJson(fullJson);
      expect(p.id, 'abc');
      expect(p.name, 'Areon Perfume');
      expect(p.description, 'A nice scent');
      expect(p.price, 1.99);
      expect(p.imageUrls, ['https://example.com/img.jpg', 'https://example.com/img2.jpg']);
      expect(p.active, true);
      expect(p.createdAt, DateTime.parse('2024-01-15T10:00:00.000Z'));
    });

    test('converts int id to string', () {
      final p = Product.fromJson({...fullJson, 'id': 42});
      expect(p.id, '42');
    });

    test('converts num price to double', () {
      final p = Product.fromJson({...fullJson, 'price': 5});
      expect(p.price, isA<double>());
      expect(p.price, 5.0);
    });

    test('defaults missing fields to safe values', () {
      final p = Product.fromJson({'id': 'x'});
      expect(p.name, '');
      expect(p.description, '');
      expect(p.price, 0.0);
      expect(p.imageUrls, isEmpty);
      expect(p.active, false);
      expect(p.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('filters empty strings from image_urls', () {
      final p = Product.fromJson({...fullJson, 'image_urls': ['https://img.com/a.jpg', '', 'https://img.com/b.jpg']});
      expect(p.imageUrls, ['https://img.com/a.jpg', 'https://img.com/b.jpg']);
    });

    test('filters non-string entries from image_urls', () {
      final p = Product.fromJson({...fullJson, 'image_urls': ['https://img.com/a.jpg', 42, null]});
      expect(p.imageUrls, ['https://img.com/a.jpg']);
    });

    test('handles null image_urls', () {
      final p = Product.fromJson({...fullJson, 'image_urls': null});
      expect(p.imageUrls, isEmpty);
    });

    test('falls back to epoch on invalid created_at', () {
      final p = Product.fromJson({...fullJson, 'created_at': 'not-a-date'});
      expect(p.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
    });
  });

  group('Product.toJson', () {
    final product = Product(
      id: 'abc',
      name: 'Areon Perfume',
      description: 'A nice scent',
      price: 1.99,
      imageUrls: ['https://example.com/img.jpg'],
      active: true,
      createdAt: DateTime.parse('2024-01-15T10:00:00.000Z'),
    );

    test('serializes all fields', () {
      final json = product.toJson();
      expect(json['id'], 'abc');
      expect(json['name'], 'Areon Perfume');
      expect(json['price'], 1.99);
      expect(json['active'], true);
      expect(json['image_urls'], ['https://example.com/img.jpg']);
    });

    test('round-trip fromJson → toJson → fromJson produces equal fields', () {
      final json = product.toJson();
      final restored = Product.fromJson(json);
      expect(restored.id, product.id);
      expect(restored.name, product.name);
      expect(restored.price, product.price);
      expect(restored.imageUrls, product.imageUrls);
      expect(restored.active, product.active);
      expect(restored.createdAt, product.createdAt);
    });
  });
}
