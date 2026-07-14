// lib/services/communication_service.dart

import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../core/constants/api_constants.dart';
import '../data/models/communication_model.dart';
import '../services/storage_service.dart';
import '../services/socket_service.dart';

class CommunicationService {
  final Dio _dio = Dio();
  final StorageService _storageService = StorageService();
  IO.Socket? _socket;

  CommunicationService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    _initSocket();
  }

  void _initSocket() {
    _socket = SocketService.getSocket();
    
    _socket?.on('new_message', (data) {
      print('📨 New message received: $data');
    });

    _socket?.on('message_status', (data) {
      print('📨 Message status updated: $data');
    });

    _socket?.on('call_notification', (data) {
      print('📞 Call notification: $data');
    });
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Authorization': 'Bearer $token',
    };
  }

Future<ChatMessage> sendMessage({
  required String customerId,
  required String text,
  MessageType type = MessageType.text,
  Map<String, dynamic>? metadata,
}) async {
  try {
    final headers = await _getHeaders();
    
    String typeValue = 'text';
    switch (type) {
      case MessageType.text:
        typeValue = 'text';
        break;
      case MessageType.location:
        typeValue = 'location';
        break;
      case MessageType.eta:
        typeValue = 'eta';
        break;
      case MessageType.status:
        typeValue = 'status';
        break;
      case MessageType.system:
        typeValue = 'system';
        break;
    }
    
    final data = {
      'customer_id': customerId.toString(),
      'text': text,
      'type': typeValue, 
      'metadata': metadata,
    };
    
    print('📤 Sending message: $data');

    final response = await _dio.post(
      '/api/driver/chat/send',
      data: data,
      options: Options(headers: headers),
    );

    print('✅ Send message response: ${response.data}');

    if (response.data['success'] == true) {
      final messageData = response.data['data'];
      
      return ChatMessage(
        id: messageData['message_id']?.toString() ?? messageData['id']?.toString() ?? '',
        senderId: messageData['sender_id']?.toString() ?? '',
        receiverId: messageData['receiver_id']?.toString() ?? '',
        text: messageData['message'] ?? '',
        type: _parseMessageType(messageData['type']),
        status: _parseMessageStatus(messageData['status']),
        timestamp: DateTime.tryParse(messageData['created_at'] ?? '') ?? DateTime.now(),
        isFromDriver: messageData['is_from_driver'] ?? false,
        metadata: messageData['metadata'],
      );
    }
    throw Exception(response.data['message'] ?? 'Failed to send message');
  } catch (e) {
    print('❌ Send message error: $e');
    rethrow;
  }
}

MessageType _parseMessageType(String? type) {
  switch (type) {
    case 'text': return MessageType.text;
    case 'location': return MessageType.location;
    case 'eta': return MessageType.eta;
    case 'status': return MessageType.status;
    case 'system': return MessageType.system;
    default: return MessageType.text;
  }
}

