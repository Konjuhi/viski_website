import 'package:flutter/material.dart';

import '../../domain/product.dart';

class ProductImageGallery extends StatefulWidget {
  const ProductImageGallery({
    super.key,
    required this.product,
    required this.height,
  });

  final Product product;
  final double height;

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  final CarouselController _carouselController = CarouselController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = widget.product.imageUrls;

    if (images.isEmpty) {
      return _GalleryShell(
        height: widget.height,
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: 56,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemExtent = constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GalleryShell(
              height: widget.height,
              child: NotificationListener<ScrollEndNotification>(
                onNotification: (_) {
                  if (!_carouselController.hasClients) {
                    return false;
                  }

                  final rawIndex = (_carouselController.offset / itemExtent)
                      .round();
                  final clampedIndex = rawIndex.clamp(0, images.length - 1);
                  if (clampedIndex != _currentIndex) {
                    setState(() => _currentIndex = clampedIndex);
                  }
                  return false;
                },
                child: CarouselView(
                  controller: _carouselController,
                  itemExtent: itemExtent,
                  itemSnapping: true,
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  children: [
                    for (final imageUrl in images)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: ColoredBox(
                            color: const Color(0xFFF5F1E8),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) {
                                  return child;
                                }
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (_, __, ___) {
                                return Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 48,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var index = 0; index < images.length; index++)
                  GestureDetector(
                    onTap: () async {
                      setState(() => _currentIndex = index);
                      await _carouselController.animateToItem(index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 72,
                      height: 72,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: index == _currentIndex
                              ? Colors.black
                              : theme.colorScheme.outlineVariant,
                          width: index == _currentIndex ? 1.6 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return ColoredBox(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _GalleryShell extends StatelessWidget {
  const _GalleryShell({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: child,
    );
  }
}
