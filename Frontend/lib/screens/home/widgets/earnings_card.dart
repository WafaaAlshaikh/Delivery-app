// lib/screens/user/driver/dashboard/widgets/earnings_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';

class EarningsCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const EarningsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final totalEarnings = stats['total_earnings'] ?? 0.0;
    final weeklyEarnings = stats['weekly_earnings'] ?? 0.0;
    final changePercentage = stats['change_percentage'] ?? 5.2;

    final chartData = [
      12.5, 18.0, 15.5, 22.0, 28.5, 25.0, 35.0,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppColors.routeGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.attach_money,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Earnings',
                        style: AppTypography.body(12, color: AppColors.ink500),
                      ),
                      Text(
                        '\$${totalEarnings.toStringAsFixed(2)}',
                        style: AppTypography.display(20, weight: FontWeight.w800),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: changePercentage >= 0
                      ? AppColors.successSoft
                      : AppColors.errorSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      changePercentage >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: changePercentage >= 0
                          ? AppColors.success
                          : AppColors.error,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${changePercentage >= 0 ? '+' : ''}${changePercentage.toStringAsFixed(1)}%',
                      style: AppTypography.body(
                        11,
                        weight: FontWeight.w600,
                        color: changePercentage >= 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 60,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: chartData.reduce((a, b) => a > b ? a : b) * 1.2,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.ink900,
                    getTooltipItems: (spots) => spots.map((s) {
                      return LineTooltipItem(
                        '\$${s.y.toStringAsFixed(2)}',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      );
                    }).toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value);
                    }).toList(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.2),
                          AppColors.primary.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _StatChip(
                  label: 'This Week',
                  value: '\$${weeklyEarnings.toStringAsFixed(2)}',
                  icon: Icons.calendar_today_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatChip(
                  label: 'Deliveries',
                  value: stats['total_deliveries']?.toString() ?? '0',
                  icon: Icons.delivery_dining_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatChip(
                  label: 'Rating',
                  value: stats['rating']?.toStringAsFixed(1) ?? '0.0',
                  icon: Icons.star_outlined,
                  trailing: '⭐',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String? trailing;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.ink500),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.body(9, color: AppColors.ink500),
                ),
                Row(
                  children: [
                    Text(
                      value,
                      style: AppTypography.body(13, weight: FontWeight.w700),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 4),
                      Text(trailing!),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}