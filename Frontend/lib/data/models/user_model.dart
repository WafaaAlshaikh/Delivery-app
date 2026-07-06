// lib/data/models/user_model.dart
class UserModel {
  final int userId;
  final String fullName;
  final String email;
  final String? phone;
  final String? profileImage;
  final List<String> roles;  
  final bool isVerified;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phone,
    this.profileImage,
    required this.roles,
    required this.isVerified,
    required this.isActive,
    this.lastLogin,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<String> rolesList = [];
    if (json['roles'] != null) {
      if (json['roles'] is List) {
        rolesList = List<String>.from(json['roles']);
      } else if (json['roles'] is String) {
        rolesList = [json['roles']];
      }
    } else if (json['role'] != null) {
      rolesList = [json['role']];
    }

    return UserModel(
      userId: json['user_id'] ?? json['userId'] ?? 0,
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone']?.toString(),
      profileImage: json['profile_image'] ?? json['profileImage'],
      roles: rolesList,  
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login']) 
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'roles': roles,  
      'is_verified': isVerified,
      'is_active': isActive,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool hasRole(String role) {
    return roles.contains(role);
  }

  bool get isAdmin => roles.contains('Admin');
  
  bool get isMerchant => roles.contains('Merchant');
  
  bool get isDriver => roles.contains('Driver');
  
  bool get isCustomer => roles.contains('Customer');

  UserModel copyWith({
    int? userId,
    String? fullName,
    String? email,
    String? phone,
    String? profileImage,
    List<String>? roles,
    bool? isVerified,
    bool? isActive,
    DateTime? lastLogin,
    DateTime? createdAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      roles: roles ?? this.roles,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}