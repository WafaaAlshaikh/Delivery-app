// lib/screens/admin/admin_reports.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../providers/admin_provider.dart';

class AdminReports extends ConsumerWidget {
  const AdminReports({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    final dashboardAsync = ref.watch(adminDashboardProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: dashboardAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr.t('reports_and_insights'),
                style: AppTypography.display(18, weight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                tr.t('reports_subtitle'),
                style: AppTypography.body(13, color: AppColors.ink500),
              ),
              const SizedBox(height: 20),
              _UserBreakdownCard(data: data),
              const SizedBox(height: 16),
              _OrdersBarChartCard(data: data),
              const SizedBox(height: 16),
              _NoteCard(),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            '${tr.t('error')}: $error',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}

class _UserBreakdownCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _UserBreakdownCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final users = data['users'] ?? {};
    final total = (users['total'] ?? 0).toDouble();
    final merchants = (users['merchants'] ?? 0).toDouble();
    final drivers = (users['drivers'] ?? 0).toDouble();
    final customers = (total - merchants - drivers).clamp(0, double.infinity);

    final rows = [
      (tr.t('customers'), customers, AppColors.roleCustomer),
      (tr.t('merchants'), merchants, AppColors.roleMerchant),
      (tr.t('drivers'), drivers, AppColors.roleDriver),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr.t('user_base_breakdown'),
            style: AppTypography.display(15, weight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          for (final row in rows) ...[
            _BarRow(
              label: row.$1,
              value: row.$2,
              total: total <= 0 ? 1 : total,
              color: row.$3,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final double value;
  final double total;
  final Color color;

  const _BarRow({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (value / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.body(12, weight: FontWeight.w600, color: AppColors.ink700),
            ),
            Text(
              value.toInt().toString(),
              style: AppTypography.body(12, weight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            backgroundColor: AppColors.surfaceSunken,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _OrdersBarChartCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _OrdersBarChartCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final orders = data['orders'] ?? {};
    final total = (orders['total'] ?? 0).toDouble();
    final active = (orders['active'] ?? 0).toDouble();
    final completed = (total - active).clamp(0, double.infinity);

    final bars = [
      (tr.t('active'), active, AppColors.primary),
      (tr.t('completed'), completed, AppColors.success),
      (tr.t('total'), total, AppColors.accent),
    ];
    final maxY = (total <= 0 ? 1 : total) * 1.25;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr.t('orders_snapshot'),
            style: AppTypography.display(15, weight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= bars.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            bars[i].$1,
                            style: AppTypography.body(11, color: AppColors.ink500),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (int i = 0; i < bars.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: bars[i].$2,
                          color: bars[i].$3,
                          width: 34,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard();

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.accentDark,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tr.t('reports_note'),
              style: AppTypography.body(
                12,
                color: AppColors.accentDark,
                weight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}