// lib/screens/merchant/manage_products.dart
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class ManageProducts extends StatelessWidget {
  const ManageProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 80, color: AppColors.ink300),
          const SizedBox(height: 16),
          Text(
            'No Products Yet',
            style: AppTypography.display(20, weight: FontWeight.w700, color: AppColors.ink500),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first product',
            style: AppTypography.body(14, color: AppColors.ink300),
          ),
        ],
      ),
    );
  }
}