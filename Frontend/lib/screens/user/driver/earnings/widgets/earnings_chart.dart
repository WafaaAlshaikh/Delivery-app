// lib/screens/user/driver/earnings/widgets/earnings_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/typography.dart';
import '../../../../../data/models/earning_model.dart';

class EarningsChart extends StatefulWidget {
  final EarningsChartData chartData;
  final String period;

  const EarningsChart({
    super.key,
    required this.chartData,
    required this.period,
  });

  @override
  State<EarningsChart> createState() => _EarningsChartState();
}

class _EarningsChartState extends State<EarningsChart> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spots = _getSpots();

    if (spots.isEmpty || spots.every((spot) => spot.y == 0)) {
      return Container(
        height: 220,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'No earnings data available',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Text(
                'Complete deliveries to see your earnings',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    maxY = maxY * 1.2;
    if (maxY <= 0) maxY = 100;

    double horizontalInterval = maxY / 4;
    if (horizontalInterval <= 0) horizontalInterval = 25;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getChartTitle(),
                    style: AppTypography.display(16, weight: FontWeight.w700),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Earnings',
                        style: AppTypography.body(10, weight: FontWeight.w700, color: AppColors.primaryDark),
                      ),
                      const SizedBox(width: 12),
                      if (_animation.value < 1)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: maxY,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: horizontalInterval,
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
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                '\$${value.toInt()}',
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
                            final index = value.toInt();
                            if (index < 0 || index >= spots.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _getLabel(index),
                                style: AppTypography.body(10, color: AppColors.ink500),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => AppColors.ink900,
                        getTooltipItems: (spots) => spots
                            .map((s) => LineTooltipItem(
                                  '\$${s.y.toStringAsFixed(2)}',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots.map((spot) {
                          return FlSpot(
                            spot.x,
                            spot.y * _animation.value,
                          );
                        }).toList(),
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
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
            ],
          ),
        );
      },
    );
  }

  List<FlSpot> _getSpots() {
    if (widget.period == 'daily') {
      return widget.chartData.daily.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.amount);
      }).toList();
    } else if (widget.period == 'weekly') {
      return widget.chartData.weekly.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.amount);
      }).toList();
    } else {
      return widget.chartData.monthly.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.amount);
      }).toList();
    }
  }

  String _getLabel(int index) {
    if (widget.period == 'daily') {
      if (index < widget.chartData.daily.length) {
        final day = widget.chartData.daily[index];
        return '${day.date.day}/${day.date.month}';
      }
    } else if (widget.period == 'weekly') {
      if (index < widget.chartData.weekly.length) {
        return widget.chartData.weekly[index].week;
      }
    } else {
      if (index < widget.chartData.monthly.length) {
        return widget.chartData.monthly[index].month;
      }
    }
    return '';
  }

  String _getChartTitle() {
    switch (widget.period) {
      case 'daily':
        return '📈 Daily Earnings';
      case 'weekly':
        return '📈 Weekly Earnings';
      case 'monthly':
        return '📈 Monthly Earnings';
      default:
        return '📈 Earnings';
    }
  }
}