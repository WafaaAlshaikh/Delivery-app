// lib/screens/user/driver/communication/widgets/smart_replies.dart

import 'package:flutter/material.dart';
import '../../../../../../core/theme/colors.dart';
import '../../../../../../core/theme/typography.dart';
import '../../../../../../data/models/communication_model.dart';

class SmartSuggestions extends StatelessWidget {
  final List<SmartSuggestion> suggestions;
  final ValueChanged<SmartSuggestion> onSuggestionTap;

  const SmartSuggestions({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                '💡 اقتراحات ذكية',
                style: AppTypography.body(12, color: AppColors.primary, weight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.take(6).length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return _SuggestionChip(
                  suggestion: suggestion,
                  onTap: () => onSuggestionTap(suggestion),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final SmartSuggestion suggestion;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.suggestion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              suggestion.emoji,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 6),
            Text(
              suggestion.text,
              style: AppTypography.body(12, color: AppColors.primaryDark),
            ),
          ],
        ),
      ),
    );
  }
}