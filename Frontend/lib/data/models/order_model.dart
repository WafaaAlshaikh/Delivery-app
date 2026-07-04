// frontend/lib/data/models/order_model.dart

import 'dart:ui';

class OrderModel {
  final int orderId;
  final String? orderNumber;
  final BusinessModel business;
  final CustomerModel customer;
  final AddressModel deliveryAddress;
  final OrderStatusModel status;
  final List<OrderItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double tax;
  final double total;
  final double? distance;
  final double? distanceToCustomer;
  final double? estimatedEarning;
  final int? estimatedTime;
  final bool isExpress;
  final double orderWeight;
  final bool requiresHeavyVehicle;
  final String vehicleMatch;
  final double? totalDistance;
  final DateTime createdAt;

  OrderModel({
    required this.orderId,
    this.orderNumber,
    required this.business,
    required this.customer,
    required this.deliveryAddress,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.tax,
    required this.total,
    this.distance,
    this.distanceToCustomer,
    this.estimatedEarning,
    this.estimatedTime,
    this.isExpress = false,
    this.orderWeight = 0,
    this.requiresHeavyVehicle = false,
    this.vehicleMatch = 'perfect',
    this.totalDistance,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // ✅ دالة مساعدة لتحويل آمن إلى double
    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
        return double.tryParse(cleaned) ?? 0.0;
      }
      return 0.0;
    }

