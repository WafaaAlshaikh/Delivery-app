// frontend/lib/screens/user/driver/available_orders.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/order_model.dart';
import '../../../providers/driver_provider.dart';
import '../../../providers/order_provider.dart';

class AvailableOrders extends ConsumerStatefulWidget {
  const AvailableOrders({super.key});

  @override
  ConsumerState<AvailableOrders> createState() => _AvailableOrdersState();
}

class _AvailableOrdersState extends ConsumerState<AvailableOrders> {
  String _selectedSort = 'distance';
  String _selectedFilter = 'all';
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderProvider.notifier).loadAvailableOrders(
        sortBy: _selectedSort,
        filterBy: _selectedFilter,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final driverState = ref.watch(driverProvider);
    final orderState = ref.watch(orderProvider);
    final orderNotifier = ref.read(orderProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // ✅ Filter Bar
          _FilterBar(
            selectedSort: _selectedSort,
            selectedFilter: _selectedFilter,
            onSortChanged: (value) {
              setState(() => _selectedSort = value);
              orderNotifier.loadAvailableOrders(
                sortBy: value,
                filterBy: _selectedFilter,
              );
            },
            onFilterChanged: (value) {
              setState(() => _selectedFilter = value);
              orderNotifier.loadAvailableOrders(
                sortBy: _selectedSort,
                filterBy: value,
              );
            },
            onToggleFilters: () {
              setState(() => _showFilters = !_showFilters);
            },
            showFilters: _showFilters,
          ),

          // ✅ Orders List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => orderNotifier.loadAvailableOrders(
                sortBy: _selectedSort,
                filterBy: _selectedFilter,
              ),
              color: AppColors.primary,
              child: _buildOrdersList(orderState, driverState, orderNotifier),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(
    OrderState orderState,
    DriverState driverState,
    OrderNotifier orderNotifier,
  ) {
    if (orderState.isLoading && orderState.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orderState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              orderState.error!,
              style: AppTypography.body(14, color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => orderNotifier.loadAvailableOrders(
                sortBy: _selectedSort,
                filterBy: _selectedFilter,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (orderState.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: AppColors.ink300),
            const SizedBox(height: 16),
            Text(
              'No available orders',
              style: AppTypography.display(20, weight: FontWeight.w700, color: AppColors.ink500),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new orders',
              style: AppTypography.body(14, color: AppColors.ink300),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => orderNotifier.loadAvailableOrders(
                sortBy: _selectedSort,
                filterBy: _selectedFilter,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orderState.orders.length,
      itemBuilder: (context, index) {
        final order = orderState.orders[index];
        return _OrderCard(
          order: order,
          isOnline: driverState.isOnline,
          onAccept: () {
            // TODO: Implement Accept
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Order #${order.orderId} accepted!'),
                backgroundColor: AppColors.success,
              ),
            );
          },
        );
      },
    );
  }
}

// ============================================
// 📌 FILTER BAR WIDGET (النسخة المصححة)
// ============================================

class _FilterBar extends StatelessWidget {
  final String selectedSort;
  final String selectedFilter;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onToggleFilters;
  final bool showFilters;

  const _FilterBar({
    required this.selectedSort,
    required this.selectedFilter,
    required this.onSortChanged,
    required this.onFilterChanged,
    required this.onToggleFilters,
    required this.showFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          // ✅ Main Filter Row
          Row(
            children: [
              // ✅ Sort Dropdown
              Expanded(
                child: _buildDropdown<String>(
                  value: selectedSort,
                  items: const [
                    DropdownMenuItem(value: 'distance', child: Text('📍 Nearest')),
                    DropdownMenuItem(value: 'time', child: Text('⏱️ Fastest')),
                    DropdownMenuItem(value: 'earning', child: Text('💰 Highest')),
                    DropdownMenuItem(value: 'express', child: Text('⚡ Express')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onSortChanged(value);
                    }
                  },
                  label: 'Sort',
                ),
              ),
              const SizedBox(width: 8),
              
              // ✅ Filter Dropdown
              Expanded(
                child: _buildDropdown<String>(
                  value: selectedFilter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('📋 All')),
                    DropdownMenuItem(value: 'nearby', child: Text('📍 Nearby')),
                    DropdownMenuItem(value: 'express', child: Text('⚡ Express')),
                    DropdownMenuItem(value: 'heavy', child: Text('🏋️ Heavy')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onFilterChanged(value);
                    }
                  },
                  label: 'Filter',
                ),
              ),
              const SizedBox(width: 8),
              
              // ✅ Toggle Filters Button
              IconButton(
                onPressed: onToggleFilters,
                icon: Icon(
                  showFilters ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.ink500,
                ),
              ),
            ],
          ),
          
          // ✅ Expanded Filters (when showFilters is true)
          if (showFilters) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSunken,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // ✅ Distance Slider
                  Row(
                    children: [
                      const Icon(Icons.radar, size: 18, color: AppColors.ink500),
                      const SizedBox(width: 8),
                      const Text('Max Distance:'),
                      const Spacer(),
                      // TODO: Add slider
                      Text('10 km', style: AppTypography.body(12, weight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // ✅ Vehicle Type Badge
                  Row(
                    children: [
                      const Icon(Icons.directions_car, size: 18, color: AppColors.ink500),
                      const SizedBox(width: 8),
                      const Text('Vehicle:'),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Motorcycle',
                          style: AppTypography.body(11, weight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ✅ ✅ ✅ التعديل هنا: onChanged يقبل T? (nullable)
  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged, // ✅ تغيير إلى T?
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged, // ✅ الآن متوافق
          style: AppTypography.body(12, weight: FontWeight.w600),
          dropdownColor: Colors.white,
        ),
      ),
    );
  }
}
// ============================================
// 📌 ORDER CARD WIDGET (مطور مع تصنيفات)
// ============================================

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isOnline;
  final VoidCallback onAccept;

  const _OrderCard({
    required this.order,
    required this.isOnline,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Header: Store + Badges
          Row(
            children: [
              // Store Logo
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.store,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.business.name,
                      style: AppTypography.body(14, weight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (order.distance != null)
                          Text(
                            '${order.distance!.toStringAsFixed(1)} km • ',
                            style: AppTypography.body(12, color: AppColors.ink500),
                          ),
                        if (order.estimatedTime != null)
                          Text(
                            '~${order.estimatedTime} min',
                            style: AppTypography.body(12, color: AppColors.ink500),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // ✅ Earning Badge
              if (order.estimatedEarning != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '\$${order.estimatedEarning!.toStringAsFixed(2)}',
                    style: AppTypography.body(
                      12,
                      weight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // ✅ Order Details
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.orderId}',
                      style: AppTypography.body(12, color: AppColors.ink500),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 14, color: AppColors.ink500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            order.customer.fullName,
                            style: AppTypography.body(12, color: AppColors.ink700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: AppColors.ink500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            order.deliveryAddress.fullAddress,
                            style: AppTypography.body(12, color: AppColors.ink700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // ✅ Tags
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (order.isExpress)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.errorSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '⚡ Express',
                        style: AppTypography.body(10, weight: FontWeight.w700, color: AppColors.error),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.ink100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${order.items.length} items',
                      style: AppTypography.body(10, color: AppColors.ink500),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ✅ Total & Accept Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: AppTypography.body(11, color: AppColors.ink500),
                  ),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: AppTypography.body(
                      16,
                      weight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              // ✅ Accept Button
              SizedBox(
                width: 120,
                height: 40,
                child: ElevatedButton(
                  onPressed: isOnline ? onAccept : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: AppColors.ink100,
                  ),
                  child: Text(
                    'Accept',
                    style: AppTypography.body(13, weight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}