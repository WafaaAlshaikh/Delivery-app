// lib/screens/driver/earnings.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../providers/driver_provider.dart';

class Earnings extends ConsumerWidget {
  const Earnings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverState = ref.watch(driverProvider);
    final stats = driverState.stats ?? {};

    final transactions = [
      {'order': '001', 'date': '2024-01-15', 'amount': '\$8.50'},
      {'order': '002', 'date': '2024-01-16', 'amount': '\$6.00'},
      {'order': '003', 'date': '2024-01-17', 'amount': '\$12.00'},
      {'order': '004', 'date': '2024-01-18', 'amount': '\$7.50'},
      {'order': '005', 'date': '2024-01-19', 'amount': '\$9.00'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.routeGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Total Earnings',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${(stats['total_earnings'] ?? 0.0).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _EarningStat(
                      label: 'Deliveries',
                      value: '${stats['total_deliveries'] ?? 0}',
                    ),
                    _EarningStat(
                      label: 'Rating',
                      value: '${stats['rating']?.toStringAsFixed(1) ?? '0.0'} ⭐',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Text(
                'Recent Transactions',
                style: AppTypography.display(18, weight: FontWeight.w700),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...transactions.map((transaction) => _TransactionCard(
                order: transaction['order']!,
                date: transaction['date']!,
                amount: transaction['amount']!,
              )),
        ],
      ),
    );
  }
}

class _EarningStat extends StatelessWidget {
  final String label;
  final String value;

  const _EarningStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final String order;
  final String date;
  final String amount;

  const _TransactionCard({
    required this.order,
    required this.date,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #ORD-2024-$order',
                    style: AppTypography.body(14, weight: FontWeight.w600),
                  ),
                  Text(
                    date,
                    style: AppTypography.body(12, color: AppColors.ink500),
                  ),
                ],
              ),
            ],
          ),
          Text(
            amount,
            style: AppTypography.body(
              14,
              weight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}