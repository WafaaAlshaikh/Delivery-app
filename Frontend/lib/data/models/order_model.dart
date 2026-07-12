// lib/data/models/order_model.dart

import 'dart:ui';

class OrderModel {
  final String id;
  final String orderNumber;
  final String status;
  final double finalAmount;
  final String deliveryAddress;
  final String paymentMethod;
  final double totalAmount;
  final double deliveryFee;
  final String paymentStatus;
  final DateTime? orderTime;
  final String? storeId;
  final String? storeName;
  final String? driverId;
  final List<OrderItemModel> items;
  final BusinessModel? business;
  final CustomerModel? customer;
  final AddressModel? deliveryAddressDetail;
  final OrderStatusModel? statusDetail;
  final double? subtotal;
  final double? discount;
  final double? tax;
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
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.finalAmount,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.totalAmount = 0,
    this.deliveryFee = 0,
    this.paymentStatus = 'Pending',
    this.orderTime,
    this.storeId,
    this.storeName,
    this.driverId,
    this.items = const [],
    this.business,
    this.customer,
    this.deliveryAddressDetail,
    this.statusDetail,
    this.subtotal,
    this.discount,
    this.tax,
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
    if (json.containsKey('Business') ||
        json.containsKey('Customer') ||
        json.containsKey('OrderStatus')) {
      return OrderModel.fromLegacyJson(json);
    }

    return OrderModel.fromNewJson(json);
  }

  factory OrderModel.fromNewJson(Map<String, dynamic> json) {
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

    return OrderModel(
      id: json['id']?.toString() ?? json['order_id']?.toString() ?? '',
      orderNumber: json['order_number']?.toString() ??
          'ORD-${json['id'] ?? json['order_id']}',
      status: json['status']?.toString() ?? 'Pending',
      finalAmount: _toDouble(json['final_amount'] ?? json['total']),
      deliveryAddress: json['delivery_address']?.toString() ??
          json['address']?.toString() ??
          '',
      paymentMethod: json['payment_method']?.toString() ?? 'Cash',
      totalAmount: _toDouble(json['total_amount'] ?? json['subtotal'] ?? 0),
      deliveryFee: _toDouble(json['delivery_fee'] ?? 0),
      paymentStatus: json['payment_status']?.toString() ?? 'Pending',
      orderTime:
          json['order_time'] != null ? _toDateTime(json['order_time']) : null,
      storeId: json['store_id']?.toString(),
      storeName: json['store_name']?.toString(),
      driverId: json['driver_id']?.toString(),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((i) => OrderItemModel.fromJson(i))
              .toList()
          : [],
      createdAt: _toDateTime(
          json['created_at'] ?? json['order_time'] ?? DateTime.now()),
      business: null,
      customer: null,
      deliveryAddressDetail: null,
      statusDetail: null,
      subtotal: _toDouble(json['subtotal']),
      discount: _toDouble(json['discount']),
      tax: _toDouble(json['tax']),
      distance: null,
      distanceToCustomer: null,
      estimatedEarning: null,
      estimatedTime: null,
      isExpress: false,
      orderWeight: 0,
      requiresHeavyVehicle: false,
      vehicleMatch: 'perfect',
      totalDistance: null,
    );
  }

  factory OrderModel.fromLegacyJson(Map<String, dynamic> json) {
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

    bool _toBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      if (value is int) return value == 1;
      return false;
    }

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

    final legacyBusiness = json['Business'] != null
        ? BusinessModel.fromJson(json['Business'])
        : BusinessModel(businessId: 0, name: 'Unknown Store');

    final legacyCustomer = json['Customer'] != null
        ? CustomerModel.fromJson(json['Customer'])
        : CustomerModel(userId: 0, fullName: 'Unknown');

    final legacyAddress = json['UserAddress'] != null
        ? AddressModel.fromJson(json['UserAddress'])
        : AddressModel(addressId: 0, label: 'Home', street: '', city: '');

    final legacyStatus = json['OrderStatus'] != null
        ? OrderStatusModel.fromJson(json['OrderStatus'])
        : OrderStatusModel(
            statusId: 0, name: json['status']?.toString() ?? 'Pending');

    final orderId = _toInt(json['order_id']);
    final orderNumber = json['order_number']?.toString() ?? 'ORD-$orderId';
    final status = legacyStatus.name;
    final finalAmount = _toDouble(json['total']);
    final deliveryAddress = legacyAddress.fullAddress;
    final paymentMethod = 'Cash';

    return OrderModel(
      id: orderId.toString(),
      orderNumber: orderNumber,
      status: status,
      finalAmount: finalAmount,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      totalAmount: _toDouble(json['subtotal']),
      deliveryFee: _toDouble(json['delivery_fee']),
      paymentStatus: 'Paid',
      orderTime: _toDateTime(json['created_at']),
      storeId: legacyBusiness.businessId.toString(),
      storeName: legacyBusiness.name,
      driverId: null,
      items: (json['OrderItems'] as List? ?? [])
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
      business: legacyBusiness,
      customer: legacyCustomer,
      deliveryAddressDetail: legacyAddress,
      statusDetail: legacyStatus,
      subtotal: _toDouble(json['subtotal']),
      discount: _toDouble(json['discount']),
      tax: _toDouble(json['tax']),
      distance: _toDoubleNullable(json['distance']),
      distanceToCustomer: _toDoubleNullable(json['distance_to_customer']),
      estimatedEarning: _toDoubleNullable(json['estimated_earning']),
      estimatedTime: _toInt(json['estimated_time']),
      isExpress: _toBool(json['is_express']),
      orderWeight: _toDouble(json['order_weight']),
      requiresHeavyVehicle: _toBool(json['requires_heavy_vehicle']),
      vehicleMatch: json['vehicle_match']?.toString() ?? 'perfect',
      totalDistance: _toDoubleNullable(json['total_distance']),
      createdAt: _toDateTime(json['created_at']),
    );
  }

  String get customerName => customer?.fullName ?? '';

  String get customerPhone => customer?.phone ?? '';

  double get lat => deliveryAddressDetail?.latitude ?? 0;

  double get lng => deliveryAddressDetail?.longitude ?? 0;

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'status': status,
      'final_amount': finalAmount,
      'delivery_address': deliveryAddress,
      'payment_method': paymentMethod,
      'total_amount': totalAmount,
      'delivery_fee': deliveryFee,
      'payment_status': paymentStatus,
      'order_time': orderTime?.toIso8601String(),
      'store_id': storeId,
      'store_name': storeName,
      'driver_id': driverId,
      'items': items.map((i) => i.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class OrderItemModel {
  final String productId;
  final String name;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String? imageUrl;

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.imageUrl,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('Product')) {
      final product = json['Product'];
      return OrderItemModel(
        productId: product['product_id']?.toString() ?? '',
        name: product['name']?.toString() ?? 'Product',
        quantity: json['quantity'] ?? 0,
        unitPrice: (json['unit_price'] ?? 0).toDouble(),
        subtotal: (json['subtotal'] ?? 0).toDouble(),
        imageUrl: product['image_url']?.toString(),
      );
    }

    return OrderItemModel(
      productId: json['product_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      imageUrl: json['image_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'image_url': imageUrl,
    };
  }
}

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
