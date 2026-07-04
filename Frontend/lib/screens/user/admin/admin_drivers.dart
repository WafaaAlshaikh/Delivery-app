// D:\Delivery\frontend\lib\screens\user\admin\admin_drivers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../providers/admin_provider.dart';

class AdminDrivers extends ConsumerStatefulWidget {
  const AdminDrivers({super.key});

  @override
  ConsumerState<AdminDrivers> createState() => _AdminDriversState();
}

class _AdminDriversState extends ConsumerState<AdminDrivers> {
  String? _selectedStatus;
  String _searchQuery = '';

  static const _statusFilters = [null, 'Pending', 'Active', 'Suspended', 'Rejected'];

  @override
  Widget build(BuildContext context) {
    final driversAsync = ref.watch(adminAllDriversProvider(_selectedStatus));
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: isWide
          ? null
          : AppBar(
              title: Text(
                'Drivers',
                style: AppTypography.display(18, weight: FontWeight.w700),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.refresh(adminAllDriversProvider(_selectedStatus)),
                ),
              ],
            ),
      body: Column(
        children: [
          // ✅ Search and Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search drivers...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: 12),
                if (isWide)
                  FilledButton.icon(
                    onPressed: () {
                      setState(() => _selectedStatus = null);
                      ref.refresh(adminAllDriversProvider(null));
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refresh'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // ✅ Status Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _statusFilters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final status = _statusFilters[i];
                  final selected = status == _selectedStatus;
                  return ChoiceChip(
                    label: Text(status ?? 'All'),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedStatus = status);
                      ref.refresh(adminAllDriversProvider(status));
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    labelStyle: AppTypography.body(
                      12,
                      weight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.ink700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ✅ Drivers List
          Expanded(
            child: driversAsync.when(
              data: (data) {
                final drivers = data['data'] ?? [];
                
                // ✅ Filter by search query
                final filteredDrivers = drivers.where((driver) {
                  final user = driver['User'] ?? {};
                  final name = (user['full_name'] ?? '').toLowerCase();
                  final email = (user['email'] ?? '').toLowerCase();
                  final query = _searchQuery.toLowerCase();
                  return name.contains(query) || email.contains(query);
                }).toList();

                if (filteredDrivers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delivery_dining_outlined,
                          size: 64,
                          color: AppColors.ink300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No drivers found',
                          style: AppTypography.display(18, weight: FontWeight.w700, color: AppColors.ink500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Drivers will appear here when they register',
                          style: AppTypography.body(13, color: AppColors.ink300),
                        ),
                      ],
                    ),
                  );
                }

                if (isWide) {
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 2.8,
                    ),
                    itemCount: filteredDrivers.length,
                    itemBuilder: (context, index) =>
                        _DriverCard(driver: filteredDrivers[index]),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredDrivers.length,
                  itemBuilder: (context, index) =>
                      _DriverCard(driver: filteredDrivers[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Error: $error',
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(adminAllDriversProvider(_selectedStatus)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// 📌 DRIVER CARD
// ============================================

class _DriverCard extends StatelessWidget {
  final Map<String, dynamic> driver;

  const _DriverCard({required this.driver});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return AppColors.success;
      case 'Pending':
        return AppColors.gold;
      case 'Rejected':
        return AppColors.error;
      case 'Suspended':
        return AppColors.warning;
      default:
        return AppColors.ink500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = driver['User'] ?? {};
    final status = driver['status'] ?? 'Pending';
    final statusColor = _getStatusColor(status);
    final isOnline = driver['is_online'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: status == 'Pending' ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink900.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ✅ Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor, statusColor.withOpacity(0.7)],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              (user['full_name'] ?? '?')[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ✅ Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user['full_name'] ?? 'Unknown',
                        style: AppTypography.body(14, weight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isOnline)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.successSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Online',
                          style: AppTypography.body(9, weight: FontWeight.w700, color: AppColors.success),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  user['email'] ?? '',
                  style: AppTypography.body(12, color: AppColors.ink500),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.car_rental_outlined,
                      size: 12,
                      color: AppColors.ink500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      driver['vehicle_type'] ?? 'N/A',
                      style: AppTypography.body(11, color: AppColors.ink500),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.credit_card_outlined,
                      size: 12,
                      color: AppColors.ink500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      driver['license_number'] ?? 'N/A',
                      style: AppTypography.body(11, color: AppColors.ink500),
                    ),
                  ],
                ),
                if (driver['admin_notes'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '📝 ${driver['admin_notes']}',
                    style: AppTypography.body(10, color: AppColors.ink500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // ✅ Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: AppTypography.body(10, weight: FontWeight.w600, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }
}