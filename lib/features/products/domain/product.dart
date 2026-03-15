class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrls,
    required this.active,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> imageUrls;
  final bool active;
  final DateTime createdAt;

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawImages = json['image_urls'];
    final images = rawImages is List
        ? rawImages.whereType<String>().where((url) => url.isNotEmpty).toList()
        : <String>[];

    return Product(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrls: images,
      active: json['active'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_urls': imageUrls,
      'active': active,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
