// lib/providers/communication_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/models/communication_model.dart';
import '../services/communication_service.dart';
import '../services/call_service.dart';
import '../services/translation_service.dart';

final communicationServiceProvider = Provider<CommunicationService>((ref) {
  return CommunicationService();
});

final callServiceProvider = Provider<CallService>((ref) {
  return CallService();
});

final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService();
});

class CommunicationState {
  final bool isLoading;
  final String? error;
  final List<ChatMessage> messages;
  final int unreadCount;
  final List<SmartSuggestion> suggestions;
  final String customerLanguage;
  final bool isRecording;

  CommunicationState({
    this.isLoading = false,
    this.error,
    this.messages = const [],
    this.unreadCount = 0,
    this.suggestions = const [],
    this.customerLanguage = 'ar',
    this.isRecording = false,
  });

  CommunicationState copyWith({
    bool? isLoading,
    String? error,
    List<ChatMessage>? messages,
    int? unreadCount,
    List<SmartSuggestion>? suggestions,
    String? customerLanguage,
    bool? isRecording,
  }) {
    return CommunicationState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      messages: messages ?? this.messages,
      unreadCount: unreadCount ?? this.unreadCount,
      suggestions: suggestions ?? this.suggestions,
      customerLanguage: customerLanguage ?? this.customerLanguage,
      isRecording: isRecording ?? this.isRecording,
    );
  }
}

class CommunicationNotifier extends StateNotifier<CommunicationState> {
  final CommunicationService _service;
  final CallService _callService;
  final TranslationService _translationService;

  CommunicationNotifier(
    this._service,
    this._callService,
    this._translationService,
  ) : super(CommunicationState());


Future<void> loadChat(String customerId) async {
  state = state.copyWith(isLoading: true, error: null);
  try {
    final messages = await _service.getChatHistory(customerId: customerId.toString()); 
    final unread = await _service.getUnreadCount();
    
    final lastMessage = messages.isNotEmpty ? messages.last.text : 'مرحباً';
    final suggestions = await _service.getSmartSuggestions(
      customerMessage: lastMessage,
      context: 'delivery',
    );

    state = state.copyWith(
      isLoading: false,
      messages: messages,
      unreadCount: unread,
      suggestions: suggestions.isNotEmpty ? suggestions : _service.getMessageTemplates(),
    );
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      error: e.toString(),
    );
  }
}

Future<void> sendMessage({
  required String customerId,
  required String text,
  MessageType type = MessageType.text,
  Map<String, dynamic>? metadata,
}) async {
  try {
    final message = await _service.sendMessage(
      customerId: customerId.toString(), 
      text: text,
      type: type,
      metadata: metadata,
    );

    state = state.copyWith(
      messages: [message, ...state.messages],
    );

    final suggestions = await _service.getSmartSuggestions(
      customerMessage: text,
      context: 'delivery',
    );

    if (suggestions.isNotEmpty) {
      state = state.copyWith(suggestions: suggestions);
    }
  } catch (e) {
    state = state.copyWith(error: e.toString());
  }
}

  Future<void> shareLocation({
    required String customerId,
    required double latitude,
    required double longitude,
  }) async {
    await sendMessage(
      customerId: customerId,
      text: '📍 موقعي الحالي',
      type: MessageType.location,
      metadata: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  Future<void> sendETA({
    required String customerId,
    required int minutes,
    required String trafficStatus,
  }) async {
    await sendMessage(
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
    await _service.notifyArrived(customerId);
    await sendMessage(
      customerId: customerId,
      text: '📍 وصلت إلى موقعك',
      type: MessageType.status,
    );
  }

  Future<void> notifyOnTheWay(String customerId, {int? etaMinutes}) async {
    await _service.notifyOnTheWay(customerId, etaMinutes: etaMinutes);
    await sendMessage(
      customerId: customerId,
      text: etaMinutes != null
          ? '🚗 في الطريق، سأصل خلال $etaMinutes دقائق'
          : '🚗 في الطريق إليك',
      type: MessageType.status,
    );
  }

  Future<String> translateMessage(String text, String targetLanguage) async {
    return _translationService.translate(
      text: text,
      targetLanguage: targetLanguage,
    );
  }

  Future<void> detectCustomerLanguage(String text) async {
    try {
      final language = await _translationService.detectLanguage(text);
      state = state.copyWith(customerLanguage: language);
    } catch (e) {
      print('❌ Language detection error: $e');
    }
  }

  Future<void> refreshSuggestions() async {
    final templates = _service.getMessageTemplates();
    state = state.copyWith(suggestions: templates);
  }

  Future<void> markMessagesAsRead(List<String> messageIds) async {
    for (final id in messageIds) {
      await _service.markAsRead(id);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final communicationProvider =
    StateNotifierProvider<CommunicationNotifier, CommunicationState>(
  (ref) {
    final service = ref.read(communicationServiceProvider);
    final callService = ref.read(callServiceProvider);
    final translationService = ref.read(translationServiceProvider);
    return CommunicationNotifier(service, callService, translationService);
  },
);
