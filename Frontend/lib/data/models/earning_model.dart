// lib/data/models/earning_model.dart

import 'dart:ui';

import 'package:flutter/material.dart';

class EarningModel {
  final String id;
  final String orderId;
  final String orderNumber;
  final double amount;
  final double deliveryFee;
  final double tips;
  final double bonus;
  final DateTime date;
  final String status;
  final String customerName;
  final String deliveryAddress;
  final double distance;
  final int duration;
  final double rating;
  final String? notes;

  EarningModel({
    required this.id,
    required this.orderId,
    this.orderNumber = '',
    required this.amount,
    required this.deliveryFee,
    this.tips = 0,
    this.bonus = 0,
    required this.date,
    required this.status,
    required this.customerName,
    required this.deliveryAddress,
    required this.distance,
    required this.duration,
    required this.rating,
    this.notes,
  });

  double get total => amount + deliveryFee + tips + bonus;

  String get statusText {
    switch (status) {
      case 'completed':
        return '✅ Completed';
      case 'pending':
        return '⏳ Pending';
      case 'cancelled':
        return '❌ Cancelled';
      case 'refunded':
        return '🔄 Refunded';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  factory EarningModel.fromJson(Map<String, dynamic> json) {
    final earningData = json['Earning'] ?? json;
    
    return EarningModel(
      id: (earningData['earning_id'] ?? earningData['id']).toString(),
      orderId: (earningData['order_id'] ?? '').toString(),
      orderNumber: earningData['Order']?['order_number']?.toString() ?? 
                   earningData['order_number']?.toString() ?? 
                   'ORD-${earningData['order_id']}',
      amount: _parseDouble(earningData['amount']),
      deliveryFee: _parseDouble(earningData['delivery_fee']),
      tips: _parseDouble(earningData['tips']),
      bonus: _parseDouble(earningData['bonus']),
      date: _parseDate(earningData['created_at'] ?? earningData['date']),
      status: earningData['status']?.toString() ?? 'pending',
      customerName: earningData['customer_name']?.toString() ?? 'Unknown',
      deliveryAddress: earningData['delivery_address']?.toString() ?? '',
      distance: _parseDouble(earningData['distance']),
      duration: _parseInt(earningData['duration']),
      rating: _parseDouble(earningData['rating']),
      notes: earningData['notes']?.toString(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _parseDate(dynamic value) {
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_id': orderId,
    'order_number': orderNumber,
    'amount': amount,
    'delivery_fee': deliveryFee,
    'tips': tips,
    'bonus': bonus,
    'date': date.toIso8601String(),
    'status': status,
    'customer_name': customerName,
    'delivery_address': deliveryAddress,
    'distance': distance,
    'duration': duration,
    'rating': rating,
    'notes': notes,
  };
}

class EarningsSummary {
  final double totalEarnings;
  final double todayEarnings;
  final double weeklyEarnings;
  final double monthlyEarnings;
  final int totalDeliveries;
  final int todayDeliveries;
  final double averageRating;
  final double averagePerDay;
  final double predictedEarnings;

  EarningsSummary({
    required this.totalEarnings,
    required this.todayEarnings,
    required this.weeklyEarnings,
    required this.monthlyEarnings,
    required this.totalDeliveries,
    required this.todayDeliveries,
    required this.averageRating,
    required this.averagePerDay,
    required this.predictedEarnings,
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      totalEarnings: _parseDouble(json['total_earnings']),
      todayEarnings: _parseDouble(json['today_earnings']),
      weeklyEarnings: _parseDouble(json['weekly_earnings']),
      monthlyEarnings: _parseDouble(json['monthly_earnings']),
      totalDeliveries: json['total_deliveries'] ?? 0,
      todayDeliveries: json['today_deliveries'] ?? 0,
      averageRating: _parseDouble(json['average_rating']),
      averagePerDay: _parseDouble(json['average_per_day']),
      predictedEarnings: _parseDouble(json['predicted_earnings']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class EarningsChartData {
  final List<DailyEarning> daily;
  final List<WeeklyEarning> weekly;
  final List<MonthlyEarning> monthly;

  EarningsChartData({
    required this.daily,
    required this.weekly,
    required this.monthly,
  });

  factory EarningsChartData.fromJson(Map<String, dynamic> json) {
    return EarningsChartData(
      daily: (json['daily'] as List?)
          ?.map((e) => DailyEarning.fromJson(e))
          .toList() ?? [],
      weekly: (json['weekly'] as List?)
          ?.map((e) => WeeklyEarning.fromJson(e))
          .toList() ?? [],
      monthly: (json['monthly'] as List?)
          ?.map((e) => MonthlyEarning.fromJson(e))
          .toList() ?? [],
    );
  }
}

class DailyEarning {
  final DateTime date;
  final double amount;
  final int deliveries;
  final double averageRating;

  DailyEarning({
    required this.date,
    required this.amount,
    required this.deliveries,
    required this.averageRating,
  });

  factory DailyEarning.fromJson(Map<String, dynamic> json) {
    return DailyEarning(
      date: json['date'] != null 
          ? DateTime.tryParse(json['date']) ?? DateTime.now()
          : DateTime.now(),
      amount: _parseDouble(json['amount']),
      deliveries: json['deliveries'] ?? 0,
      averageRating: _parseDouble(json['average_rating']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class WeeklyEarning {
  final String week;
  final double amount;
  final int deliveries;

  WeeklyEarning({
    required this.week,
    required this.amount,
    required this.deliveries,
  });

  factory WeeklyEarning.fromJson(Map<String, dynamic> json) {
    return WeeklyEarning(
      week: json['week']?.toString() ?? '',
      amount: _parseDouble(json['amount']),
      deliveries: json['deliveries'] ?? 0,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class MonthlyEarning {
  final String month;
  final double amount;
  final int deliveries;

  MonthlyEarning({
    required this.month,
    required this.amount,
    required this.deliveries,
  });

  factory MonthlyEarning.fromJson(Map<String, dynamic> json) {
    return MonthlyEarning(
      month: json['month']?.toString() ?? '',
      amount: _parseDouble(json['amount']),
      deliveries: json['deliveries'] ?? 0,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}