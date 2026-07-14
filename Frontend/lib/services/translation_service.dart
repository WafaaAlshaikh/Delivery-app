// lib/services/translation_service.dart

import 'package:translator/translator.dart';

class TranslationService {
  final GoogleTranslator _translator = GoogleTranslator();

  static const List<String> supportedLanguages = [
    'ar', 
    'en', 
    'fr', 
    'he', 
    'ru', 
  ];

  Future<String> translate({
    required String text,
    required String targetLanguage,
    String sourceLanguage = 'ar',
  }) async {
    try {
      if (sourceLanguage == targetLanguage) return text;

      final translation = await _translator.translate(text, to: targetLanguage);
      return translation.text;
    } catch (e) {
      print('❌ Translation error: $e');
      return text;
    }
  }

  Future<String> detectLanguage(String text) async {
    try {
      final translation = await _translator.translate(text, to: 'en');
      final translatedText = translation.text.toLowerCase();
      
      if (translatedText.contains('hello') || 
          translatedText.contains('thank') || 
          translatedText.contains('please')) {
        return 'en';
      } else if (translatedText.contains('bonjour') || 
                 translatedText.contains('merci')) {
        return 'fr';
      } else {
        return 'ar'; 
      }
    } catch (e) {
      print('❌ Language detection error: $e');
      return 'ar';
    }
  }

  Future<String> translateMessage({
    required String message,
    required String targetLanguage,
    required String context,
  }) async {
    final contextualMessage = _addContext(message, context);
    return translate(
      text: contextualMessage,
      targetLanguage: targetLanguage,
    );
  }

  String _addContext(String message, String context) {
    switch (context) {
      case 'greeting':
        return 'مرحباً، $message';
      case 'delivery':
        return 'بخصوص التوصيل، $message';
      case 'emergency':
        return 'عاجل: $message';
      default:
        return message;
    }
  }

  Map<String, String> getTranslatedTemplates(String language) {
    final templates = {
      'ar': {
        'on_way': '🚗 أنا في الطريق الآن',
        'arriving': '⏱️ سأصل خلال 5 دقائق',
        'arrived': '📍 وصلت إلى موقعك',
        'completed': '✅ تم التوصيل بنجاح',
        'sorry_delay': '🙏 آسف على التأخير',
        'need_location': '📍 هل يمكنك تحديد موقعك بشكل أفضل؟',
        'will_call': '📞 سأتصل بك عند الوصول',
      },
      'en': {
        'on_way': '🚗 I\'m on my way now',
        'arriving': '⏱️ I\'ll arrive in 5 minutes',
        'arrived': '📍 I\'ve arrived at your location',
        'completed': '✅ Successfully delivered',
        'sorry_delay': '🙏 Sorry for the delay',
        'need_location': '📍 Can you specify your location better?',
        'will_call': '📞 I\'ll call you upon arrival',
      },
    };

    return templates[language] ?? templates['ar']!;
  }
}