// lib/screens/user/driver/earnings/widgets/earnings_history_list.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/typography.dart';
import '../../../../../data/models/earning_model.dart';

class EarningsHistoryList extends StatelessWidget {
  final List<EarningModel> earnings;

  const EarningsHistoryList({super.key, required this.earnings});

  @override
  Widget build(BuildContext context) {
    if (earnings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            Text(
              'No earnings history yet',
              style: AppTypography.body(14, color: AppColors.ink500),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '📋 Recent Transactions',
              style: AppTypography.display(16, weight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: AppTypography.body(12, weight: FontWeight.w600, color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...earnings.take(10).map((earning) => _EarningHistoryItem(earning: earning)),
      ],
    );
  }
}

class _EarningHistoryItem extends StatelessWidget {
  final EarningModel earning;

  const _EarningHistoryItem({required this.earning});

  @override
  Widget build(BuildContext context) {
    final statusColor = earning.status == 'completed'
        ? AppColors.success
        : earning.status == 'pending'
            ? Colors.orange
            : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              earning.status == 'completed'
                  ? Icons.check_circle
                  : earning.status == 'pending'
                      ? Icons.hourglass_empty
                      : Icons.cancel,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  earning.customerName,
                  style: AppTypography.body(13, weight: FontWeight.w600),
                ),
                Text(
                  '${earning.date.day}/${earning.date.month}/${earning.date.year} • ${earning.duration} min',
                  style: AppTypography.body(11, color: AppColors.ink500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${earning.total.toStringAsFixed(2)}',
                style: AppTypography.body(15, weight: FontWeight.w700, color: statusColor),
              ),
              Row(
                children: [
                  Icon(Icons.star, size: 12, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(
                    earning.rating.toStringAsFixed(1),
                    style: AppTypography.body(11, color: AppColors.ink500),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}