// lib/utils/nlp_analyzer.dart

import 'dart:convert';
import 'package:frontend/services/sentiment_analyzer.dart';
import 'package:http/http.dart' as http;
import '../data/models/sentiment_model.dart';

class NLPAnalyzer {
  static const String _apiKey = 'AIzaSyDYqtonHEBiDf-IA2iTFPHfu3_AiVoLAko';
  static const String _url = 'https://language.googleapis.com/v1/documents:analyzeSentiment?key=$_apiKey';

  static Future<SentimentAnalysis> analyzeSentiment(String text) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'document': {
            'type': 'PLAIN_TEXT',
            'content': text,
          },
          'encodingType': 'UTF8',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sentiment = data['documentSentiment'];
        
        final score = (sentiment['score'] ?? 0.0).toDouble();
        final magnitude = (sentiment['magnitude'] ?? 0.0).toDouble();
        
        SentimentResult result;
        if (score > 0.2) {
          result = SentimentResult.positive;
        } else if (score < -0.2) {
          result = SentimentResult.negative;
        } else {
          result = SentimentResult.neutral;
        }

        final sentences = data['sentences'] ?? [];
        final keywords = <String>[];
        for (final sentence in sentences) {
          final text = sentence['text']['content'] ?? '';
          final words = text.split(' ');
          for (final word in words) {
            if (word.length > 3) {
              keywords.add(word.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ''));
            }
          }
        }

        return SentimentAnalysis(
          text: text,
          result: result,
          scores: {
            'positive': score > 0 ? score : 0,
            'negative': score < 0 ? -score : 0,
            'neutral': 1.0 - score.abs(),
          },
          keywords: keywords.take(10).toList(),
          analyzedAt: DateTime.now(),
        );
      } else {
        print('❌ NLP API error: ${response.statusCode}');
        return _fallbackAnalysis(text);
      }
    } catch (e) {
      print('❌ NLP analysis error: $e');
      return _fallbackAnalysis(text);
    }
  }

  static SentimentAnalysis _fallbackAnalysis(String text) {
    return SentimentAnalyzer.analyze(text);
  }
}