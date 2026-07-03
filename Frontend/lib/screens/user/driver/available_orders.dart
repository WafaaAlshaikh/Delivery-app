// lib/screens/driver/available_orders.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../providers/driver_provider.dart';

class AvailableOrders extends ConsumerWidget {
  const AvailableOrders({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverState = ref.watch(driverProvider);

    // ✅ بيانات وهمية للطلبات المتاحة
    final orders = [
      {
        'id': 1,
        'store': 'Pizza Palace',
        'distance': '2.5 km',
        'earning': '\$8.50',
        'customer': 'Ahmed Mohamed',
        'address': '123 Main St, Cairo',
      },
      {
        'id': 2,
        'store': 'Burger House',
        'distance': '1.8 km',
        'earning': '\$6.00',
        'customer': 'Sara Ali',
        'address': '45 Nile St, Cairo',
      },
      {
        'id': 3,
        'store': 'Sushi King',
        'distance': '3.2 km',
        'earning': '\$12.00',
        'customer': 'Mohammed Hassan',
        'address': '78 Zamalek, Cairo',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Available Orders',
                style: AppTypography.display(18, weight: FontWeight.w700),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${orders.length} available',
                  style: AppTypography.body(
                    12,
                    weight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ✅ إذا كان السائق Offline
          if (!driverState.isOnline)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.errorSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You are offline. Go online to see available orders.',
                      style: AppTypography.body(14, color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),

          if (driverState.isOnline)
            ...orders.map((order) => _AvailableOrderCard(order: order)),
        ],
      ),
    );
  }
}

class _AvailableOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const _AvailableOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
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
                'Pickup: ${order['store']}',
                style: AppTypography.body(14, weight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order['distance'],
                  style: AppTypography.body(
                    11,
                    weight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Customer: ${order['customer']}',
            style: AppTypography.body(12, color: AppColors.ink500),
          ),
          Text(
            order['address'],
            style: AppTypography.body(12, color: AppColors.ink500),
          ),
          const SizedBox(height: 4),
          Text(
            'Earning: ${order['earning']}',
            style: AppTypography.body(
              14,
              weight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: قبول الطلب
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order #${order['id']} accepted!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Accept Order'),
            ),
          ),
        ],
      ),
    );
  }
}