// lib/screens/user/driver/earnings/widgets/ai_assistant_card.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/typography.dart';
import '../../../../../data/models/earning_model.dart';

class AIAssistantCard extends StatelessWidget {
  final Map<String, dynamic> prediction;
  final EarningsSummary? summary;

  const AIAssistantCard({
    super.key,
    required this.prediction,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final predicted = prediction['predicted_earnings'] ?? 0.0;
    final bestTime = prediction['best_time'] ?? '6-9 PM';
    final tips = prediction['tips'] ?? ['Work more during peak hours'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '🤖 AI Assistant',
                style: AppTypography.display(16, weight: FontWeight.w700, color: Colors.white),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Live',
                  style: AppTypography.body(10, weight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📊 Predicted Today',
                      style: AppTypography.body(12, color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${predicted.toStringAsFixed(2)}',
                      style: AppTypography.display(28, weight: FontWeight.w800, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⏰ Best Time',
                      style: AppTypography.body(12, color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bestTime,
                      style: AppTypography.display(18, weight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tips.first,
                    style: AppTypography.body(12, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}