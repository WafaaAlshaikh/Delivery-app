// lib/data/models/communication_model.dart

import 'package:flutter/material.dart';

enum MessageType {
  text,
  location,
  eta,
  status,
  system,
}

enum MessageStatus {
  sent,
  delivered,
  read,
  failed,
}

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final bool isFromDriver;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.type,
    required this.status,
    required this.timestamp,
    required this.isFromDriver,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      senderId: json['sender_id'] ?? '',
      receiverId: json['receiver_id'] ?? '',
      text: json['text'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isFromDriver: json['is_from_driver'] ?? false,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender_id': senderId,
    'receiver_id': receiverId,
    'text': text,
    'type': type.toString(),
    'status': status.toString(),
    'timestamp': timestamp.toIso8601String(),
    'is_from_driver': isFromDriver,
    'metadata': metadata,
  };
}

class CallInfo {
  final String customerId;
  final String customerName;
  final String phoneNumber;
  final DateTime? scheduledTime;
  final bool isVideo;
  final int duration;
  final CallStatus status;

  CallInfo({
    required this.customerId,
    required this.customerName,
    required this.phoneNumber,
    this.scheduledTime,
    this.isVideo = false,
    this.duration = 0,
    required this.status,
  });

  factory CallInfo.fromJson(Map<String, dynamic> json) {
    return CallInfo(
      customerId: json['customer_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      scheduledTime: DateTime.tryParse(json['scheduled_time']),
      isVideo: json['is_video'] ?? false,
      duration: json['duration'] ?? 0,
      status: CallStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => CallStatus.pending,
      ),
    );
  }
}

enum CallStatus {
  pending,
  ongoing,
  completed,
  missed,
  cancelled,
}

class SmartSuggestion {
  final String text;
  final String emoji;
  final String? translation;
  final double confidence;

  SmartSuggestion({
    required this.text,
    required this.emoji,
    this.translation,
    this.confidence = 1.0,
  });
}

class ETAPrediction {
  final int minutes;
  final String trafficStatus; 
  final String route;
  final double distance;

  ETAPrediction({
    required this.minutes,
    required this.trafficStatus,
    required this.route,
    required this.distance,
  });

  String get timeDisplay {
    if (minutes < 1) return 'أقل من دقيقة';
    if (minutes == 1) return 'دقيقة واحدة';
    if (minutes < 10) return '$minutes دقائق';
    if (minutes < 60) return '$minutes دقيقة';
    return '${minutes ~/ 60} ساعة و ${minutes % 60} دقيقة';
  }

  String get trafficEmoji {
    switch (trafficStatus) {
      case 'light':
        return '🟢';
      case 'moderate':
        return '🟡';
      case 'heavy':
        return '🔴';
      default:
        return '🟢';
    }
  }
}