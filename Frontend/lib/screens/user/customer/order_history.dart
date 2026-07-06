// lib/screens/customer/order_history.dart
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/user_model.dart';

class OrderHistory extends StatelessWidget {
  final UserModel? user;

  const OrderHistory({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order History',
            style: AppTypography.display(18, weight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...List.generate(3, (index) => _OrderHistoryCard(index: index)), // ✅ إضافة index
        ],
      ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  final int index; 

  const _OrderHistoryCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final statuses = ['Delivered', 'Processing', 'Pending'];
    final colors = [AppColors.success, AppColors.primary, AppColors.warning];
    final bgColors = [AppColors.successSoft, AppColors.primarySoft, AppColors.goldSoft];
    
    final status = statuses[index % statuses.length];
    final color = colors[index % colors.length];
    final bgColor = bgColors[index % bgColors.length];

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
                'Order #ORD-2024-00${index + 1}', 
                style: AppTypography.body(14, weight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: AppTypography.body(11, weight: FontWeight.w600, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Total: \$${(index + 1) * 15 + 30}.00', 
            style: AppTypography.body(14, weight: FontWeight.w700, color: AppColors.primary),
          ),
          Text(
            'Date: 2024-01-${15 + index}', 
            style: AppTypography.body(12, color: AppColors.ink500),
          ),
        ],
      ),
    );
  }
}