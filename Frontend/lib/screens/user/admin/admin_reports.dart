// lib/screens/user/admin/admin_reports.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../providers/admin_provider.dart';
import '../../../data/models/admin_models.dart';

class AdminReports extends ConsumerStatefulWidget {
  const AdminReports({super.key});

  @override
  ConsumerState<AdminReports> createState() => _AdminReportsState();
}

class _AdminReportsState extends ConsumerState<AdminReports> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final dashboardState = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: dashboardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardState.error != null
              ? Center(
                  child: Text(
                    '${tr.t('error')}: ${dashboardState.error}',
                    style: const TextStyle(color: AppColors.error),
                  ),
                )
              : dashboardState.dashboardData == null
                  ? Center(
                      child: Text(
                        tr.t('no_data_yet'),
                        style: AppTypography.body(14, color: AppColors.ink500),
                      ),
                    )
                  : SingleChildScrollView(
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
                          _UserBreakdownCard(stats: dashboardState.dashboardData!),
                          const SizedBox(height: 16),
                          _OrdersBarChartCard(stats: dashboardState.dashboardData!),
                          const SizedBox(height: 16),
                          _OrdersByStatusCard(stats: dashboardState.dashboardData!),
                          const SizedBox(height: 16),
                          _NoteCard(),
                        ],
                      ),
                    ),
    );
  }
}

class _UserBreakdownCard extends StatelessWidget {
  final AdminDashboardStats stats;

  const _UserBreakdownCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final total = stats.totalUsers.toDouble();
    
    final merchants = stats.totalStores.toDouble();
    final drivers = (total - merchants).clamp(0, double.infinity);
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
          const SizedBox(height: 4),
          Text(
            '${tr.t('total_users')}: ${stats.totalUsers}',
            style: AppTypography.body(12, color: AppColors.ink500),
          ),
          const SizedBox(height: 18),
          for (final row in rows) ...[
            _BarRow(
              label: row.$1,
              value: (row.$2 as double),
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
  final AdminDashboardStats stats;

  const _OrdersBarChartCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final total = stats.totalOrders.toDouble();
    
    final activeFromStatus = stats.ordersByStatus
        .where((e) => e.status != 'Delivered' && e.status != 'Completed' && e.status != 'Cancelled' && e.status != 'Refunded')
        .fold<int>(0, (sum, e) => sum + e.count);
    
    final completedFromStatus = stats.ordersByStatus
        .where((e) => e.status == 'Delivered' || e.status == 'Completed')
        .fold<int>(0, (sum, e) => sum + e.count);

    final active = activeFromStatus > 0 ? activeFromStatus.toDouble() : (total * 0.3);
    final completed = completedFromStatus > 0 ? completedFromStatus.toDouble() : (total * 0.7);

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
          const SizedBox(height: 4),
          Text(
            '${tr.t('total_orders')}: ${stats.totalOrders}',
            style: AppTypography.body(12, color: AppColors.ink500),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 200,
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
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            value.toInt().toString(),
                            style: AppTypography.body(10, color: AppColors.ink500),
                          ),
                        );
                      },
                    ),
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

class _OrdersByStatusCard extends StatelessWidget {
  final AdminDashboardStats stats;

  const _OrdersByStatusCard({required this.stats});

  static const List<Color> _palette = [
    AppColors.primary,
    AppColors.accent,
    AppColors.gold,
    AppColors.roleCustomer,
    AppColors.roleAdmin,
    AppColors.success,
    AppColors.error,
  ];

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    if (stats.ordersByStatus.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            tr.t('no_data_yet'),
            style: AppTypography.body(14, color: AppColors.ink500),
          ),
        ),
      );
    }

    final entries = stats.ordersByStatus;
    final total = entries.fold<int>(0, (sum, e) => sum + e.count);

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
            tr.t('orders_by_status'),
            style: AppTypography.display(15, weight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${tr.t('total')}: $total',
            style: AppTypography.body(12, color: AppColors.ink500),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 180,
                      width: 180,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 50,
                          sections: [
                            for (int i = 0; i < entries.length; i++)
                              PieChartSectionData(
                                value: entries[i].count.toDouble(),
                                color: _palette[i % _palette.length],
                                title: '',
                                radius: 30,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          for (int i = 0; i < entries.length; i++)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _palette[i % _palette.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entries[i].status,
                                      style: AppTypography.body(12, weight: FontWeight.w600),
                                    ),
                                    Text(
                                      '${entries[i].count} (${((entries[i].count / total) * 100).toStringAsFixed(1)}%)',
                                      style: AppTypography.body(11, color: AppColors.ink500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  SizedBox(
                    height: 180,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 50,
                        sections: [
                          for (int i = 0; i < entries.length; i++)
                            PieChartSectionData(
                              value: entries[i].count.toDouble(),
                              color: _palette[i % _palette.length],
                              title: '',
                              radius: 30,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      for (int i = 0; i < entries.length; i++)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _palette[i % _palette.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entries[i].status,
                                  style: AppTypography.body(12, weight: FontWeight.w600),
                                ),
                                Text(
                                  '${entries[i].count} (${((entries[i].count / total) * 100).toStringAsFixed(1)}%)',
                                  style: AppTypography.body(11, color: AppColors.ink500),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              );
            },
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