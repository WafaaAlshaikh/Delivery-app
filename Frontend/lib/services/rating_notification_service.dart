// lib/services/rating_notification_service.dart

import 'package:flutter/material.dart';
import 'notification_service.dart';

class RatingNotificationService {
  
  static Future<void> sendLowRatingNotification({
    required String driverName,
    required double rating,
    required String comment,
    required int orderId,
  }) async {
    if (rating >= 3.0) return;

    final title = '⚠️ Low Rating Alert';
    final body = '$driverName, you received a ${rating.toStringAsFixed(1)}⭐ rating: "$comment"';
    final suggestion = _getImprovementSuggestion(rating, comment);

    await NotificationService().showCustomNotification(
      title: title,
      body: suggestion,
      data: {
        'type': 'low_rating',
        'order_id': orderId.toString(),
        'rating': rating.toString(),
        'comment': comment,
      },
    );
  }

  static Future<void> sendExcellentRatingNotification({
    required String driverName,
    required double rating,
    required String comment,
    required int orderId,
  }) async {
    if (rating < 4.5) return;

    final title = '🌟 Excellent Rating!';
    final body = '$driverName, you received a ${rating.toStringAsFixed(1)}⭐ rating! "$comment"';

    await NotificationService().showCustomNotification(
      title: title,
      body: body,
      data: {
        'type': 'excellent_rating',
        'order_id': orderId.toString(),
        'rating': rating.toString(),
        'comment': comment,
      },
    );
  }

  static String _getImprovementSuggestion(double rating, String comment) {
    if (comment.contains('بطيء') || comment.contains('تأخر')) {
      return '💡 نصيحة: حاول تحسين سرعة التوصيل وتخطيط المسار.';
    }
    if (comment.contains('غير محترم') || comment.contains('وقح')) {
      return '💡 نصيحة: تدرب على مهارات التواصل مع العملاء.';
    }
    if (comment.contains('بارد') || comment.contains('تالف')) {
      return '💡 نصيحة: تأكد من جودة الطعام قبل التوصيل.';
    }
    if (comment.contains('عنوان') || comment.contains('ضاع')) {
      return '💡 نصيحة: تأكد من دقة العنوان قبل الانطلاق.';
    }
    return '💡 نصيحة: راجع تفاصيل الطلب وحاول تحسين الخدمة.';
  }
}