// lib/screens/user/driver/ratings/widgets/filter_chips.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/typography.dart';

class FilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final Map<String, int> counts;

  const FilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'key': 'all', 'label': 'الكل', 'icon': Icons.all_inclusive},
      {'key': 'positive', 'label': '😊 إيجابي', 'icon': Icons.sentiment_very_satisfied},
      {'key': 'neutral', 'label': '😐 محايد', 'icon': Icons.sentiment_neutral},
      {'key': 'negative', 'label': '😞 سلبي', 'icon': Icons.sentiment_very_dissatisfied},
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final filterKey = filter['key'] as String;
          final isSelected = selectedFilter == filterKey;
          final count = counts[filterKey] ?? 0;
          final icon = filter['icon'] as IconData;

          return FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? Colors.white : AppColors.ink500,
                ),
                const SizedBox(width: 4),
                Text(
                  '${filter['label']} ($count)',
                  style: AppTypography.body(
                    11,
                    weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.ink700,
                  ),
                ),
              ],
            ),
            selected: isSelected,
            onSelected: (_) => onFilterChanged(filterKey),
            selectedColor: AppColors.primary,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
              ),
            ),
            labelPadding: const EdgeInsets.symmetric(horizontal: 8),
          );
        },
      ),
    );
  }
}