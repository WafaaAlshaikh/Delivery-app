// lib/screens/user/driver/scheduling/widgets/ai_suggestion_card.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/typography.dart';
import '../../../../../../data/models/scheduled_order_model.dart';

class AISuggestionCard extends StatelessWidget {
  final AISuggestion suggestion;

  const AISuggestionCard({super.key, required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.pink.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.purple, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🤖 اقتراح ذكي',
                  style: AppTypography.display(14, weight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'الوقت المقترح: ${_formatTime(suggestion.suggestedTime)}',
                  style: AppTypography.body(14, weight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  suggestion.reasoning,
                  style: AppTypography.body(12, color: AppColors.ink500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: suggestion.confidence > 70 
                  ? Colors.green.shade100 
                  : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${suggestion.confidence.round()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: suggestion.confidence > 70 ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}