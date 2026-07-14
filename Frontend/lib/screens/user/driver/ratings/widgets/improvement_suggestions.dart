// lib/screens/user/driver/ratings/widgets/improvement_suggestions.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/typography.dart';
import '../../../../../data/models/rating_model.dart';

class ImprovementSuggestions extends StatelessWidget {
  final AIInsights insights;

  const ImprovementSuggestions({super.key, required this.insights});

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
          Text(
            '📈 Improvement Suggestions',
            style: AppTypography.display(14, weight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...insights.suggestions.map((suggestion) {
            final icon = _getIconForSuggestion(suggestion);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: icon.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon.icon, color: icon.color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: AppTypography.body(13, color: AppColors.ink700),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  _SuggestionIcon _getIconForSuggestion(String suggestion) {
    if (suggestion.contains('سرعة') || suggestion.contains('سريع')) {
      return _SuggestionIcon(Icons.speed, Colors.blue);
    }
    if (suggestion.contains('تواصل') || suggestion.contains('محترم')) {
      return _SuggestionIcon(Icons.people, Colors.green);
    }
    if (suggestion.contains('دقة') || suggestion.contains('عنوان')) {
      return _SuggestionIcon(Icons.location_on, Colors.orange);
    }
    if (suggestion.contains('تقييم')) {
      return _SuggestionIcon(Icons.star, Colors.amber);
    }
    return _SuggestionIcon(Icons.lightbulb, Colors.purple);
  }
}

class _SuggestionIcon {
  final IconData icon;
  final Color color;

  _SuggestionIcon(this.icon, this.color);
}