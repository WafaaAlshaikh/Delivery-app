// lib/screens/user/driver/ratings/widgets/ai_insights_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/typography.dart';
import '../../../../../data/models/rating_model.dart';

class AIInsightsCard extends StatelessWidget {
  final AIInsights insights;

  const AIInsightsCard({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.purple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '🧠 AI Analysis',
                  style: AppTypography.display(16, weight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${insights.improvementScore.round()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(insights.improvementScore),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            insights.overallAssessment,
            style: AppTypography.body(14, color: AppColors.ink700),
          ),
          const SizedBox(height: 12),
          if (insights.strengths.isNotEmpty) ...[
            _buildTagSection('💪 نقاط القوة', insights.strengths, Colors.green),
            const SizedBox(height: 8),
          ],
          if (insights.weaknesses.isNotEmpty) ...[
            _buildTagSection('⚠️ نقاط الضعف', insights.weaknesses, Colors.red),
            const SizedBox(height: 8),
          ],
          if (insights.recommendations.isNotEmpty) ...[
            _buildTagSection('🎯 توصيات', insights.recommendations, Colors.blue),
          ],
        ],
      ),
    );
  }

  Widget _buildTagSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.body(12, weight: FontWeight.w600, color: AppColors.ink500),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                item,
                style: AppTypography.body(11, color: color, weight: FontWeight.w500),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}