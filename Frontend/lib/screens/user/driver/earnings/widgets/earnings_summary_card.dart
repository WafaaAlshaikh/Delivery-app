// lib/screens/user/driver/earnings/widgets/earnings_summary_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/typography.dart';
import '../../../../../data/models/earning_model.dart';

class EarningsSummaryCard extends StatelessWidget {
  final EarningsSummary summary;

  const EarningsSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final items = [
      _SummaryItem(
        icon: Icons.today,
        label: 'Today',
        value: '\$${summary.todayEarnings.toStringAsFixed(2)}',
        subtitle: '${summary.todayDeliveries} deliveries',
        color: const Color(0xFF667EEA),
      ),
      _SummaryItem(
        icon: Icons.calendar_today,
        label: 'This Week',
        value: '\$${summary.weeklyEarnings.toStringAsFixed(2)}',
        subtitle: '${summary.averagePerDay.toStringAsFixed(2)}/day',
        color: const Color(0xFF764BA2),
      ),
      _SummaryItem(
        icon: Icons.calendar_month,
        label: 'This Month',
        value: '\$${summary.monthlyEarnings.toStringAsFixed(2)}',
        subtitle: '${summary.totalDeliveries} deliveries',
        color: const Color(0xFFF093FB),
      ),
      _SummaryItem(
        icon: Icons.star,
        label: 'Rating',
        value: summary.averageRating.toStringAsFixed(1),
        subtitle: '⭐ Average',
        color: const Color(0xFFF5576C),
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: items.map((item) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, color: item.color, size: 18),
                  ),
                  Text(
                    item.label,
                    style: AppTypography.body(11, color: AppColors.ink500),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.value,
                    style: AppTypography.display(20, weight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.subtitle,
                    style: AppTypography.body(11, color: AppColors.ink500),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SummaryItem {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;

  _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });
}