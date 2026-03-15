import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../repositories/cart_repository.dart';
import '../../data/shared_preferences_cart_repository.dart';
import '../../domain/cart_item.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return SharedPreferences.getInstance();
});

final cartRepositoryProvider = FutureProvider<CartRepository>((ref) async {
  final preferences = await ref.watch(sharedPreferencesProvider.future);
  return SharedPreferencesCartRepository(preferences);
});

final cartControllerProvider =
    AsyncNotifierProvider<CartController, List<CartItem>>(CartController.new);

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartControllerProvider);
  return cart.maybeWhen(
    data: (items) => items.fold(0, (sum, item) => sum + item.quantity),
    orElse: () => 0,
  );
});

class CartController extends AsyncNotifier<List<CartItem>> {
  @override
  Future<List<CartItem>> build() async {
    final repository = await ref.watch(cartRepositoryProvider.future);
    return repository.loadCart();
  }

  Future<void> addItem({
    required String productId,
    required int quantity,
  }) async {
    final current = _currentItems();
    final updated = <CartItem>[];
    var merged = false;

    for (final item in current) {
      if (item.productId == productId) {
        updated.add(item.copyWith(quantity: item.quantity + quantity));
        merged = true;
      } else {
        updated.add(item);
      }
    }

    if (!merged) {
      updated.add(CartItem(productId: productId, quantity: quantity));
    }

    await _persist(updated);
  }

  Future<void> increment(String productId) async {
    final updated = [
      for (final item in _currentItems())
        if (item.productId == productId)
          item.copyWith(quantity: item.quantity + 1)
        else
          item,
    ];
    await _persist(updated);
  }

  Future<void> decrement(String productId) async {
    final updated = <CartItem>[];
    for (final item in _currentItems()) {
      if (item.productId != productId) {
        updated.add(item);
        continue;
      }

      if (item.quantity > 1) {
        updated.add(item.copyWith(quantity: item.quantity - 1));
      }
    }

    await _persist(updated);
  }

  Future<void> remove(String productId) async {
    final updated = [
      for (final item in _currentItems())
        if (item.productId != productId) item,
    ];
    await _persist(updated);
  }

  Future<void> clear() async {
    await _persist([]);
  }

  List<CartItem> _currentItems() {
    return state.maybeWhen(data: (items) => items, orElse: () => const []);
  }

  Future<void> _persist(List<CartItem> items) async {
    state = AsyncData(items);
    final repository = await ref.read(cartRepositoryProvider.future);
    await repository.saveCart(items);
  }
}
