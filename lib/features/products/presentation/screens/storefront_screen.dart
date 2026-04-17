import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../repositories/cart_repository.dart';
import '../../../../services/supabase_service.dart';
import '../../../../widgets/brand_header.dart';
import '../../../../widgets/feature_highlight_card.dart';
import '../../../cart/data/local_storage_cart_repository.dart';
import '../../../cart/domain/cart_item.dart';
import '../../../cart/presentation/widgets/cart_sheet.dart';
import '../../../orders/presentation/widgets/order_form_sheet.dart';
import '../../../reviews/data/supabase_review_repository.dart';
import '../../../reviews/domain/product_review.dart';
import '../../../reviews/presentation/widgets/product_reviews_section.dart';
import '../../../reviews/presentation/widgets/review_form_sheet.dart';
import '../../data/supabase_product_repository.dart';
import '../../domain/product.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/product_selector_list.dart';
import '../widgets/quantity_selector.dart';

enum _Modal { none, cart, order, review, success }

class StorefrontScreen extends StatefulComponent {
  const StorefrontScreen({super.key});

  @override
  State<StorefrontScreen> createState() => _StorefrontScreenState();
}

class _StorefrontScreenState extends State<StorefrontScreen> {
  static const _features = [
    (
      'Phone Confirmation',
      'When you place an order, the owner receives an SMS notification and will contact you to confirm it.',
    ),
    (
      'Local Bag Privacy',
      'Each visitor keeps a separate bag on their own browser or device without seeing anybody else\'s items.',
    ),
    (
      'Ready For Growth',
      'The app separates products, bag state, and checkout so categories and payments can be added later.',
    ),
  ];

  final _productRepo = SupabaseProductRepository(SupabaseService.client);
  final CartRepository _cartRepo = LocalStorageCartRepository();

  List<Product> _products = [];
  List<CartItem> _cart = [];
  List<ProductReview> _reviews = [];
  String? _selectedProductId;
  int _quantity = 1;
  bool _loading = true;
  String? _error;
  _Modal _modal = _Modal.none;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      final products = await _productRepo.fetchActiveProducts();
      final cart = await _cartRepo.loadCart();
      setState(() {
        _products = products;
        _cart = cart;
        _selectedProductId = products.isNotEmpty ? products.first.id : null;
        _loading = false;
      });
      if (_selectedProductId != null) await _loadReviews(_selectedProductId!);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadReviews(String productId) async {
    try {
      final repo = SupabaseReviewRepository(SupabaseService.client);
      final reviews = await repo.fetchApprovedReviews(productId);
      setState(() => _reviews = reviews);
    } catch (_) {
      setState(() => _reviews = []);
    }
  }

  Product? get _selectedProduct =>
      _products.where((p) => p.id == _selectedProductId).cast<Product?>().firstOrNull;

  int get _cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  Map<String, Product> get _productsById => {for (final p in _products) p.id: p};

  Future<void> _selectProduct(String id) async {
    setState(() {
      _selectedProductId = id;
      _quantity = 1;
      _reviews = [];
    });
    await _loadReviews(id);
  }

  Future<void> _addToCart() async {
    final product = _selectedProduct;
    if (product == null) return;
    final existing = _cart.indexWhere((i) => i.productId == product.id);
    final updated = List<CartItem>.from(_cart);
    if (existing >= 0) {
      updated[existing] =
          CartItem(productId: product.id, quantity: updated[existing].quantity + _quantity);
    } else {
      updated.add(CartItem(productId: product.id, quantity: _quantity));
    }
    await _cartRepo.saveCart(updated);
    setState(() {
      _cart = updated;
      _quantity = 1;
    });
  }

  Future<void> _updateCartItem(String productId, int delta) async {
    final updated = List<CartItem>.from(_cart);
    final i = updated.indexWhere((item) => item.productId == productId);
    if (i < 0) return;
    final newQty = updated[i].quantity + delta;
    if (newQty <= 0) {
      updated.removeAt(i);
    } else {
      updated[i] = CartItem(productId: productId, quantity: newQty);
    }
    await _cartRepo.saveCart(updated);
    setState(() => _cart = updated);
  }

  Future<void> _removeCartItem(String productId) async {
    final updated = _cart.where((i) => i.productId != productId).toList();
    await _cartRepo.saveCart(updated);
    setState(() => _cart = updated);
  }

  Future<void> _clearCart() async {
    await _cartRepo.saveCart([]);
    setState(() => _cart = []);
  }

