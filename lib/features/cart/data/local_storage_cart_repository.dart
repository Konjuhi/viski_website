import 'dart:convert';
import 'dart:html' as html;

import '../../../repositories/cart_repository.dart';
import '../domain/cart_item.dart';

class LocalStorageCartRepository implements CartRepository {
  static const _key = 'swift_shop_cart_items';

  @override
  Future<List<CartItem>> loadCart() async {
    final raw = html.window.localStorage[_key];
    if (raw == null || raw.isEmpty) return [];
    final data = jsonDecode(raw) as List;
    return data.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveCart(List<CartItem> items) async {
    html.window.localStorage[_key] =
        jsonEncode(items.map((e) => e.toJson()).toList());
  }
}
