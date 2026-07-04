// lib/screens/home/driver_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/models/user_model.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/maps/driver_location_map.dart';
import '../user/driver/widgets/driver_stat_card.dart';
import '../user/driver/available_orders.dart';
import '../user/driver/my_deliveries.dart';
import '../user/driver/earnings.dart';
import '../user/driver/driver_profile_screen.dart';
import '../user/driver/driver_settings_screen.dart';
import '../auth/login_screen.dart';

class DriverDashboard extends ConsumerStatefulWidget {
  const DriverDashboard({super.key});

  @override
  ConsumerState<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends ConsumerState<DriverDashboard> {
  int _currentIndex = 0;
  final LocationService _locationService = LocationService();
  bool _isSidebarOpen = false;

  // ✅ قائمة الصفحات الرئيسية
  final List<Widget> _pages = const [
    _DriverHomeContent(),
    AvailableOrders(),
    MyDeliveries(),
    Earnings(),
  ];

  // ✅ قائمة عناصر الـ Sidebar
  final List<Map<String, dynamic>> _sidebarItems = [
    {'icon': Icons.dashboard_outlined, 'label': 'Dashboard', 'index': 0},
    {'icon': Icons.local_shipping_outlined, 'label': 'Available Orders', 'index': 1},
    {'icon': Icons.delivery_dining_outlined, 'label': 'My Deliveries', 'index': 2},
    {'icon': Icons.monetization_on_outlined, 'label': 'Earnings', 'index': 3},
    {'icon': Icons.person_outline, 'label': 'Profile', 'index': 4, 'isProfile': true},
    {'icon': Icons.settings_outlined, 'label': 'Settings', 'index': 5, 'isSettings': true},
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

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  void _navigateToPage(int index) {
    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DriverProfileScreen()),
      ).then((_) {
        ref.read(driverProvider.notifier).loadDriverData();
      });
      _closeSidebar();
      return;
    }
    