  @override
  Component build(BuildContext context) {
    if (_loading) {
      return div([
        div([
          div([], classes: 'spinner'),
          p([Component.text('Loading products…')]),
        ], classes: 'loading-state'),
      ], classes: 'storefront');
    }

    if (_error != null) {
      return div([
        div([
          p([Component.text('Unable to load products')], classes: 'section-title'),
          p([Component.text(_error!)], classes: 'product-description'),
        ], classes: 'loading-state'),
      ], classes: 'storefront');
    }

    if (_products.isEmpty) {
      return div([
        div([
          p([Component.text('No products found')], classes: 'section-title'),
          p(
            [Component.text('Add rows to the products table and set active = true.')],
            classes: 'product-description',
          ),
        ], classes: 'loading-state'),
      ], classes: 'storefront');
    }

    final product = _selectedProduct;

    return div([
      BrandHeader(
        cartCount: _cartCount,
        onCartTap: () => setState(() => _modal = _Modal.cart),
      ),
      div([
        if (product != null)
          div([
            ProductImageGallery(imageUrls: product.imageUrls),
            _buildProductInfo(product),
          ], classes: 'storefront-hero'),
        if (_products.length > 1)
          ProductSelectorList(
            products: _products,
            selectedProductId: _selectedProductId,
            onSelect: _selectProduct,
          ),
        section([
          div(
            _features
                .map((f) => FeatureHighlightCard(title: f.$1, description: f.$2))
                .toList(),
            classes: 'feature-cards-grid',
          ),
        ], classes: 'feature-cards-section'),
        if (product != null)
          ProductReviewsSection(
            product: product,
            reviews: _reviews,
            onWriteReview: () => setState(() => _modal = _Modal.review),
          ),
      ], classes: 'storefront'),
      if (_modal == _Modal.cart) _buildOverlay(CartSheet(
        cart: _cart,
        productsById: _productsById,
        onIncrement: (id) => _updateCartItem(id, 1),
        onDecrement: (id) => _updateCartItem(id, -1),
        onRemove: _removeCartItem,
        onCheckout: () => setState(() => _modal = _Modal.order),
        onClose: () => setState(() => _modal = _Modal.none),
      )),
      if (_modal == _Modal.order) _buildOverlay(OrderFormSheet(
        cart: _cart,
        productsById: _productsById,
        onClose: () => setState(() => _modal = _Modal.none),
        onSuccess: () async {
          await _clearCart();
          setState(() => _modal = _Modal.success);
        },
      )),
      if (_modal == _Modal.review && product != null)
        _buildOverlay(ReviewFormSheet(
          product: product,
          onClose: () => setState(() => _modal = _Modal.none),
          onSuccess: () async {
            setState(() => _modal = _Modal.none);
            await _loadReviews(product.id);
          },
        )),
      if (_modal == _Modal.success) _buildSuccessModal(),
    ], classes: 'app');
  }

  Component _buildProductInfo(Product product) {
    final avg = _reviews.isNotEmpty
        ? (_reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length)
            .toStringAsFixed(1)
        : null;

    return div([
      div([
        span([Component.text('★')], classes: 'star-filled'),
        span([
          Component.text(avg != null
              ? '$avg (${_reviews.length} review${_reviews.length == 1 ? '' : 's'})'
              : 'No reviews yet'),
        ]),
      ], classes: 'stars', styles: Styles(raw: {'margin-bottom': '12px'})),
      p([Component.text(product.name)], classes: 'product-name'),
      p([Component.text(formatPrice(product.price))], classes: 'product-price'),
      p([Component.text(product.description)], classes: 'product-description'),
      QuantitySelector(
        quantity: _quantity,
        onIncrement: () => setState(() => _quantity++),
        onDecrement: () =>
            setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1),
      ),
      div([
        button(
          [Component.text('Add to Bag')],
          classes: 'btn-primary',
          events: {
            'click': (_) async {
              await _addToCart();
              setState(() => _modal = _Modal.cart);
            },
          },
        ),
        button(
          [Component.text('View Bag')],
          classes: 'btn-secondary',
          events: {'click': (_) => setState(() => _modal = _Modal.cart)},
        ),
        button(
          [Component.text('Write a review')],
          classes: 'btn-ghost',
          events: {'click': (_) => setState(() => _modal = _Modal.review)},
        ),
      ], classes: 'action-buttons'),
    ], classes: 'product-info');
  }

  Component _buildOverlay(Component child) {
    return div(
      [child],
      classes: 'modal-overlay',
      events: {'click': (_) => setState(() => _modal = _Modal.none)},
    );
  }

  Component _buildSuccessModal() {
    return div(
      [
        div([
          p([Component.text('🎉')], classes: 'success-icon'),
          p([Component.text('Order request sent!')], classes: 'success-title'),
          p(
            [Component.text('Your order was submitted. The owner will contact you to confirm.')],
            classes: 'success-subtitle',
          ),
          button(
            [Component.text('Close')],
            classes: 'btn-primary',
            events: {'click': (_) => setState(() => _modal = _Modal.none)},
          ),
        ], classes: 'success-state modal-shell', events: {'click': (_) {}}),
      ],
      classes: 'modal-overlay',
      events: {'click': (_) => setState(() => _modal = _Modal.none)},
    );
  }
}
