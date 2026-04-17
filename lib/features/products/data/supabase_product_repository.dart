import 'package:supabase/supabase.dart';

import '../../../repositories/product_repository.dart';
import '../domain/product.dart';

class SupabaseProductRepository implements ProductRepository {
  const SupabaseProductRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Product>> fetchActiveProducts() async {
    final response = await _client
        .from('products')
        .select()
        .eq('active', true)
        .order('created_at', ascending: false);

    final data = (response as List).cast<Map<String, dynamic>>();
    return data.map(Product.fromJson).toList();
  }
}