MessageStatus _parseMessageStatus(String? status) {
  switch (status) {
    case 'sent': return MessageStatus.sent;
    case 'delivered': return MessageStatus.delivered;
    case 'read': return MessageStatus.read;
    case 'failed': return MessageStatus.failed;
    default: return MessageStatus.sent;
  }
}
  Future<List<ChatMessage>> getChatHistory({
    required String customerId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/driver/chat/history',
        queryParameters: {
          'customer_id': customerId.toString(), 
          'page': page,
          'limit': limit,
        },
        options: Options(headers: headers),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as List? ?? [];
        return data.map((e) => ChatMessage.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Get chat history error: $e');
      return [];
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/driver/chat/unread',
        options: Options(headers: headers),
      );

      if (response.data['success'] == true) {
        return response.data['data']['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('❌ Get unread count error: $e');
      return 0;
    }
  }

  Future<List<SmartSuggestion>> getSmartSuggestions({
    required String customerMessage,
    required String context,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '/api/driver/chat/suggestions',
        data: {
          'message': customerMessage,
          'context': context,
        },
        options: Options(headers: headers),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as List? ?? [];
        return data.map((e) => SmartSuggestion(
          text: e['text'] ?? '',
          emoji: e['emoji'] ?? '💡',
          translation: e['translation'],
          confidence: (e['confidence'] ?? 1.0).toDouble(),
        )).toList();
      }
      return [];
    } catch (e) {
      print('❌ Get smart suggestions error: $e');
      return [];
    }
  }

  Future<void> markAsRead(String messageId) async {
    try {
      final headers = await _getHeaders();
      await _dio.put(
        '/api/driver/chat/read/$messageId',
        options: Options(headers: headers),
      );
    } catch (e) {
      print('❌ Mark as read error: $e');
    }
  }

 
  List<SmartSuggestion> getMessageTemplates() {
    return [
      SmartSuggestion(
        text: 'أنا في الطريق الآن',
        emoji: '🚗',
        translation: 'I\'m on my way now',
      ),
      SmartSuggestion(
        text: 'سأصل خلال 5 دقائق',
        emoji: '⏱️',
        translation: 'I\'ll arrive in 5 minutes',
      ),
      SmartSuggestion(
        text: 'هل لديك أي تعليمات إضافية؟',
        emoji: '📝',
        translation: 'Do you have any additional instructions?',
      ),
      SmartSuggestion(
        text: 'وصلت إلى موقعك',
        emoji: '📍',
        translation: 'I\'ve arrived at your location',
      ),
      SmartSuggestion(
        text: 'تم التوصيل بنجاح ✅',
        emoji: '✅',
        translation: 'Successfully delivered',
      ),
      SmartSuggestion(
        text: 'آسف على التأخير',
        emoji: '🙏',
        translation: 'Sorry for the delay',
      ),
      SmartSuggestion(
        text: 'هل يمكنك تحديد موقعك بشكل أفضل؟',
        emoji: '📍',
        translation: 'Can you specify your location better?',
      ),
      SmartSuggestion(
        text: 'سأتصل بك عند الوصول',
        emoji: '📞',
        translation: 'I\'ll call you upon arrival',
      ),
    ];
  }

  Future<ChatMessage> shareLocation({
    required String customerId,
    required double latitude,
    required double longitude,
  }) async {
    return sendMessage(
      customerId: customerId,
      text: '📍 موقعي الحالي',
      type: MessageType.location,
      metadata: {
        'latitude': latitude,
        'longitude': longitude,
        'url': 'https://maps.google.com/?q=$latitude,$longitude',
      },
    );
  }

  Future<ChatMessage> sendETA({
    required String customerId,
    required int minutes,
    required String trafficStatus,
  }) async {
    return sendMessage(
      customerId: customerId,
      text: '🚗 سأصل خلال $minutes دقائق',
      type: MessageType.eta,
      metadata: {
        'minutes': minutes,
        'traffic_status': trafficStatus,
      },
    );
  }

  Future<void> notifyArrived(String customerId) async {
    try {
      final headers = await _getHeaders();
      await _dio.post(
        '/api/driver/chat/arrived',
        data: {
          'customer_id': customerId,
        },
        options: Options(headers: headers),
      );
    } catch (e) {
      print('❌ Notify arrived error: $e');
    }
  }

  Future<void> notifyOnTheWay(String customerId, {int? etaMinutes}) async {
    try {
      final headers = await _getHeaders();
      await _dio.post(
        '/api/driver/chat/on-the-way',
        data: {
          'customer_id': customerId,
          'eta_minutes': etaMinutes,
        },
        options: Options(headers: headers),
      );
    } catch (e) {
      print('❌ Notify on the way error: $e');
    }
  }

  void dispose() {
    _socket?.off('new_message');
    _socket?.off('message_status');
    _socket?.off('call_notification');
  }
}
