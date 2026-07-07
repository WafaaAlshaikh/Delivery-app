// lib/widgets/order/order_status_timeline.dart
import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../data/models/order_model.dart';

class OrderStatusTimeline extends StatelessWidget {
  final OrderModel order;

  const OrderStatusTimeline({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final statuses = _getStatuses(tr);
    final currentIndex = _getCurrentStatusIndex(order.status.statusId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr.t('order_progress'),
            style: AppTypography.display(14, weight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Row(
            children: statuses.asMap().entries.map((entry) {
              final index = entry.key;
              final status = entry.value;
              final isCompleted = index <= currentIndex;
              final isCurrent = index == currentIndex;

              return Expanded(
                child: Column(
                  children: [
                    if (index > 0)
                      Container(
                        height: 2,
                        color: isCompleted ? AppColors.primary : AppColors.border,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                      ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? AppColors.primary : AppColors.surfaceSunken,
                        border: Border.all(
                          color: isCurrent ? AppColors.primary : AppColors.border,
                          width: isCurrent ? 3 : 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          isCompleted ? Icons.check : status.icon,
                          size: 16,
                          color: isCompleted ? Colors.white : AppColors.ink500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status.label,
                      style: AppTypography.body(
                        10,
                        color: isCompleted ? AppColors.primary : AppColors.ink500,
                        weight: isCompleted ? FontWeight.w700 : FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<_StatusItem> _getStatuses(AppLocalizations tr) {
    return [
      _StatusItem(Icons.receipt_long, tr.t('status_placed')),
      _StatusItem(Icons.check_circle, tr.t('status_accepted')),
      _StatusItem(Icons.restaurant, tr.t('status_preparing')),
      _StatusItem(Icons.delivery_dining, tr.t('status_out_for_delivery')),
      _StatusItem(Icons.home, tr.t('status_delivered')),
    ];
  }

  int _getCurrentStatusIndex(int statusId) {
    switch (statusId) {
      case 1:
        return 0; 
      case 2:
        return 1; 
      case 3:
      case 4:
        return 2; 
      case 5:
      case 6:
      case 7:
        return 3; 
      case 8:
        return 4; 
      default:
        return 0;
    }
  }
}

class _StatusItem {
  final IconData icon;
  final String label;

  _StatusItem(this.icon, this.label);
}