    // ✅ دالة مساعدة لتحويل آمن إلى int
    int _toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
        return int.tryParse(cleaned) ?? 0;
      }
      return 0;
    }

    // ✅ دالة مساعدة لتحويل آمن إلى bool
    bool _toBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      if (value is int) return value == 1;
      return false;
    }

    // ✅ دالة مساعدة لتحويل آمن إلى double? (nullable)
    double? _toDoubleNullable(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
        return double.tryParse(cleaned);
      }
      return null;
    }

    // ✅ دالة مساعدة لتحويل آمن إلى DateTime
    DateTime _toDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    // ✅ قراءة الحقول بأمان
    final isExpress = _toBool(json['is_express']);
    final orderWeight = _toDouble(json['order_weight']);
    final requiresHeavyVehicle = _toBool(json['requires_heavy_vehicle']);
    final vehicleMatch = json['vehicle_match']?.toString() ?? 'perfect';
    
    return OrderModel(
      orderId: _toInt(json['order_id']),
      orderNumber: json['order_number']?.toString() ?? 'ORD-${json['order_id']}',
      business: BusinessModel.fromJson(json['Business'] ?? {}),
      customer: CustomerModel.fromJson(json['Customer'] ?? {}),
      deliveryAddress: AddressModel.fromJson(json['UserAddress'] ?? {}),
      status: OrderStatusModel.fromJson(json['OrderStatus'] ?? {}),
      items: (json['OrderItems'] as List? ?? [])
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
      subtotal: _toDouble(json['subtotal']),
      deliveryFee: _toDouble(json['delivery_fee']),
      discount: _toDouble(json['discount']),
      tax: _toDouble(json['tax']),
      total: _toDouble(json['total']),
      distance: _toDoubleNullable(json['distance']),
      distanceToCustomer: _toDoubleNullable(json['distance_to_customer']),
      estimatedEarning: _toDoubleNullable(json['estimated_earning']),
      estimatedTime: _toInt(json['estimated_time']),
      isExpress: isExpress,
      orderWeight: orderWeight,
      requiresHeavyVehicle: requiresHeavyVehicle,
      vehicleMatch: vehicleMatch,
      totalDistance: _toDoubleNullable(json['total_distance']),
      createdAt: _toDateTime(json['created_at']),
    );
  }

  // ✅ Getter لون حالة المركبة
  Color get vehicleMatchColor {
    switch (vehicleMatch) {
      case 'perfect':
        return const Color(0xFF4CAF50);
      case 'medium':
        return const Color(0xFFFF9800);
      case 'poor':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  // ✅ Getter نص حالة المركبة
  String get vehicleMatchText {
    switch (vehicleMatch) {
      case 'perfect':
        return 'Perfect Match';
      case 'medium':
        return 'Acceptable';
      case 'poor':
        return 'Not Recommended';
      default:
        return 'Unknown';
    }
  }
}

// ============================================
// 📌 BusinessModel
// ============================================

class BusinessModel {
  final int businessId;
  final String name;
  final String? logo;
  final String? phone;
  final double? rating;
  final double? latitude;
  final double? longitude;

  BusinessModel({
    required this.businessId,
    required this.name,
    this.logo,
    this.phone,
    this.rating,
    this.latitude,
    this.longitude,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    double? _toDoubleNullable(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
        return double.tryParse(cleaned);
      }
      return null;
    }

    return BusinessModel(
      businessId: json['business_id'] ?? 0,
      name: json['name']?.toString() ?? 'Unknown Store',
      logo: json['logo']?.toString(),
      phone: json['phone']?.toString(),
      rating: _toDoubleNullable(json['rating']),
      latitude: _toDoubleNullable(json['latitude']),
      longitude: _toDoubleNullable(json['longitude']),
    );
  }
}

// ============================================
// 📌 CustomerModel
// ============================================

class CustomerModel {
  final int userId;
  final String fullName;
  final String? phone;

  CustomerModel({
    required this.userId,
    required this.fullName,
    this.phone,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      userId: json['user_id'] ?? 0,
      fullName: json['full_name']?.toString() ?? 'Unknown',
      phone: json['phone']?.toString(),
    );
  }
}

// ============================================
// 📌 AddressModel
// ============================================

class AddressModel {
  final int addressId;
  final String label;
  final String street;
  final String city;
  final String? building;
  final double? latitude;
  final double? longitude;

  AddressModel({
    required this.addressId,
    required this.label,
    required this.street,
    required this.city,
    this.building,
    this.latitude,
    this.longitude,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    double? _toDoubleNullable(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
        return double.tryParse(cleaned);
      }
      return null;
    }

    return AddressModel(
      addressId: json['address_id'] ?? 0,
      label: json['label']?.toString() ?? 'Home',
      street: json['street']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      building: json['building']?.toString(),
      latitude: _toDoubleNullable(json['latitude']),
      longitude: _toDoubleNullable(json['longitude']),
    );
  }

  String get fullAddress {
    String address = '$street, $city';
    if (building != null && building!.isNotEmpty) {
      address = '$building, $address';
    }
    return address;
  }
}

// ============================================
// 📌 OrderStatusModel
// ============================================

class OrderStatusModel {
  final int statusId;
  final String name;
  final String? color;

  OrderStatusModel({
    required this.statusId,
    required this.name,
    this.color,
  });

  factory OrderStatusModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusModel(
      statusId: json['status_id'] ?? 0,
      name: json['name']?.toString() ?? 'Unknown',
      color: json['color']?.toString(),
    );
  }
}

// ============================================
// 📌 OrderItemModel
// ============================================

class OrderItemModel {
  final int itemId;
  final int productId;
  final String productName;
  final String? imageUrl;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  OrderItemModel({
    required this.itemId,
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
        return double.tryParse(cleaned) ?? 0.0;
      }
      return 0.0;
    }

    int _toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
        return int.tryParse(cleaned) ?? 0;
      }
      return 0;
    }

    final product = json['Product'] ?? {};
    return OrderItemModel(
      itemId: _toInt(json['item_id']),
      productId: _toInt(product['product_id']),
      productName: product['name']?.toString() ?? 'Product',
      imageUrl: product['image_url']?.toString(),
      quantity: _toInt(json['quantity']),
      unitPrice: _toDouble(json['unit_price']),
      subtotal: _toDouble(json['subtotal']),
    );
  }
}