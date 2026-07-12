// lib/data/models/admin_models.dart

class AdminDashboardStats {
  final int totalUsers;
  final int totalStores;
  final int totalOrders;
  final double revenue;
  final List<AdminOrdersByStatus> ordersByStatus;

  AdminDashboardStats({
    required this.totalUsers,
    required this.totalStores,
    required this.totalOrders,
    required this.revenue,
    required this.ordersByStatus,
  });

  factory AdminDashboardStats.empty() => AdminDashboardStats(
        totalUsers: 0,
        totalStores: 0,
        totalOrders: 0,
        revenue: 0,
        ordersByStatus: const [],
      );

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] ?? {};
    return AdminDashboardStats(
      totalUsers: stats['total_users'] ?? 0,
      totalStores: stats['total_stores'] ?? 0,
      totalOrders: stats['total_orders'] ?? 0,
      revenue: (stats['revenue'] ?? 0).toDouble(),
      ordersByStatus: (json['orders_by_status'] as List? ?? [])
          .map((o) => AdminOrdersByStatus.fromJson(o))
          .toList(),
    );
  }
}

class AdminOrdersByStatus {
  final String status;
  final int count;

  AdminOrdersByStatus({required this.status, required this.count});

  factory AdminOrdersByStatus.fromJson(Map<String, dynamic> json) {
    return AdminOrdersByStatus(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class AdminStoreModel {
  final String id;
  final String name;
  final String? category;
  final String address;
  final String imageUrl;
  final String approvalStatus;

  AdminStoreModel({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.imageUrl,
    required this.approvalStatus,
  });

  factory AdminStoreModel.fromJson(Map<String, dynamic> json) {
    return AdminStoreModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      category: json['category'],
      address: json['address'] ?? '',
      imageUrl: json['image_url'] ?? '',
      approvalStatus: json['approval_status'] ?? 'Pending',
    );
  }
}

class AdminUserModel {
  final String id;
  final String fullName;
  final String email;
  final String role;

  AdminUserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

class AdminCategoryModel {
  final String id;
  final String name;
  final String icon;
  final int storeCount;
  final int productCount;

  AdminCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.storeCount,
    required this.productCount,
  });

  factory AdminCategoryModel.fromJson(Map<String, dynamic> json) {
    return AdminCategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      storeCount: json['store_count'] ?? 0,
      productCount: json['product_count'] ?? 0,
    );
  }
}
