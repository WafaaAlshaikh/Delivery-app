// lib/screens/merchant/merchant_orders.dart
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class MerchantOrders extends StatelessWidget {
  const MerchantOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Orders',
            style: AppTypography.display(18, weight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          // ✅ تمرير index لكل بطاقة
          ...List.generate(3, (index) => _MerchantOrderCard(index: index)), // ✅ إضافة index
        ],
      ),
    );
  }
}

class _MerchantOrderCard extends StatelessWidget {
  final int index; // ✅ إضافة index كـ parameter

  const _MerchantOrderCard({required this.index}); // ✅ constructor مع index

  @override
  Widget build(BuildContext context) {
    // ✅ قائمة العملاء والأسعار والحالات
    final customers = ['Ahmed Mohamed', 'Sara Ali', 'Mohammed Hassan'];
    final totals = ['\$45.00', '\$67.50', '\$23.00'];
    final statuses = ['Pending', 'Pending', 'Accepted'];
    final colors = [AppColors.warning, AppColors.warning, AppColors.success];
    final bgColors = [AppColors.goldSoft, AppColors.goldSoft, AppColors.successSoft];

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
                'Order #ORD-2024-00${index + 1}', // ✅ استخدام index
                style: AppTypography.body(14, weight: FontWeight.w600),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: bgColors[index % bgColors.length],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statuses[index % statuses.length],
                      style: AppTypography.body(10, weight: FontWeight.w600, color: colors[index % colors.length]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ✅ إظهار زر Accept فقط إذا كانت الحالة Pending
                  if (statuses[index % statuses.length] == 'Pending')
                    ElevatedButton(
                      onPressed: () {
                        // TODO: قبول الطلب
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Accept'),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Customer: ${customers[index % customers.length]}', // ✅ استخدام index
            style: AppTypography.body(12, color: AppColors.ink500),
          ),
          Text(
            'Total: ${totals[index % totals.length]}', // ✅ استخدام index
            style: AppTypography.body(12, color: AppColors.ink500),
          ),
        ],
      ),
    );
  }
}