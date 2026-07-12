// lib/data/models/user_model.dart

class UserModel {
  final int userId;
  final String fullName;
  final String email;
  final String? phone;
  final bool isVerified;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final List<String> roles;
  final String? profileImage;
  final String role;
  final String? profilePicture;
  final String? businessType;
  final String status;
  final String? locationAddress;
  final String? city;
  final String? region;
  final DateTime updatedAt;

  UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phone,
    this.profileImage,
    this.profilePicture,
    required this.roles,
    required this.role,
    this.businessType,
    required this.status,
    required this.isVerified,
    required this.isActive,
    this.locationAddress,
    this.city,
    this.region,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
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

    final roleValue = json['role']?.toString() ?? 
                      (rolesList.isNotEmpty ? rolesList.first : 'Customer');

    final profileImageValue = json['profile_image'] ?? json['profileImage'];
    final profilePictureValue = json['profile_picture'] ?? json['profilePicture'];

    return UserModel(
      userId: json['user_id'] ?? json['userId'] ?? 0,
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone']?.toString(),
      profileImage: profileImageValue?.toString(),
      profilePicture: profilePictureValue?.toString(),
      roles: rolesList,
      role: roleValue,
      businessType: json['business_type']?.toString() ?? json['businessType']?.toString(),
      status: json['status']?.toString() ?? 'Pending',
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      locationAddress: json['location_address']?.toString() ?? json['locationAddress']?.toString(),
      city: json['city']?.toString(),
      region: json['region']?.toString(),
      lastLogin: json['last_login'] != null 
          ? DateTime.tryParse(json['last_login'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
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
      'profile_picture': profilePicture,
      'roles': roles,
      'role': role,
      'business_type': businessType,
      'status': status,
      'is_verified': isVerified,
      'is_active': isActive,
      'location_address': locationAddress,
      'city': city,
      'region': region,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String? get profilePictureOrImage => profilePicture ?? profileImage;
  
  bool get hasMultipleRoles => roles.length > 1;
  
  String get primaryRole => role;
  
  List<String> get allRoles => roles;

  bool hasRole(String roleName) {
    return roles.contains(roleName) || role == roleName;
  }

  bool get isAdmin => hasRole('Admin');
  
  bool get isMerchant => hasRole('Merchant');
  
  bool get isDriver => hasRole('Driver');
  
  bool get isCustomer => hasRole('Customer');
  
  bool get isBusinessOwner => isMerchant || hasRole('Restaurant') || hasRole('Pharmacy');

  bool get isPending => status == 'Pending';
  
  bool get isApproved => status == 'Approved' || status == 'Active';
  
  bool get isSuspended => status == 'Suspended';
  
  bool get isVerifiedAndActive => isVerified && isActive;
  
  String get displayName => fullName;
  
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  UserModel copyWith({
    int? userId,
    String? fullName,
    String? email,
    String? phone,
    String? profileImage,
    String? profilePicture,
    List<String>? roles,
    String? role,
    String? businessType,
    String? status,
    bool? isVerified,
    bool? isActive,
    String? locationAddress,
    String? city,
    String? region,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      profilePicture: profilePicture ?? this.profilePicture,
      roles: roles ?? this.roles,
      role: role ?? this.role,
      businessType: businessType ?? this.businessType,
      status: status ?? this.status,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      locationAddress: locationAddress ?? this.locationAddress,
      city: city ?? this.city,
      region: region ?? this.region,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserModel.fromLegacyJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone']?.toString(),
      profileImage: json['profileImage']?.toString(),
      profilePicture: json['profileImage']?.toString(),
      roles: json['roles'] != null 
          ? List<String>.from(json['roles']) 
          : [json['role']?.toString() ?? 'Customer'],
      role: json['role']?.toString() ?? 'Customer',
      businessType: json['businessType']?.toString(),
      status: json['status']?.toString() ?? 'Pending',
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      locationAddress: json['locationAddress']?.toString(),
      city: json['city']?.toString(),
      region: json['region']?.toString(),
      lastLogin: json['lastLogin'] != null 
          ? DateTime.tryParse(json['lastLogin'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toLegacyJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage ?? profilePicture,
      'roles': roles,
      'role': role,
      'businessType': businessType,
      'status': status,
      'isVerified': isVerified,
      'isActive': isActive,
      'locationAddress': locationAddress,
      'city': city,
      'region': region,
      'lastLogin': lastLogin?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

extension UserModelExtension on UserModel {
  String? get avatarUrl => profilePicture ?? profileImage;
  
  bool get hasMultipleRoles => roles.length > 1;
  
  String get mainRole => role;
  
  bool get isMerchantOrBusiness => isMerchant || businessType != null;
  
  bool get hasBusiness => businessType != null && businessType!.isNotEmpty;
  
  String get businessTypeArabic {
    switch (businessType) {
      case 'Restaurant':
        return 'مطعم';
      case 'Pharmacy':
        return 'صيدلية';
      case 'Furniture':
        return 'أثاث';
      case 'Supermarket':
        return 'سوبر ماركت';
      case 'Electronics':
        return 'إلكترونيات';
      case 'Clothing':
        return 'ملابس';
      case 'Other':
        return 'آخر';
      default:
        return businessType ?? 'غير محدد';
    }
  }
}