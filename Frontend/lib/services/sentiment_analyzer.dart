// lib/services/sentiment_analyzer.dart

import 'package:frontend/utils/nlp_analyzer.dart';
import '../data/models/sentiment_model.dart';

class SentimentAnalyzer {
  static bool useAdvancedNLP = true;

  static Future<SentimentAnalysis> analyzeText(String text) async {
    if (useAdvancedNLP) {
      try {
        final result = await NLPAnalyzer.analyzeSentiment(text);
        print('🧠 [NLP] Using Google Cloud NLP');
        return result;
      } catch (e) {
        print('⚠️ [NLP] Failed, using fallback: $e');
        return _fallbackAnalyze(text);
      }
    }
    print('📝 [Fallback] Using keyword-based analysis');
    return _fallbackAnalyze(text);
  }


  static SentimentAnalysis _fallbackAnalyze(String text) {
    return analyze(text);
  }

  static const List<String> _positiveWords = [
    'سريع', 'ممتاز', 'رائع', 'جميل', 'ممتاز', 'أفضل',
    'دقيق', 'محترم', 'متعاون', 'لطيف', 'ودود', 'متفهم',
    'سريع التوصيل', 'في الوقت', 'قبل الوقت',
    'رائع', 'ممتاز', 'جيد جداً', 'ممتاز', 'خدمة ممتازة'
  ];

  static const List<String> _negativeWords = [
    'بطيء', 'سيء', 'متأخر', 'غير محترم', 'وقح', 'فظ',
    'مهمل', 'غير دقيق', 'متأخر جداً', 'تأخير',
    'سيئ', 'مزعج', 'غير لطيف', 'غير متعاون',
    'تأخر التوصيل', 'فاتني', 'ضاع الطلب'
  ];

  static const List<String> _neutralWords = [
    'طبيعي', 'عادي', 'مقبول', 'متوسط', 'لا بأس',
    'ليس سيئاً', 'ليس ممتازاً', 'جيد', 'ليس سيئاً'
  ];

  static SentimentAnalysis analyze(String text) {
    final lowerText = text.toLowerCase();
    final words = lowerText.split(' ');

    int positiveScore = 0;
    int negativeScore = 0;
    int neutralScore = 0;
    final List<String> foundKeywords = [];

    for (final word in words) {
      if (_positiveWords.contains(word)) {
        positiveScore++;
        foundKeywords.add(word);
      } else if (_negativeWords.contains(word)) {
        negativeScore++;
        foundKeywords.add(word);
      } else if (_neutralWords.contains(word)) {
        neutralScore++;
        foundKeywords.add(word);
      }
    }

    final total = positiveScore + negativeScore + neutralScore;
    if (total == 0) {
      return SentimentAnalysis(
        text: text,
        result: SentimentResult.neutral,
        scores: {
          'positive': 0.0,
          'negative': 0.0,
          'neutral': 1.0,
        },
        keywords: ['لا يوجد كلمات مفتاحية'],
        analyzedAt: DateTime.now(),
      );
    }

    SentimentResult result;
    if (positiveScore > negativeScore * 1.5) {
      result = SentimentResult.positive;
    } else if (negativeScore > positiveScore * 1.5) {
      result = SentimentResult.negative;
    } else {
      result = SentimentResult.neutral;
    }

    return SentimentAnalysis(
      text: text,
      result: result,
      scores: {
        'positive': positiveScore / total,
        'negative': negativeScore / total,
        'neutral': neutralScore / total,
      },
      keywords: foundKeywords,
      analyzedAt: DateTime.now(),
    );
  }

  static List<String> extractTopKeywords(List<SentimentAnalysis> analyses) {
    final keywordCount = <String, int>{};
    for (final analysis in analyses) {
      for (final keyword in analysis.keywords) {
        keywordCount[keyword] = (keywordCount[keyword] ?? 0) + 1;
      }
    }

    final sorted = keywordCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).map((e) => e.key).toList();
  }

  static Map<String, double> analyzeTrends(List<SentimentAnalysis> analyses) {
    if (analyses.isEmpty) return {};

    final positive = analyses.where((a) => a.result == SentimentResult.positive).length;
    final negative = analyses.where((a) => a.result == SentimentResult.negative).length;
    final neutral = analyses.where((a) => a.result == SentimentResult.neutral).length;

    final total = analyses.length;
    return {
      'positive': positive / total * 100,
      'negative': negative / total * 100,
      'neutral': neutral / total * 100,
    };
  }

  static List<String> generateRecommendations(SentimentAnalysis analysis) {
    final recommendations = <String>[];

    if (analysis.result == SentimentResult.negative) {
      recommendations.add('💡 حاول تحسين سرعة التوصيل');
      recommendations.add('💡 كن أكثر تواصلاً مع العميل');
      recommendations.add('💡 تأكد من دقة العنوان قبل الانطلاق');
    } else if (analysis.result == SentimentResult.positive) {
      recommendations.add('🌟 استمر على هذا الأداء الممتاز');
      recommendations.add('🌟 شارك تجاربك الإيجابية مع السائقين الآخرين');
    }

    if (analysis.keywords.contains('بطيء') || analysis.keywords.contains('متأخر')) {
      recommendations.add('⏰ خطط لمسارك بشكل أفضل لتجنب التأخير');
    }

    if (analysis.keywords.contains('غير محترم') || analysis.keywords.contains('وقح')) {
      recommendations.add('🤝 تدرب على مهارات التواصل مع العملاء');
    }

    if (recommendations.isEmpty) {
      recommendations.add('📊 استمر بالعمل الجيد واطلب تقييمات من العملاء');
    }

    return recommendations;
  }

  static Map<String, List<String>> analyzeStrengthsWeaknesses(
    List<SentimentAnalysis> analyses,
  ) {
    final strengths = <String>{};
    final weaknesses = <String>{};

    for (final analysis in analyses) {
      if (analysis.result == SentimentResult.positive) {
        strengths.addAll(analysis.keywords);
      } else if (analysis.result == SentimentResult.negative) {
        weaknesses.addAll(analysis.keywords);
      }
    }

    return {
      'strengths': strengths.toList().take(5).toList(),
      'weaknesses': weaknesses.toList().take(5).toList(),
    };
  }
}