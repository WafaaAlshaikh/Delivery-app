// lib/screens/admin/admin_drivers.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../providers/admin_provider.dart';

class AdminDrivers extends ConsumerWidget {
  const AdminDrivers({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driversAsync = ref.watch(adminDriversProvider);
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: isWide
          ? null
          : AppBar(
              title: Text('Drivers', style: AppTypography.display(18, weight: FontWeight.w700)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})],
            ),
      body: driversAsync.when(
        data: (drivers) {
          if (drivers.isEmpty) {
            return Center(child: Text('No drivers found', style: AppTypography.body(13, color: AppColors.ink500)));
          }

          if (isWide) {
            return GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 3.0,
              ),
              itemCount: drivers.length,
              itemBuilder: (context, index) => _DriverCard(driver: drivers[index]),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: drivers.length,
            itemBuilder: (context, index) => _DriverCard(driver: drivers[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error', style: const TextStyle(color: AppColors.error)),
        ),
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final Map<String, dynamic> driver;

  const _DriverCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    final isActive = driver['is_active'] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: AppColors.ink900.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.roleDriver, AppColors.roleDriver.withOpacity(0.7)]),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              driver['full_name']?.isNotEmpty == true ? driver['full_name'][0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(driver['full_name'] ?? 'Unknown', style: AppTypography.body(14, weight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                Text(driver['email'] ?? '', style: AppTypography.body(12, color: AppColors.ink500), overflow: TextOverflow.ellipsis),
                if (driver['phone'] != null)
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 12, color: AppColors.ink500),
                      const SizedBox(width: 4),
                      Text(driver['phone'], style: AppTypography.body(12, color: AppColors.ink500)),
                    ],
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? AppColors.successSoft : AppColors.errorSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: AppTypography.body(10, weight: FontWeight.w600, color: isActive ? AppColors.success : AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}