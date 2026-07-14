// lib/screens/user/driver/ratings/widgets/sentiment_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/typography.dart';
import '../../../../../data/models/rating_model.dart';

class SentimentChart extends StatelessWidget {
  final RatingsSummary summary;

  const SentimentChart({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📊 Sentiment Analysis',
                style: AppTypography.display(14, weight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'AI Powered',
                  style: AppTypography.body(10, weight: FontWeight.w600, color: Colors.blue.shade800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 30,
                sections: [
                  PieChartSectionData(
                    value: summary.positivePercentage,
                    color: Colors.green,
                    title: '${summary.positivePercentage.round()}%',
                    radius: 30,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  PieChartSectionData(
                    value: summary.neutralPercentage,
                    color: Colors.orange,
                    title: '${summary.neutralPercentage.round()}%',
                    radius: 30,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  PieChartSectionData(
                    value: summary.negativePercentage,
                    color: Colors.red,
                    title: '${summary.negativePercentage.round()}%',
                    radius: 30,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem('😊 Positive', summary.positivePercentage, Colors.green),
              const SizedBox(width: 16),
              _legendItem('😐 Neutral', summary.neutralPercentage, Colors.orange),
              const SizedBox(width: 16),
              _legendItem('😞 Negative', summary.negativePercentage, Colors.red),
            ],
          ),
          if (summary.topKeywords.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: summary.topKeywords.map((keyword) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#$keyword',
                    style: AppTypography.body(11, color: AppColors.ink500),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _legendItem(String label, double percentage, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${percentage.round()}%',
          style: AppTypography.body(10, weight: FontWeight.w600),
        ),
      ],
    );
  }
}