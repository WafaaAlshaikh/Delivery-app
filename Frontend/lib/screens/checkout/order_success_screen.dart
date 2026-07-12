// lib/screens/checkout/order_success_screen.dart

import 'package:flutter/material.dart';
import '../landing/landing_screen.dart';
import '../orders/orders_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final List<String> orderNumbers;
  final bool hasPartialFailure;

  const OrderSuccessScreen({
    super.key,
    required this.orderNumbers,
    this.hasPartialFailure = false,
  });

  static const Color brandColor = Color(0xFF006D32);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: brandColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: brandColor,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Order Placed!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    orderNumbers.length > 1
                        ? 'Your ${orderNumbers.length} orders have been placed successfully.'
                        : 'Your order has been placed successfully.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: orderNumbers
                          .map(
                            (number) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    number,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Pending',
                                    style: TextStyle(color: Colors.orange[800], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  if (hasPartialFailure) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Note: some items from other stores in your cart could '
                      'not be ordered. Please try again for those.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.redAccent[700]),
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const OrdersScreen()),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Track My Orders',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: brandColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: brandColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LandingScreen()),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Continue Shopping',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
