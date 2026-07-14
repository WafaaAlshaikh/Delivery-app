// lib/screens/user/driver/ratings/analytics/period_filter.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/typography.dart';

enum Period { day, week, month, year }

class PeriodFilter extends StatelessWidget {
  final Period selectedPeriod;
  final ValueChanged<Period> onPeriodChanged;
  final Map<Period, int> counts;

  const PeriodFilter({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    final periods = [
      {'key': Period.day, 'label': '📅 Day'},
      {'key': Period.week, 'label': '📊 Week'},
      {'key': Period.month, 'label': '📈 Month'},
      {'key': Period.year, 'label': '📉 Year'},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = period['key'] == selectedPeriod;
          final count = counts[period['key']] ?? 0;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => onPeriodChanged(period['key'] as Period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  children: [
                    Text(
                      period['label'] as String,
                      style: AppTypography.body(
                        12,
                        weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.ink500,
                      ),
                    ),
                    Text(
                      '$count',
                      style: AppTypography.body(
                        10,
                        color: isSelected ? AppColors.primary : AppColors.ink300,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}