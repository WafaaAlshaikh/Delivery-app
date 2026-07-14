// lib/screens/user/driver/earnings/widgets/period_selector.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/typography.dart';

class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final periods = [
      {'value': 'daily', 'label': '📅 Daily'},
      {'value': 'weekly', 'label': '📊 Weekly'},
      {'value': 'monthly', 'label': '📈 Monthly'},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = period['value'] == selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () => onPeriodChanged(period['value']!),
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
                child: Text(
                  period['label']!,
                  textAlign: TextAlign.center,
                  style: AppTypography.body(
                    13,
                    weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.ink500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}