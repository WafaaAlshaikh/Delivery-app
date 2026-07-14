// lib/data/models/scheduled_order_model.dart

import 'package:flutter/material.dart';
import 'order_model.dart';

enum ScheduleStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
}

extension ScheduleStatusExtension on ScheduleStatus {
  String get label {
    switch (this) {
      case ScheduleStatus.pending:
        return 'قيد الانتظار';
      case ScheduleStatus.confirmed:
        return 'مؤكد';
      case ScheduleStatus.inProgress:
        return 'قيد التنفيذ';
      case ScheduleStatus.completed:
        return 'مكتمل';
      case ScheduleStatus.cancelled:
        return 'ملغي';
    }
  }

  Color get color {
    switch (this) {
      case ScheduleStatus.pending:
        return Colors.orange;
      case ScheduleStatus.confirmed:
        return Colors.blue;
      case ScheduleStatus.inProgress:
        return Colors.purple;
      case ScheduleStatus.completed:
        return Colors.green;
      case ScheduleStatus.cancelled:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case ScheduleStatus.pending:
        return Icons.hourglass_top;
      case ScheduleStatus.confirmed:
        return Icons.check_circle;
      case ScheduleStatus.inProgress:
        return Icons.play_circle;
      case ScheduleStatus.completed:
        return Icons.check_circle_outline;
      case ScheduleStatus.cancelled:
        return Icons.cancel;
    }
  }
}

class ScheduledOrder {
  final String id;
  final String orderId;
  final String driverId;
  final DateTime scheduledTime;
  final int? estimatedDuration;
  final ScheduleStatus status;
  final int priority;
  final int? routeOrder;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime? aiSuggestedTime;
  final Map<String, dynamic>? routeOptimized;
  final OrderModel? order;

  ScheduledOrder({
    required this.id,
    required this.orderId,
    required this.driverId,
    required this.scheduledTime,
    this.estimatedDuration,
    required this.status,
    this.priority = 0,
    this.routeOrder,
    this.confirmedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.aiSuggestedTime,
    this.routeOptimized,
    this.order,
  });

  factory ScheduledOrder.fromJson(Map<String, dynamic> json) {
    return ScheduledOrder(
      id: json['scheduled_id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      driverId: json['driver_id']?.toString() ?? '',
      scheduledTime: DateTime.tryParse(json['scheduled_time'] ?? '') ?? DateTime.now(),
      estimatedDuration: json['estimated_duration'],
      status: _parseStatus(json['status']),
      priority: json['priority'] ?? 0,
      routeOrder: json['route_order'],
      confirmedAt: DateTime.tryParse(json['confirmed_at'] ?? ''),
      cancelledAt: DateTime.tryParse(json['cancelled_at'] ?? ''),
      cancellationReason: json['cancellation_reason'],
      aiSuggestedTime: DateTime.tryParse(json['ai_suggested_time'] ?? ''),
      routeOptimized: json['route_optimized'],
      order: json['Order'] != null ? OrderModel.fromJson(json['Order']) : null,
    );
  }

  static ScheduleStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending': return ScheduleStatus.pending;
      case 'confirmed': return ScheduleStatus.confirmed;
      case 'in_progress': return ScheduleStatus.inProgress;
      case 'completed': return ScheduleStatus.completed;
      case 'cancelled': return ScheduleStatus.cancelled;
      default: return ScheduleStatus.pending;
    }
  }

  Map<String, dynamic> toJson() => {
    'scheduled_id': id,
    'order_id': orderId,
    'driver_id': driverId,
    'scheduled_time': scheduledTime.toIso8601String(),
    'estimated_duration': estimatedDuration,
    'status': status.toString().split('.').last,
    'priority': priority,
    'route_order': routeOrder,
    'confirmed_at': confirmedAt?.toIso8601String(),
    'cancelled_at': cancelledAt?.toIso8601String(),
    'cancellation_reason': cancellationReason,
    'ai_suggested_time': aiSuggestedTime?.toIso8601String(),
    'route_optimized': routeOptimized,
  };

  String get timeDisplay {
    final hour = scheduledTime.hour.toString().padLeft(2, '0');
    final minute = scheduledTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get dateDisplay {
    final now = DateTime.now();
    final diff = scheduledTime.difference(now);

    if (diff.inDays == 0) {
      return 'اليوم';
    } else if (diff.inDays == 1) {
      return 'غداً';
    } else if (diff.inDays < 7) {
      return 'بعد ${diff.inDays} أيام';
    } else {
      return '${scheduledTime.day}/${scheduledTime.month}/${scheduledTime.year}';
    }
  }

  bool get isToday {
    final now = DateTime.now();
    return scheduledTime.day == now.day &&
           scheduledTime.month == now.month &&
           scheduledTime.year == now.year;
  }
}

class RouteOptimization {
  final List<OrderModel> route;
  final double totalDistance;
  final int totalTime;
  final double estimatedEarnings;

  RouteOptimization({
    required this.route,
    required this.totalDistance,
    required this.totalTime,
    required this.estimatedEarnings,
  });

  factory RouteOptimization.fromJson(Map<String, dynamic> json) {
    return RouteOptimization(
      route: (json['route'] as List? ?? [])
          .map((e) => OrderModel.fromJson(e))
          .toList(),
      totalDistance: (json['total_distance'] ?? 0).toDouble(),
      totalTime: json['total_time'] ?? 0,
      estimatedEarnings: (json['estimated_earnings'] ?? 0).toDouble(),
    );
  }

  String get totalTimeDisplay {
    if (totalTime < 60) return '$totalTime دقيقة';
    final hours = totalTime ~/ 60;
    final minutes = totalTime % 60;
    return '$hours ساعة و $minutes دقيقة';
  }
}

class AISuggestion {
  final DateTime suggestedTime;
  final double confidence;
  final String reasoning;

  AISuggestion({
    required this.suggestedTime,
    required this.confidence,
    required this.reasoning,
  });

  factory AISuggestion.fromJson(Map<String, dynamic> json) {
    return AISuggestion(
      suggestedTime: DateTime.tryParse(json['suggested_time'] ?? '') ?? DateTime.now(),
      confidence: (json['confidence'] ?? 0).toDouble(),
      reasoning: json['reasoning'] ?? '',
    );
  }
}