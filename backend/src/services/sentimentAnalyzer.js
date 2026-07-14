// backend/src/services/sentimentAnalyzer.js

class SentimentAnalyzer {
  static get _positiveWords() {
    return [
      'سريع', 'ممتاز', 'رائع', 'جميل', 'أفضل', 'دقيق',
      'محترم', 'متعاون', 'لطيف', 'ودود', 'متفهم',
      'سريع التوصيل', 'في الوقت', 'قبل الوقت',
      'رائع', 'جيد جدا', 'خدمة ممتازة', 'ممتازة',
      'مشكور', 'جزاك الله خير', 'رائعة', 'متميز'
    ];
  }

  static get _negativeWords() {
    return [
      'بطيء', 'سيء', 'متأخر', 'غير محترم', 'وقح', 'فظ',
      'مهمل', 'غير دقيق', 'متأخر جدا', 'تأخير', 'سيئ',
      'مزعج', 'غير لطيف', 'غير متعاون', 'تأخر التوصيل',
      'فاتني', 'ضاع الطلب', 'غير مهتم', 'سئ', 'فظيع'
    ];
  }

  static get _neutralWords() {
    return [
      'طبيعي', 'عادي', 'مقبول', 'متوسط', 'لا بأس',
      'ليس سيئاً', 'ليس ممتازاً', 'جيد', 'لا بأس به'
    ];
  }

  static analyze(text) {
    if (!text || text.trim().length === 0) {
      return {
        sentiment: 'neutral',
        score: 0.5,
        keywords: []
      };
    }

    const lowerText = text.toLowerCase();
    const words = lowerText.split(' ');

    let positiveScore = 0;
    let negativeScore = 0;
    let neutralScore = 0;
    const foundKeywords = [];

    for (const word of words) {
      if (SentimentAnalyzer._positiveWords.includes(word)) {
        positiveScore++;
        if (!foundKeywords.includes(word)) foundKeywords.push(word);
      } else if (SentimentAnalyzer._negativeWords.includes(word)) {
        negativeScore++;
        if (!foundKeywords.includes(word)) foundKeywords.push(word);
      } else if (SentimentAnalyzer._neutralWords.includes(word)) {
        neutralScore++;
        if (!foundKeywords.includes(word)) foundKeywords.push(word);
      }
    }

    const total = positiveScore + negativeScore + neutralScore;
    
    if (total === 0) {
      return {
        sentiment: 'neutral',
        score: 0.5,
        keywords: ['لا توجد كلمات مفتاحية']
      };
    }

    const positiveRatio = positiveScore / total;
    const negativeRatio = negativeScore / total;

    let sentiment;
    let score;

    if (positiveRatio > negativeRatio * 1.5) {
      sentiment = 'positive';
      score = 0.7 + (positiveRatio * 0.3);
    } else if (negativeRatio > positiveRatio * 1.5) {
      sentiment = 'negative';
      score = 0.3 - (negativeRatio * 0.3);
    } else {
      sentiment = 'neutral';
      score = 0.5;
    }

    score = Math.max(0, Math.min(1, score));

    return {
      sentiment: sentiment,
      score: score,
      keywords: foundKeywords.slice(0, 5)
    };
  }

  static extractTopKeywords(analyses) {
    const keywordCount = {};
    
    for (const analysis of analyses) {
      if (analysis.keywords) {
        for (const keyword of analysis.keywords) {
          keywordCount[keyword] = (keywordCount[keyword] || 0) + 1;
        }
      }
    }

    const sorted = Object.entries(keywordCount)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([key]) => key);

    return sorted;
  }

  static analyzeTrends(ratings) {
    if (!ratings || ratings.length === 0) {
      return { positive: 0, negative: 0, neutral: 0 };
    }

    const total = ratings.length;
    const positive = ratings.filter(r => r.sentiment === 'positive').length;
    const negative = ratings.filter(r => r.sentiment === 'negative').length;
    const neutral = ratings.filter(r => r.sentiment === 'neutral').length;

    return {
      positive: (positive / total) * 100,
      negative: (negative / total) * 100,
      neutral: (neutral / total) * 100
    };
  }

  static generateRecommendations(insights) {
    const recommendations = [];

    if (insights.strengths && insights.strengths.length > 0) {
      recommendations.push(`🌟 استمر على نقاط قوتك: ${insights.strengths.slice(0, 2).join('، ')}`);
    }

    if (insights.weaknesses && insights.weaknesses.length > 0) {
      recommendations.push(`💪 حاول تحسين: ${insights.weaknesses.slice(0, 2).join('، ')}`);
    }

    if (insights.improvementScore < 50) {
      recommendations.push('📈 ركز على سرعة التوصيل ودقة العنوان');
    }

    if (insights.improvementScore > 70) {
      recommendations.push('🏆 أداء ممتاز! شارك تجاربك الإيجابية مع السائقين الآخرين');
    }

    if (recommendations.length === 0) {
      recommendations.push('📊 استمر بالعمل الجيد واطلب تقييمات من العملاء');
    }

    return recommendations;
  }
}

module.exports = SentimentAnalyzer;