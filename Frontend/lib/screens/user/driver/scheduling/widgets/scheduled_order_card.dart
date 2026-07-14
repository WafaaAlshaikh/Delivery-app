// lib/screens/user/driver/scheduling/widgets/scheduled_order_card.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/typography.dart';
import '../../../../../data/models/scheduled_order_model.dart';

class ScheduledOrderCard extends StatelessWidget {
  final ScheduledOrder scheduledOrder;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ScheduledOrderCard({
    super.key,
    required this.scheduledOrder,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final status = scheduledOrder.status;
    final order = scheduledOrder.order;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: status.color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(status.icon, color: status.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order?.orderNumber ?? 'طلب #${scheduledOrder.orderId}',
                      style: AppTypography.body(14, weight: FontWeight.w600),
                    ),
                    Text(
                      scheduledOrder.dateDisplay,
                      style: AppTypography.body(12, color: AppColors.ink500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: status.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _DetailChip(
                icon: Icons.access_time,
                label: scheduledOrder.timeDisplay,
              ),
              const SizedBox(width: 8),
              if (scheduledOrder.routeOrder != null)
                _DetailChip(
                  icon: Icons.numbers,
                  label: '#${scheduledOrder.routeOrder} في المسار',
                ),
              const SizedBox(width: 8),
              if (scheduledOrder.priority > 0)
                _DetailChip(
                  icon: Icons.star,
                  label: 'أولوية ${scheduledOrder.priority}',
                  color: Colors.amber,
                ),
            ],
          ),

          if (order?.customer != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: AppColors.ink500),
                const SizedBox(width: 6),
                Text(
                  order!.customer!.fullName,
                  style: AppTypography.body(12, color: AppColors.ink700),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.ink500),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.deliveryAddress,
                    style: AppTypography.body(12, color: AppColors.ink700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          if (status == ScheduleStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('تأكيد'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _DetailChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color ?? AppColors.ink500),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.body(10, color: color ?? AppColors.ink500),
          ),
        ],
      ),
    );
  }
}