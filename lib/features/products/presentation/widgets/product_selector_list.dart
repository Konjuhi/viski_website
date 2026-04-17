import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/product.dart';

class ProductSelectorList extends StatelessComponent {
  const ProductSelectorList({
    super.key,
    required this.products,
    required this.selectedProductId,
    required this.onSelect,
  });

  final List<Product> products;
  final String? selectedProductId;
  final void Function(String) onSelect;

  @override
  Component build(BuildContext context) {
    return section([
      h2([Component.text('More Products')], classes: 'section-title'),
      div(
        products.map(_productCard).toList(),
        classes: 'product-selector-list',
      ),
    ], classes: 'product-selector-section');
  }

  Component _productCard(Product product) {
    final isSelected = product.id == selectedProductId;
    final imageUrl =
        product.imageUrls.isNotEmpty ? product.imageUrls.first : '';

    return div(
      [
        img(src: imageUrl, alt: product.name),
        div([
          p([Component.text(product.name)], classes: 'product-selector-name'),
          p([Component.text(formatPrice(product.price))], classes: 'product-selector-price'),
        ], classes: 'product-selector-info'),
      ],
      classes: 'product-selector-card${isSelected ? ' selected' : ''}',
      events: {'click': (_) => onSelect(product.id)},
    );
  }
}
