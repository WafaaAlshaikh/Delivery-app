// lib/data/models/product_model.dart

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String storeId; 
  final String imageUrl;
  final double price;
  final double averageRating;
  final int totalReviews;
  final bool inStock;
  final bool isActive;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.storeId,
    required this.imageUrl,
    required this.price,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.inStock = true,
    this.isActive = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      storeId: json['store_id']?.toString() ?? '',
      imageUrl: json['image_url'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      inStock: json['in_stock'] ?? true,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'store_id': storeId,
      'image_url': imageUrl,
      'price': price,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'in_stock': inStock,
      'is_active': isActive,
    };
  }
}
