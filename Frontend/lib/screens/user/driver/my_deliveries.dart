// lib/screens/driver/my_deliveries.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class MyDeliveries extends ConsumerWidget {
  const MyDeliveries({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    
    final deliveries = [
      {
        'id': '001',
        'store': 'Pizza Palace',
        'customer': 'Ahmed Mohamed',
        'address': '123 Main St, Cairo',
        'status': 'in_progress',
        'statusColor': AppColors.primary,
        'statusBgColor': AppColors.primarySoft,
      },
      {
        'id': '002',
        'store': 'Burger House',
        'customer': 'Sara Ali',
        'address': '45 Nile St, Cairo',
        'status': 'completed',
        'statusColor': AppColors.success,
        'statusBgColor': AppColors.successSoft,
      },
      {
        'id': '003',
        'store': 'Sushi King',
        'customer': 'Mohammed Hassan',
        'address': '78 Zamalek, Cairo',
        'status': 'in_progress',
        'statusColor': AppColors.primary,
        'statusBgColor': AppColors.primarySoft,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr.t('my_deliveries'),
            style: AppTypography.display(18, weight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...deliveries.map((delivery) => _DeliveryCard(
                delivery: delivery,
                tr: tr,
              )),
        ],
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final Map<String, dynamic> delivery;
  final AppLocalizations tr;

  const _DeliveryCard({
    required this.delivery,
    required this.tr,
  });

  String _getStatusText(String status) {
    switch (status) {
      case 'in_progress':
        return tr.t('status_in_progress');
      case 'completed':
        return tr.t('status_completed');
      case 'pending':
        return tr.t('status_pending');
      case 'cancelled':
        return tr.t('status_cancelled');
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = delivery['status'] ?? 'pending';
    final statusText = _getStatusText(status);
    final isInProgress = status == 'in_progress';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${tr.t('order')} #ORD-2024-${delivery['id']}',
                style: AppTypography.body(14, weight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: delivery['statusBgColor'],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: AppTypography.body(
                    11,
                    weight: FontWeight.w600,
                    color: delivery['statusColor'],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${tr.t('pickup')}: ${delivery['store']}',
            style: AppTypography.body(12, color: AppColors.ink500),
          ),
          Text(
            '${tr.t('delivery_to')}: ${delivery['customer']}',
            style: AppTypography.body(12, color: AppColors.ink500),
          ),
          Text(
            delivery['address'],
            style: AppTypography.body(12, color: AppColors.ink500),
          ),
          const SizedBox(height: 8),
          if (isInProgress)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: تحديث حالة التوصيل
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ ${tr.t('order_marked_delivered')}'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(tr.t('mark_as_delivered')),
              ),
            ),
        ],
      ),
    );
  }
}