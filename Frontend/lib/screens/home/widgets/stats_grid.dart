// lib/screens/user/driver/dashboard/widgets/stats_grid.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';

class StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;

  const StatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(
        icon: Icons.delivery_dining_outlined,
        label: 'Deliveries',
        value: stats['total_deliveries']?.toString() ?? '0',
        color: AppColors.primary,
      ),
      _StatItem(
        icon: Icons.attach_money_outlined,
        label: 'Earnings',
        value: '\$${stats['total_earnings']?.toStringAsFixed(2) ?? '0.00'}',
        color: AppColors.success,
      ),
      _StatItem(
        icon: Icons.star_outlined,
        label: 'Rating',
        value: stats['rating']?.toStringAsFixed(1) ?? '0.0',
        color: AppColors.gold,
        trailing: '⭐',
      ),
      _StatItem(
        icon: Icons.hourglass_top_outlined,
        label: 'Active Orders',
        value: stats['current_orders']?.toString() ?? '0',
        color: AppColors.accent,
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return _StatCard(item: item)
            .animate()
            .fadeIn(duration: 300.ms, delay: (100 + index * 50).ms)
            .slideY(begin: 0.2);
      }).toList(),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? trailing;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.trailing,
  });
}

class _StatCard extends StatelessWidget {
  final _StatItem item;

  const _StatCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
              if (item.trailing != null)
                Text(item.trailing!, style: const TextStyle(fontSize: 12)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.value,
                style: AppTypography.display(18, weight: FontWeight.w800),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                item.label,
                style: AppTypography.body(11, color: AppColors.ink500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}