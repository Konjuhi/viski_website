import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../repositories/cart_repository.dart';
import '../domain/cart_item.dart';

class SharedPreferencesCartRepository implements CartRepository {
  SharedPreferencesCartRepository(this._preferences);

  static const _cartStorageKey = 'swift_shop_cart_items';

  final SharedPreferences _preferences;

  @override
  Future<List<CartItem>> loadCart() async {
    final rawValue = _preferences.getString(_cartStorageKey);
    if (rawValue == null || rawValue.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(rawValue);
    if (decoded is! List) {
      return [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(CartItem.fromJson)
        .where((item) => item.productId.isNotEmpty && item.quantity > 0)
        .toList();
  }

  @override
  Future<void> saveCart(List<CartItem> items) {
    final rawValue = jsonEncode(items.map((item) => item.toJson()).toList());
    return _preferences.setString(_cartStorageKey, rawValue);
  }
}
