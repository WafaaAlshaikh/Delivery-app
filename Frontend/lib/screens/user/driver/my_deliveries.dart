// lib/screens/driver/my_deliveries.dart
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class MyDeliveries extends StatelessWidget {
  const MyDeliveries({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ بيانات وهمية
    final deliveries = [
      {
        'id': '001',
        'store': 'Pizza Palace',
        'customer': 'Ahmed Mohamed',
        'address': '123 Main St, Cairo',
        'status': 'In Progress',
        'statusColor': AppColors.primary,
        'statusBgColor': AppColors.primarySoft,
      },
      {
        'id': '002',
        'store': 'Burger House',
        'customer': 'Sara Ali',
        'address': '45 Nile St, Cairo',
        'status': 'Completed',
        'statusColor': AppColors.success,
        'statusBgColor': AppColors.successSoft,
      },
      {
        'id': '003',
        'store': 'Sushi King',
        'customer': 'Mohammed Hassan',
        'address': '78 Zamalek, Cairo',
        'status': 'In Progress',
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
            'My Deliveries',
            style: AppTypography.display(18, weight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...deliveries.map((delivery) => _DeliveryCard(delivery: delivery)),
        ],
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final Map<String, dynamic> delivery;

  const _DeliveryCard({required this.delivery});

  @override
  Widget build(BuildContext context) {
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
                'Order #ORD-2024-${delivery['id']}',
                style: AppTypography.body(14, weight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: delivery['statusBgColor'],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  delivery['status'],
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
            'Pickup: ${delivery['store']}',
            style: AppTypography.body(12, color: AppColors.ink500),
          ),
          Text(
            'Delivery: ${delivery['customer']}',
            style: AppTypography.body(12, color: AppColors.ink500),
          ),
          Text(
            delivery['address'],
            style: AppTypography.body(12, color: AppColors.ink500),
          ),
          const SizedBox(height: 8),
          if (delivery['status'] == 'In Progress')
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: تحديث حالة التوصيل
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order marked as delivered!'),
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
                child: const Text('Mark as Delivered'),
              ),
            ),
        ],
      ),
    );
  }
}