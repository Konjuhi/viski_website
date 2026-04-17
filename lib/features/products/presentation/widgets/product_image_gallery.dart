import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

class ProductImageGallery extends StatefulComponent {
  const ProductImageGallery({super.key, required this.imageUrls});

  final List<String> imageUrls;

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  int _currentIndex = 0;

  @override
  void didUpdateComponent(ProductImageGallery oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.imageUrls != component.imageUrls) {
      setState(() => _currentIndex = 0);
    }
  }

  @override
  Component build(BuildContext context) {
    final urls = component.imageUrls;
    final mainUrl =
        urls.isNotEmpty ? urls[_currentIndex.clamp(0, urls.length - 1)] : '';

    return div([
      div([
        if (mainUrl.isNotEmpty) img(src: mainUrl, alt: 'Product image'),
      ], classes: 'gallery-main'),
      if (urls.length > 1)
        div(
          urls.asMap().entries.map((e) {
            final i = e.key;
            final url = e.value;
            return div(
              [img(src: url, alt: 'Thumbnail ${i + 1}')],
              classes: 'gallery-thumb${i == _currentIndex ? ' active' : ''}',
              events: {'click': (_) => setState(() => _currentIndex = i)},
            );
          }).toList(),
          classes: 'gallery-thumbs',
        ),
    ], classes: 'gallery');
  }
}
