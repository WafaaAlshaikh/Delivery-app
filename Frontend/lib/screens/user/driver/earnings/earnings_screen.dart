// lib/screens/user/driver/earnings/earnings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:frontend/screens/user/driver/earnings/widgets/comparison_card.dart';
import 'package:frontend/screens/user/driver/earnings/widgets/trend_analysis_card.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../providers/earnings_provider.dart';
import 'widgets/ai_assistant_card.dart';
import 'widgets/earnings_summary_card.dart';
import 'widgets/earnings_chart.dart';
import 'widgets/earnings_history_list.dart';
import 'widgets/period_selector.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          ref.read(earningsProvider.notifier).loadAllData();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final earningsState = ref.watch(earningsProvider);
    final notifier = ref.read(earningsProvider.notifier);

    if (earningsState.isLoading && earningsState.summary == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading earnings data...'),
            ],
          ),
        ),
      );
    }

    if (earningsState.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                earningsState.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => notifier.refreshData(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => notifier.loadAllData(),
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(
                  '💰 My Earnings',
                  style: AppTypography.display(22, weight: FontWeight.w800),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
                actions: [
                  IconButton(
                    onPressed: earningsState.isExporting
                        ? null
                        : () => _showExportDialog(context, notifier),
                    icon: earningsState.isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : const Icon(Icons.file_download_outlined),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      if (earningsState.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else ...[
                        if (earningsState.aiPrediction != null)
                          AIAssistantCard(
                            prediction: earningsState.aiPrediction!,
                            summary: earningsState.summary,
                          ).animate().fadeIn(duration: 300.ms).slideY(),

                        const SizedBox(height: 16),

                        if (earningsState.summary != null)
                          EarningsSummaryCard(
                            summary: earningsState.summary!,
                          ).animate().fadeIn(duration: 300.ms).slideY(),

                        const SizedBox(height: 16),

                        PeriodSelector(
                          selectedPeriod: earningsState.selectedPeriod,
                          onPeriodChanged: (period) {
                            notifier.changePeriod(period);
                          },
                        ).animate().fadeIn(duration: 300.ms).slideY(),

                        const SizedBox(height: 12),

                        if (earningsState.summary != null)
  ComparisonCard(
    currentPeriod: earningsState.summary!.weeklyEarnings,
    previousPeriod: earningsState.summary!.weeklyEarnings * 0.8, 
    periodLabel: 'Last Week',
  ).animate().fadeIn(duration: 300.ms).slideY(),

const SizedBox(height: 16),

if (earningsState.history.isNotEmpty)
  TrendAnalysisCard(
    dataPoints: earningsState.history.map((e) => e.total).toList(),
    labels: earningsState.history.map((e) => '${e.date.day}/${e.date.month}').toList(),
  ).animate().fadeIn(duration: 300.ms).slideY(),

                        if (earningsState.chartData != null)
                          EarningsChart(
                            chartData: earningsState.chartData!,
                            period: earningsState.selectedPeriod,
                          ).animate().fadeIn(duration: 300.ms).slideY(),

                        const SizedBox(height: 16),

                        EarningsHistoryList(
                          earnings: earningsState.history,
                        ).animate().fadeIn(duration: 300.ms).slideY(),

                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, EarningsNotifier notifier) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '📄 Export Report',
              style: AppTypography.display(20, weight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose format to export your earnings report',
              style: AppTypography.body(14, color: AppColors.ink500),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _ExportOption(
                    icon: Icons.picture_as_pdf,
                    label: 'PDF',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      notifier.exportReport('pdf');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}