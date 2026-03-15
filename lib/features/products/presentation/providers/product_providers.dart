import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../repositories/product_repository.dart';
import '../../../../services/supabase_service.dart';
import '../../data/supabase_product_repository.dart';
import '../../domain/product.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseProductRepository(client);
});

final activeProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.fetchActiveProducts();
});

final selectedProductIdProvider =
    NotifierProvider<SelectedProductIdNotifier, String?>(
      SelectedProductIdNotifier.new,
    );

final productQuantityProvider = NotifierProvider<ProductQuantityNotifier, int>(
  ProductQuantityNotifier.new,
);

final selectedProductProvider = Provider<Product?>((ref) {
  return ref
      .watch(activeProductsProvider)
      .maybeWhen(
        data: (products) {
          if (products.isEmpty) {
            return null;
          }

          final selectedId = ref.watch(selectedProductIdProvider);
          if (selectedId == null) {
            return products.first;
          }

          for (final product in products) {
            if (product.id == selectedId) {
              return product;
            }
          }

          return products.first;
        },
        orElse: () => null,
      );
});

class SelectedProductIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? productId) {
    state = productId;
  }
}

class ProductQuantityNotifier extends Notifier<int> {
  @override
  int build() => 1;

  void increment() {
    state = state + 1;
  }

  void decrement() {
    state = state > 1 ? state - 1 : 1;
  }

  void reset() {
    state = 1;
  }
}
