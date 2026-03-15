import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/product.dart';

class ProductSelectorList extends StatelessWidget {
  const ProductSelectorList({
    super.key,
    required this.products,
    required this.selectedProductId,
    required this.onProductSelected,
  });

  final List<Product> products;
  final String selectedProductId;
  final ValueChanged<Product> onProductSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 142,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final product = products[index];
          final isSelected = product.id == selectedProductId;
          final previewImage = product.imageUrls.isEmpty
              ? null
              : product.imageUrls.first;

          return SizedBox(
            width: 220,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => onProductSelected(product),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? Colors.black : theme.colorScheme.outlineVariant,
                    width: isSelected ? 1.6 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F1E8),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: previewImage == null
                          ? const Icon(Icons.inventory_2_outlined)
                          : Image.network(
                              previewImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return const Icon(Icons.broken_image_outlined);
                              },
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formatPrice(product.price),
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
