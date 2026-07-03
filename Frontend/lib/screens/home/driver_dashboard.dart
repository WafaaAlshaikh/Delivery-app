// lib/screens/home/driver_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/typography.dart';
import '../../providers/driver_provider.dart';
import '../../services/location_service.dart';
import '../user/driver/widgets/driver_stat_card.dart';
import '../../widgets/maps/driver_location_map.dart';
import '../user/driver/available_orders.dart';
import '../user/driver/my_deliveries.dart';
import '../user/driver/earnings.dart';

class DriverDashboard extends ConsumerStatefulWidget {
  const DriverDashboard({super.key});

  @override
  ConsumerState<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends ConsumerState<DriverDashboard> {
  int _currentIndex = 0;
  final LocationService _locationService = LocationService();

  final List<Widget> _pages = const [
    _DriverHomeContent(),
    AvailableOrders(),
    MyDeliveries(),
    Earnings(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(driverProvider.notifier).loadDriverData();
      _updateLocation();
    });
  }

  Future<void> _updateLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null && mounted) {
      final notifier = ref.read(driverProvider.notifier);
      await notifier.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverState = ref.watch(driverProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Delivery',
          style: AppTypography.display(20, weight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!driverState.isLoading)
            GestureDetector(
              onTap: () {
                ref.read(driverProvider.notifier).toggleOnline();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: driverState.isOnline
                      ? AppColors.successSoft
                      : AppColors.errorSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: driverState.isOnline
                            ? AppColors.success
                            : AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      driverState.isOnline ? 'Online' : 'Offline',
                      style: AppTypography.body(
                        12,
                        weight: FontWeight.w600,
                        color: driverState.isOnline
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: driverState.isLoading && _currentIndex == 0
          ? const Center(child: CircularProgressIndicator())
          : _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.ink500,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_outlined),
            activeIcon: Icon(Icons.local_shipping),
            label: 'Available',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining_outlined),
            activeIcon: Icon(Icons.delivery_dining),
            label: 'My Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_outlined),
            activeIcon: Icon(Icons.monetization_on),
            label: 'Earnings',
          ),
        ],
      ),
    );
  }
}

// ✅ محتوى الـ Dashboard الرئيسي للـ Driver
class _DriverHomeContent extends ConsumerWidget {
  const _DriverHomeContent();

  // ✅ دالة مساعدة لتحويل القيم بأمان
  String _formatNumber(dynamic value, {int decimals = 1}) {
    if (value == null) {
      return decimals == 1 ? '0.0' : '0.00';
    }
    try {
      // ✅ التحويل إلى num أولاً
      final number = value is num ? value : double.parse(value.toString());
      return number.toStringAsFixed(decimals);
    } catch (e) {
      return decimals == 1 ? '0.0' : '0.00';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverState = ref.watch(driverProvider);

    if (driverState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (driverState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              driverState.error!,
              style: const TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(driverProvider.notifier).loadDriverData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final stats = driverState.stats ?? {};
    final profile = driverState.profile ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ بطاقة الترحيب
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.routeGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.delivery_dining,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hello, Driver!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        profile['status'] ?? 'Pending',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: driverState.isOnline
                        ? AppColors.success
                        : AppColors.error,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    driverState.isOnline ? 'ONLINE' : 'OFFLINE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ✅ الخريطة
          DriverLocationMap(
            latitude: profile['current_latitude'] != null
                ? double.tryParse(profile['current_latitude'].toString())
                : null,
            longitude: profile['current_longitude'] != null
                ? double.tryParse(profile['current_longitude'].toString())
                : null,
            isOnline: driverState.isOnline,
            interactive: true,
            onLocationChanged: (newPosition) {
              ref
                  .read(driverProvider.notifier)
                  .updateLocation(
                    latitude: newPosition.latitude,
                    longitude: newPosition.longitude,
                  );
            },
          ),
          const SizedBox(height: 24),

          // ✅ إحصائيات سريعة
          Text(
            'Your Stats',
            style: AppTypography.display(18, weight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              DriverStatCard(
                title: 'Total Deliveries',
                value: '${stats['total_deliveries'] ?? 0}',
                icon: Icons.delivery_dining,
                color: AppColors.primary,
              ),
              DriverStatCard(
                title: 'Total Earnings',
                // ✅ استخدام الدالة المساعدة
                value:
                    '\$${_formatNumber(stats['total_earnings'], decimals: 2)}',
                icon: Icons.attach_money,
                color: AppColors.success,
              ),
              DriverStatCard(
                title: 'Rating',
                // ✅ استخدام الدالة المساعدة
                value: '${_formatNumber(stats['rating'], decimals: 1)} ⭐',
                icon: Icons.star,
                color: AppColors.gold,
              ),
              DriverStatCard(
                title: 'Current Orders',
                value: '${stats['current_orders'] ?? 0}',
                icon: Icons.hourglass_top,
                color: AppColors.accent,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ✅ زر تحديث الموقع
          if (driverState.isOnline)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final position = await _getCurrentLocation();
                  if (position != null && context.mounted) {
                    await ref
                        .read(driverProvider.notifier)
                        .updateLocation(
                          latitude: position.latitude,
                          longitude: position.longitude,
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('📍 Location updated successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '❌ Failed to get location. Please check GPS.',
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.my_location),
                label: const Text('Update Location'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ✅ دالة مساعدة لجلب الموقع
  Future<Position?> _getCurrentLocation() async {
    try {
      final locationService = LocationService();
      return await locationService.getCurrentLocation();
    } catch (e) {
      return null;
    }
  }
}
