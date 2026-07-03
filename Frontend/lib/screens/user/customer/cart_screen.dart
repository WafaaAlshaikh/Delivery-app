// lib/screens/customer/cart_screen.dart
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.ink300,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: AppTypography.display(20, weight: FontWeight.w700, color: AppColors.ink500),
          ),
          const SizedBox(height: 8),
          Text(
            'Start shopping to add items to your cart',
            style: AppTypography.body(14, color: AppColors.ink300),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: رجوع للتصفح
            },
            child: const Text('Browse Stores'),
          ),
        ],
      ),
    );
  }
}