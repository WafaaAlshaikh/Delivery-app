// lib/screens/user/driver/earnings/widgets/comparison_card.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/typography.dart';

class ComparisonCard extends StatelessWidget {
  final double currentPeriod;
  final double previousPeriod;
  final String periodLabel; 

  const ComparisonCard({
    super.key,
    required this.currentPeriod,
    required this.previousPeriod,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    final difference = currentPeriod - previousPeriod;
    final percentage = previousPeriod > 0 
        ? (difference / previousPeriod) * 100 
        : 0;

    final isPositive = difference >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPositive ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isPositive ? Colors.green.shade100 : Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              color: isPositive ? Colors.green : Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📊 مقابل $periodLabel',
                  style: AppTypography.body(14, weight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${isPositive ? '+' : ''}${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPositive ? '📈 تحسن' : '📉 تراجع',
                      style: AppTypography.body(12, color: isPositive ? Colors.green : Colors.red),
                    ),
                  ],
                ),
                Text(
                  'قبل: \$${previousPeriod.toStringAsFixed(2)} → الآن: \$${currentPeriod.toStringAsFixed(2)}',
                  style: AppTypography.body(12, color: AppColors.ink500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}