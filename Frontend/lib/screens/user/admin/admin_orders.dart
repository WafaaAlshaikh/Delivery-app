// lib/screens/admin/admin_orders.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../providers/admin_provider.dart';

class AdminOrders extends ConsumerStatefulWidget {
  const AdminOrders({super.key});

  @override
  ConsumerState<AdminOrders> createState() => _AdminOrdersState();
}

class _AdminOrdersState extends ConsumerState<AdminOrders> {
  int? _selectedStatus;
  int _currentPage = 1;

  static const _statusFilters = [
    (null, 'All'),
    (1, 'Pending'),
    (2, 'Accepted'),
    (8, 'Delivered'),
    (9, 'Cancelled'),
  ];

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(adminOrdersProvider({
      'status': _selectedStatus,
      'page': _currentPage,
    }));
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: isWide
          ? null
          : AppBar(
              title: Text('Orders', style: AppTypography.display(18, weight: FontWeight.w700)),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _statusFilters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final (value, label) = _statusFilters[i];
                  final selected = value == _selectedStatus;
                  return ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedStatus = value),
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    labelStyle: AppTypography.body(12, weight: FontWeight.w600, color: selected ? Colors.white : AppColors.ink700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: ordersAsync.when(
              data: (data) {
                final orders = data['orders'] ?? [];
                if (orders.isEmpty) {
                  return Center(child: Text('No orders found', style: AppTypography.body(13, color: AppColors.ink500)));
                }

                if (isWide) {
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 2.4,
                    ),
                    itemCount: orders.length,
                    itemBuilder: (context, index) => _OrderCard(order: orders[index]),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) => _OrderCard(order: orders[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error', style: const TextStyle(color: AppColors.error)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order['OrderStatus'] ?? {};
    final statusColor = status['color'] != null
        ? Color(int.parse(status['color'].replaceFirst('#', '0xFF')))
        : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: AppColors.ink900.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order #${order['order_id']}', style: AppTypography.body(14, weight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(status['name'] ?? 'Unknown', style: AppTypography.body(10, weight: FontWeight.w600, color: statusColor)),
              ),
            ],
          ),
          const Divider(height: 18, color: AppColors.border),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: AppColors.ink500),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order['Customer']?['full_name'] ?? 'Unknown',
                  style: AppTypography.body(12, color: AppColors.ink700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.storefront_outlined, size: 14, color: AppColors.ink500),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order['Business']?['name'] ?? 'Unknown',
                  style: AppTypography.body(12, color: AppColors.ink700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${order['total']?.toStringAsFixed(2) ?? '0.00'}',
            style: AppTypography.body(15, weight: FontWeight.w800, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}