// lib/data/models/store_model.dart

class StoreModel {
  final String id;
  final String name;
  final String categoryId; 
  final String imageUrl;
  final double averageRating;
  final int totalReviews;
  final bool isActive;
  final bool isApproved;
  final String deliveryTime; 
  final String deliveryFee; 
  final String approvalStatus; 
  final String? rejectionReason;
  final String address;
  final String phone;
  final String email;
  final String description;
  final String? openingTime;
  final String? closingTime;

  StoreModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.imageUrl,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.isActive = true,
    this.isApproved = false,
    this.deliveryTime = '',
    this.deliveryFee = '',
    this.approvalStatus = 'Pending',
    this.rejectionReason,
    this.address = '',
    this.phone = '',
    this.email = '',
    this.description = '',
    this.openingTime,
    this.closingTime,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      imageUrl: json['image_url'] ?? '',
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      isActive: json['is_active'] ?? true,
      isApproved: json['is_approved'] ?? false,
      deliveryTime: json['delivery_time'] ?? '',
      deliveryFee: json['delivery_fee'] ?? '',
      approvalStatus: json['approval_status'] ?? 'Pending',
      rejectionReason: json['rejection_reason'],
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      description: json['description'] ?? '',
      openingTime: json['opening_time']?.toString(),
      closingTime: json['closing_time']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
      'image_url': imageUrl,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'is_active': isActive,
      'is_approved': isApproved,
      'delivery_time': deliveryTime,
      'delivery_fee': deliveryFee,
      'approval_status': approvalStatus,
      'rejection_reason': rejectionReason,
      'address': address,
      'phone': phone,
      'email': email,
      'description': description,
      'opening_time': openingTime,
      'closing_time': closingTime,
    };
  }
}
