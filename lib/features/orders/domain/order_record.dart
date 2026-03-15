class OrderRecord {
  const OrderRecord({
    required this.id,
    required this.productId,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.quantity,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String productId;
  final String customerName;
  final String phone;
  final String address;
  final int quantity;
  final String status;
  final DateTime createdAt;

  factory OrderRecord.fromJson(Map<String, dynamic> json) {
    return OrderRecord(
      id: json['id'].toString(),
      productId: json['product_id'].toString(),
      customerName: json['customer_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      status: json['status'] as String? ?? 'pending_confirmation',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'customer_name': customerName,
      'phone': phone,
      'address': address,
      'quantity': quantity,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
