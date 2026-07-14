// lib/screens/user/driver/ratings/analytics/city_rating_analytics.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/typography.dart';
import '../../../../../services/rating_analytics_service.dart';

class CityRatingAnalytics extends ConsumerStatefulWidget {
  const CityRatingAnalytics({super.key});

  @override
  ConsumerState<CityRatingAnalytics> createState() => _CityRatingAnalyticsState();
}

class _CityRatingAnalyticsState extends ConsumerState<CityRatingAnalytics> {
  Map<String, CityRatingStats>? _cityStats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = RatingAnalyticsService();
      final stats = await service.getAverageRatingByCity();
      setState(() {
        _cityStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_cityStats == null || _cityStats!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_city, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No city data available'),
          ],
        ),
      );
    }

    final cities = _cityStats!.keys.toList();
    final sortedCities = cities
        .map((city) => _cityStats![city]!)
        .toList()
      ..sort((a, b) => b.averageRating.compareTo(a.averageRating));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '📍 Ratings by City',
                style: AppTypography.display(18, weight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...sortedCities.map((city) => _CityRatingCard(city: city)),

          const SizedBox(height: 16),

          _CityComparisonChart(cities: sortedCities),
        ],
      ),
    );
  }
}

class _CityRatingCard extends StatelessWidget {
  final CityRatingStats city;

  const _CityRatingCard({required this.city});

  @override
  Widget build(BuildContext context) {
    final color = city.averageRating >= 4.5
        ? Colors.green
        : city.averageRating >= 3.5
            ? Colors.orange
            : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                city.city,
                style: AppTypography.display(16, weight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  city.averageRating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _sentimentChip(
                '😊 ${city.positivePercentage.toStringAsFixed(0)}%',
                Colors.green,
              ),
              const SizedBox(width: 8),
              _sentimentChip(
                '😐 ${city.neutralPercentage.toStringAsFixed(0)}%',
                Colors.orange,
              ),
              const SizedBox(width: 8),
              _sentimentChip(
                '😞 ${city.negativePercentage.toStringAsFixed(0)}%',
                Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${city.totalRatings} reviews',
            style: AppTypography.body(12, color: AppColors.ink500),
          ),
          if (city.topKeywords.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: city.topKeywords.map((keyword) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '#$keyword',
                    style: AppTypography.body(10, color: AppColors.ink500),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sentimentChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTypography.body(10, color: color, weight: FontWeight.w600),
      ),
    );
  }
}

class _CityComparisonChart extends StatelessWidget {
  final List<CityRatingStats> cities;

  const _CityComparisonChart({required this.cities});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 City Comparison',
            style: AppTypography.display(14, weight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: 5.5,
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.shade200,
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
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTypography.body(10, color: AppColors.ink500),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= cities.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            cities[index].city.length > 8
                                ? '${cities[index].city.substring(0, 6)}...'
                                : cities[index].city,
                            style: AppTypography.body(10, color: AppColors.ink500),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: cities.asMap().entries.map((entry) {
                  final index = entry.key;
                  final city = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: city.averageRating,
                        color: city.averageRating >= 4.5
                            ? Colors.green
                            : city.averageRating >= 3.5
                                ? Colors.orange
                                : Colors.red,
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}