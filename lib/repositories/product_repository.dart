import '../features/products/domain/product.dart';

abstract class ProductRepository {
  Future<List<Product>> fetchActiveProducts();
}
