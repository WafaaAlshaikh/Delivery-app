// lib/screens/user/driver/ratings/widgets/rating_summary_card.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/typography.dart';
import '../../../../../data/models/rating_model.dart';

class RatingSummaryCard extends StatelessWidget {
  final RatingsSummary summary;

  const RatingSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
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
        children: [
          Text(
            '⭐ Rating Overview',
            style: AppTypography.display(16, weight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text(
                      summary.averageRating.toStringAsFixed(1),
                      style: AppTypography.display(32, weight: FontWeight.w800),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final filled = index < summary.averageRating.round();
                        return Icon(
                          filled ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                    Text(
                      '${summary.totalRatings} reviews',
                      style: AppTypography.body(12, color: AppColors.ink500),
                    ),
                    if (summary.monthlyChange != 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            summary.monthlyChange > 0 ? Icons.trending_up : Icons.trending_down,
                            color: summary.monthlyChange > 0 ? Colors.green : Colors.red,
                            size: 14,
                          ),
                          Text(
                            '${summary.monthlyChange > 0 ? '+' : ''}${summary.monthlyChange.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: summary.monthlyChange > 0 ? Colors.green : Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'vs last month',
                            style: AppTypography.body(10, color: AppColors.ink300),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildDistributionBar('5 ★', summary.fiveStarCount, summary.totalRatings),
                    _buildDistributionBar('4 ★', summary.fourStarCount, summary.totalRatings),
                    _buildDistributionBar('3 ★', summary.threeStarCount, summary.totalRatings),
                    _buildDistributionBar('2 ★', summary.twoStarCount, summary.totalRatings),
                    _buildDistributionBar('1 ★', summary.oneStarCount, summary.totalRatings),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionBar(String label, int count, int total) {
    final percentage = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              label,
              style: AppTypography.body(10, color: AppColors.ink500),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getColorForRating(label),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(
              count.toString(),
              style: AppTypography.body(10, color: AppColors.ink500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForRating(String label) {
    switch (label) {
      case '5 ★':
        return Colors.green;
      case '4 ★':
        return Colors.lightGreen;
      case '3 ★':
        return Colors.orange;
      case '2 ★':
        return Colors.orange.shade700;
      case '1 ★':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}