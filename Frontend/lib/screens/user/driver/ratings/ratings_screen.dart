// lib/screens/user/driver/ratings/ratings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../providers/ratings_provider.dart';
import '../../../../data/models/rating_model.dart';
import '../../../../services/rating_report_service.dart';
import 'widgets/rating_summary_card.dart';
import 'widgets/sentiment_chart.dart';
import 'widgets/ai_insights_card.dart';
import 'widgets/improvement_suggestions.dart';
import 'widgets/rating_item.dart';
import 'widgets/filter_chips.dart';
import 'analytics/period_filter.dart';
import 'analytics/city_rating_analytics.dart';
import 'analytics/driver_ranking_screen.dart'; 

class RatingsScreen extends ConsumerStatefulWidget {
  const RatingsScreen({super.key});

  @override
  ConsumerState<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends ConsumerState<RatingsScreen> {
  Period _selectedPeriod = Period.month;
  bool _isExporting = false;
  bool _showAnalytics = false; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          ref.read(ratingsProvider.notifier).loadAllData();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ratingsProvider);
    final notifier = ref.read(ratingsProvider.notifier);

    if (state.isLoading && state.summary == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading ratings...'),
            ],
          ),
        ),
      );
    }

    if (state.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                state.error!,
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
      appBar: AppBar(
        title: Text(
          '⭐ My Ratings',
          style: AppTypography.display(20, weight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.analytics_outlined),
            onSelected: (value) {
              if (value == 'city_analytics') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CityRatingAnalytics(),
                  ),
                );
              } else if (value == 'driver_ranking') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DriverRankingScreen(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'city_analytics',
                child: Row(
                  children: [
                    Icon(Icons.location_city, size: 18),
                    SizedBox(width: 8),
                    Text('📍 City Analytics'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'driver_ranking',
                child: Row(
                  children: [
                    Icon(Icons.emoji_events, size: 18),
                    SizedBox(width: 8),
                    Text('🏆 Driver Ranking'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.file_download_outlined),
            onSelected: (value) async {
              if (value == 'export_ratings') {
                await _exportRatingReport(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_ratings',
                child: Row(
                  children: [
                    Icon(Icons.rate_review, size: 18),
                    SizedBox(width: 8),
                    Text('Export Ratings Report'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => notifier.refreshData(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.refreshData(),
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildAnalyticsCards(context),
                    const SizedBox(height: 16),

                    if (state.aiInsights != null)
                      AIInsightsCard(
                        insights: state.aiInsights!,
                      ).animate().fadeIn(duration: 300.ms).slideY(),

                    const SizedBox(height: 16),

                    if (state.summary != null)
                      RatingSummaryCard(
                        summary: state.summary!,
                      ).animate().fadeIn(duration: 300.ms).slideY(),

                    const SizedBox(height: 16),

                    if (state.summary != null)
                      SentimentChart(
                        summary: state.summary!,
                      ).animate().fadeIn(duration: 300.ms).slideY(),

                    const SizedBox(height: 16),

                    if (state.aiInsights != null)
                      ImprovementSuggestions(
                        insights: state.aiInsights!,
                      ).animate().fadeIn(duration: 300.ms).slideY(),

                    const SizedBox(height: 16),

                    PeriodFilter(
                      selectedPeriod: _selectedPeriod,
                      onPeriodChanged: (period) {
                        setState(() {
                          _selectedPeriod = period;
                        });
                        _loadDataForPeriod(period, notifier, state);
                      },
                      counts: _getPeriodCounts(state),
                    ).animate().fadeIn(duration: 300.ms).slideY(),

                    const SizedBox(height: 12),

                    FilterChips(
                      selectedFilter: state.selectedFilter,
                      onFilterChanged: (filter) {
                        notifier.changeFilter(filter);
                      },
                      counts: _getFilterCounts(state),
                    ).animate().fadeIn(duration: 300.ms).slideY(),

                    const SizedBox(height: 12),

                    if (state.ratings.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.rate_review_outlined,
                                  size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'No ratings yet',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                'Complete deliveries to get ratings',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...state.ratings.map((rating) =>
                        RatingItem(rating: rating)
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideY(delay: Duration(milliseconds: 100 * state.ratings.indexOf(rating)))
                      ),

                    if (state.hasMoreData && !state.isLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: TextButton(
                            onPressed: () => notifier.loadMore(),
                            child: const Text('Load More'),
                          ),
                        ),
                      ),

                    if (state.isLoading && state.ratings.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AnalyticsCard(
            icon: Icons.location_city,
            title: 'City Analytics',
            subtitle: 'View ratings by city',
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CityRatingAnalytics(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _AnalyticsCard(
            icon: Icons.emoji_events,
            title: 'Driver Ranking',
            subtitle: 'Compare with others',
            color: Colors.amber,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DriverRankingScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _loadDataForPeriod(Period period, RatingsNotifier notifier, RatingsState state) {
    final now = DateTime.now();
    final filteredRatings = state.ratings.where((r) {
      switch (period) {
        case Period.day:
          return r.date.isAfter(now.subtract(const Duration(days: 1)));
        case Period.week:
          return r.date.isAfter(now.subtract(const Duration(days: 7)));
        case Period.month:
          return r.date.isAfter(now.subtract(const Duration(days: 30)));
        case Period.year:
          return r.date.isAfter(now.subtract(const Duration(days: 365)));
      }
    }).toList();
  }

  Map<Period, int> _getPeriodCounts(RatingsState state) {
    final now = DateTime.now();
    return {
      Period.day: state.ratings.where((r) => 
        r.date.isAfter(now.subtract(const Duration(days: 1)))
      ).length,
      Period.week: state.ratings.where((r) => 
        r.date.isAfter(now.subtract(const Duration(days: 7)))
      ).length,
      Period.month: state.ratings.where((r) => 
        r.date.isAfter(now.subtract(const Duration(days: 30)))
      ).length,
      Period.year: state.ratings.where((r) => 
        r.date.isAfter(now.subtract(const Duration(days: 365)))
      ).length,
    };
  }

  Future<void> _exportRatingReport(BuildContext context) async {
    if (_isExporting) return;
    
    try {
      setState(() => _isExporting = true);

      final month = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2024, 1),
        lastDate: DateTime.now(),
        helpText: 'Select Month for Report',
      );

      if (month == null) {
        setState(() => _isExporting = false);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Generating report...'),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );

      final service = RatingReportService();
      final file = await service.generateRatingReport(
        DateTime(month.year, month.month, 1),
      );

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '📊 Monthly Rating Report - ${month.year}/${month.month}',
      );

      setState(() => _isExporting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Report exported successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() => _isExporting = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to generate report: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Map<String, int> _getFilterCounts(RatingsState state) {
    return {
      'all': state.ratings.length,
      'positive': state.ratings.where((r) => r.sentiment == SentimentType.positive).length,
      'neutral': state.ratings.where((r) => r.sentiment == SentimentType.neutral).length,
      'negative': state.ratings.where((r) => r.sentiment == SentimentType.negative).length,
    };
  }
}

class _AnalyticsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AnalyticsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body(14, weight: FontWeight.w700),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.body(11, color: AppColors.ink500),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}