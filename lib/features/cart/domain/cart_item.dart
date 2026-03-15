class CartItem {
  const CartItem({required this.productId, required this.quantity});

  final String productId;
  final int quantity;

  CartItem copyWith({String? productId, int? quantity}) {
    return CartItem(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['product_id'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {'product_id': productId, 'quantity': quantity};
  }
}
