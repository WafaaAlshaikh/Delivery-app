// lib/data/models/offer_model.dart
import 'order_model.dart';

class OfferModel {
  final int offerId;
  final int orderId;
  final int driverId;
  final String status; 
  final OrderModel order;
  final int? remainingSeconds;
  final String offerType;
  final int priority;

  OfferModel({
    required this.offerId,
    required this.orderId,
    required this.driverId,
    required this.status,
    required this.order,
    this.remainingSeconds,
    this.offerType = 'smart',
    this.priority = 0,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    final orderData = json['Order'] ?? json['order'] ?? {};
    
    return OfferModel(
      offerId: json['offer_id'] ?? json['offerId'] ?? 0,
      orderId: json['order_id'] ?? json['orderId'] ?? 0,
      driverId: json['driver_id'] ?? json['driverId'] ?? 0,
      status: json['status'] ?? 'pending',
      order: OrderModel.fromJson(orderData),
      remainingSeconds: json['remainingSeconds'] ?? json['remaining'] ?? 15,
      offerType: json['offer_type'] ?? 'smart',
      priority: json['priority'] ?? 0,
    );
  }

  OfferModel copyWith({
    int? offerId,
    int? orderId,
    int? driverId,
    String? status,
    OrderModel? order,
    int? remainingSeconds,
    String? offerType,
    int? priority,
  }) {
    return OfferModel(
      offerId: offerId ?? this.offerId,
      orderId: orderId ?? this.orderId,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
      order: order ?? this.order,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      offerType: offerType ?? this.offerType,
      priority: priority ?? this.priority,
    );
  }
}