    if (index == 5) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DriverSettingsScreen()),
      );
      _closeSidebar();
      return;
    }

    setState(() {
      _currentIndex = index;
      _isSidebarOpen = false;
    });
  }

  void _closeSidebar() {
    setState(() {
      _isSidebarOpen = false;
    });
  }

  Future<void> _logout() async {
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.logout();
    
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driverState = ref.watch(driverProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      body: Stack(
        children: [
          _buildMainContent(driverState),
          
          if (_isSidebarOpen)
            GestureDetector(
              onTap: _closeSidebar,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isSidebarOpen ? 0 : -280,
            top: 0,
            bottom: 0,
            child: _buildSidebar(user),
          ),
        ],
      ),
    );
  }

  // ============================================
  // 📌 المحتوى الرئيسي
  // ============================================
  
  Widget _buildMainContent(DriverState driverState) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Delivery',
          style: AppTypography.display(20, weight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: _toggleSidebar,
          color: AppColors.ink700,
        ),
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

  // ============================================
  // 📌 Sidebar
  // ============================================

  Widget _buildSidebar(UserModel? user) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        gradient: AppColors.duskGradient,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.routeGradient,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.transparent,
                      backgroundImage: user?.profileImage != null
                          ? NetworkImage(user!.profileImage!)
                          : null,
                      child: user?.profileImage == null
                          ? Text(
                              user?.fullName?.isNotEmpty == true
                                  ? user!.fullName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? 'Driver',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: ref.watch(driverProvider).isOnline
                                ? AppColors.success
                                : AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          ref.watch(driverProvider).isOnline
                              ? 'Online'
                              : 'Offline',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(color: Colors.white24, height: 1),
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _sidebarItems.length,
                itemBuilder: (context, index) {
                  final item = _sidebarItems[index];
                  final isSelected = _currentIndex == item['index'] && 
                      !(item['isProfile'] == true || item['isSettings'] == true);
                  
                  return _SidebarItem(
                    icon: item['icon'],
                    label: item['label'],
                    isSelected: isSelected,
                    onTap: () => _navigateToPage(item['index']),
                  );
                },
              ),
            ),
            
            const Divider(color: Colors.white24, height: 1),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: _SidebarItem(
                icon: Icons.logout_rounded,
                label: 'Logout',
                isSelected: false,
                isDestructive: true,
                onTap: () => _showLogoutDialog(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// ============================================
// 📌 Sidebar Item Widget
// ============================================

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDestructive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: Colors.white.withOpacity(0.2))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? AppColors.error
                    : (isSelected ? Colors.white : Colors.white70),
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isDestructive
                        ? AppColors.error
                        : (isSelected ? Colors.white : Colors.white70),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// 📌 Driver Home Content (المحسّن)
// ============================================

class _DriverHomeContent extends ConsumerWidget {
  const _DriverHomeContent();

  // ✅ ✅ ✅ الدالة المصححة
  String _formatNumber(dynamic value, {int decimals = 1}) {
    // ✅ إذا كانت القيمة null
    if (value == null) {
      return decimals == 1 ? '0.0' : '0.00';
    }
    
    try {
      // ✅ إذا كانت القيمة String، نحاول تحويلها إلى num
      if (value is String) {
        // ✅ إزالة أي أحرف غير رقمية (مثل $)
        final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
        final number = double.tryParse(cleaned);
        if (number != null) {
          return number.toStringAsFixed(decimals);
        }
        return decimals == 1 ? '0.0' : '0.00';
      }
      
      // ✅ إذا كانت القيمة num
      if (value is num) {
        return value.toStringAsFixed(decimals);
      }
      
      // ✅ محاولة التحويل المباشر
      final number = double.parse(value.toString());
      return number.toStringAsFixed(decimals);
      
    } catch (e) {
      // ✅ في حالة أي خطأ، نعيد القيمة الافتراضية
      return decimals == 1 ? '0.0' : '0.00';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverState = ref.watch(driverProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

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

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await ref.read(driverProvider.notifier).loadDriverData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(context, driverState, user),
            const SizedBox(height: 24),
            _buildMapSection(context, driverState, ref),
            const SizedBox(height: 24),
            _buildStatsSection(stats),
            const SizedBox(height: 24),
            if (driverState.isOnline)
              _buildUpdateLocationButton(context, ref),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, DriverState driverState, UserModel? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.routeGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: user?.profileImage != null
                  ? NetworkImage(user!.profileImage!)
                  : null,
              child: user?.profileImage == null
                  ? Text(
                      user?.fullName?.isNotEmpty == true
                          ? user!.fullName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user?.fullName?.split(' ').first ?? 'Driver'}! 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Status: ${driverState.profile?['status'] ?? 'Pending'}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatNumber(driverState.stats?['rating'], decimals: 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
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
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(BuildContext context, DriverState driverState, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DriverLocationMap(
          latitude: driverState.profile?['current_latitude'] != null
              ? double.tryParse(driverState.profile!['current_latitude'].toString())
              : null,
          longitude: driverState.profile?['current_longitude'] != null
              ? double.tryParse(driverState.profile!['current_longitude'].toString())
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
      ),
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Your Stats',
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
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            DriverStatCard(
              title: 'Total Deliveries',
              value: _formatNumber(stats['total_deliveries']),
              icon: Icons.delivery_dining,
              color: AppColors.primary,
            ),
            DriverStatCard(
              title: 'Total Earnings',
              value: '\$${_formatNumber(stats['total_earnings'], decimals: 2)}',
              icon: Icons.attach_money,
              color: AppColors.success,
            ),
            DriverStatCard(
              title: 'Rating',
              value: '${_formatNumber(stats['rating'], decimals: 1)} ⭐',
              icon: Icons.star,
              color: AppColors.gold,
            ),
            DriverStatCard(
              title: 'Current Orders',
              value: _formatNumber(stats['current_orders']),
              icon: Icons.hourglass_top,
              color: AppColors.accent,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpdateLocationButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          try {
            final locationService = LocationService();
            final position = await locationService.getCurrentLocation();
            if (position != null) {
              await ref
                  .read(driverProvider.notifier)
                  .updateLocation(
                    latitude: position.latitude,
                    longitude: position.longitude,
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📍 Location updated successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('❌ Failed to update location'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
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
    );
  }
}