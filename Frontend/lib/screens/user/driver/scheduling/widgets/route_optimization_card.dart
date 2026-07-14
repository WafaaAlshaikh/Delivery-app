// lib/screens/user/driver/scheduling/widgets/route_optimization_card.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/typography.dart';
import '../../../../../data/models/scheduled_order_model.dart';

class RouteOptimizationCard extends StatelessWidget {
  final RouteOptimization optimization;

  const RouteOptimizationCard({super.key, required this.optimization});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.route, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Text(
                '🗺️ المسار الأمثل',
                style: AppTypography.display(16, weight: FontWeight.w700),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${optimization.route.length} طلبات',
                  style: AppTypography.body(11, color: Colors.green.shade700, weight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatItem(
                icon: Icons.straighten, 
                label: 'المسافة',
                value: '${optimization.totalDistance} كم',
              ),
              _StatItem(
                icon: Icons.timer,
                label: 'الوقت المتوقع',
                value: optimization.totalTimeDisplay,
              ),
              _StatItem(
                icon: Icons.attach_money,
                label: 'الأرباح المتوقعة',
                value: '\$${optimization.estimatedEarnings.toStringAsFixed(2)}',
                color: Colors.green,
              ),
            ],
          ),
          if (optimization.route.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'ترتيب الطلبات:',
              style: AppTypography.body(12, color: AppColors.ink500),
            ),
            const SizedBox(height: 8),
            ...optimization.route.asMap().entries.map((entry) {
              final index = entry.key;
              final order = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        order.orderNumber,
                        style: AppTypography.body(13),
                      ),
                    ),
                    Text(
                      '\$${order.finalAmount.toStringAsFixed(2)}',
                      style: AppTypography.body(13, weight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color ?? AppColors.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.ink900,
            ),
          ),
          Text(
            label,
            style: AppTypography.body(10, color: AppColors.ink500),
          ),
        ],
      ),
    );
  }
}