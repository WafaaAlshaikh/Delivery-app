// lib/screens/user/driver/earnings/widgets/trend_analysis_card.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/typography.dart';

class TrendAnalysisCard extends StatelessWidget {
  final List<double> dataPoints;
  final List<String> labels;

  const TrendAnalysisCard({
    super.key,
    required this.dataPoints,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final trend = _calculateTrend(dataPoints);
    final seasonality = _detectSeasonality(dataPoints);
    final prediction = _predictNext(dataPoints);
    final volatility = _calculateVolatility(dataPoints);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.analytics, color: Colors.purple, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                '🧠 تحليل الاتجاهات الذكي',
                style: AppTypography.display(16, weight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _TrendItem(
            icon: Icons.trending_up,
            label: 'الاتجاه العام',
            value: trend > 0.5 ? '📈 صاعد قوي' 
                : trend > 0 ? '📈 صاعد خفيف' 
                : trend > -0.5 ? '📉 هابط خفيف' 
                : '📉 هابط قوي',
            color: trend > 0 ? Colors.green : Colors.red,
            subValue: '${(trend * 100).toStringAsFixed(1)}%',
          ),
          const SizedBox(height: 8),
          _TrendItem(
            icon: Icons.calendar_today,
            label: 'النمط الموسمي',
            value: seasonality,
            color: Colors.blue,
            subValue: _getSeasonalityIcon(seasonality),
          ),
          const SizedBox(height: 8),
          _TrendItem(
            icon: Icons.analytics,
            label: 'توقع الأسبوع القادم',
            value: '\$${prediction.toStringAsFixed(2)}',
            color: Colors.purple,
            subValue: '${volatility > 0.2 ? '⚠️' : '✓'} تذبذب ${(volatility * 100).toStringAsFixed(0)}%',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getSuggestion(trend, volatility),
                    style: AppTypography.body(12, color: AppColors.ink700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTrend(List<double> data) {
    if (data.length < 2) return 0;
    final n = data.length;
    final sumX = List.generate(n, (i) => i.toDouble()).reduce((a, b) => a + b);
    final sumY = data.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => i.toDouble() * data[i]).reduce((a, b) => a + b);
    final sumX2 = List.generate(n, (i) => i * i).reduce((a, b) => a + b);
    
    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    return slope / (data.reduce((a, b) => a > b ? a : b) + 0.01);
  }

  String _detectSeasonality(List<double> data) {
    if (data.length < 7) return 'غير كافٍ للتحليل';
    final weekAvg = data.sublist(data.length - 7).reduce((a, b) => a + b) / 7;
    final totalAvg = data.reduce((a, b) => a + b) / data.length;
    final ratio = weekAvg / totalAvg;
    
    if (ratio > 1.2) return '📈 موسم مرتفع';
    if (ratio < 0.8) return '📉 موسم منخفض';
    return '📊 موسم مستقر';
  }

  double _predictNext(List<double> data) {
    if (data.isEmpty) return 0;
    if (data.length == 1) return data[0];
    final window = data.length > 7 ? data.sublist(data.length - 7) : data;
    return window.reduce((a, b) => a + b) / window.length * 1.02;
  }

  double _calculateVolatility(List<double> data) {
    if (data.length < 2) return 0;
    final mean = data.reduce((a, b) => a + b) / data.length;
    final variance = data.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) / data.length;
    return variance / (mean + 0.01);
  }

  String _getSeasonalityIcon(String seasonality) {
    if (seasonality.contains('مرتفع')) return '📈';
    if (seasonality.contains('منخفض')) return '📉';
    return '📊';
  }

  String _getSuggestion(double trend, double volatility) {
    if (trend > 0.5) {
      return '🚀 أداء ممتاز! استمر بنفس النهج. فكر في زيادة ساعات العمل.';
    } else if (trend > 0) {
      return '📈 تحسن ملحوظ! حاول العمل في أوقات الذروة لتعزيز الأرباح.';
    } else if (trend > -0.5) {
      return '📊 استقرار في الأداء. جرب تغيير مناطق العمل أو الأوقات.';
    } else {
      return '⚠️ تراجع في الأداء. راجع تقييمات العملاء وحاول تحسين جودة الخدمة.';
    }
  }
}

class _TrendItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String subValue;

  const _TrendItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.subValue = '',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTypography.body(13, color: AppColors.ink500),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: AppTypography.body(13, weight: FontWeight.w600, color: color),
          ),
        ),
        if (subValue.isNotEmpty)
          Text(
            subValue,
            style: AppTypography.body(11, color: AppColors.ink900),
          ),
      ],
    );
  }
}