// lib/screens/user/driver/dashboard/driver_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:frontend/core/localization/app_localizations.dart';
import 'package:frontend/core/theme/typography.dart';
import 'widgets/dashboard_app_bar.dart';
import 'widgets/dashboard_sidebar.dart';
import 'widgets/live_status_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/welcome_card.dart';
import 'widgets/stats_grid.dart';
import 'widgets/earnings_card.dart';
import 'widgets/skeleton_loader.dart';
import 'package:frontend/screens/user/driver/available_orders.dart';
import 'package:frontend/screens/user/driver/my_deliveries.dart';
import 'package:frontend/screens/user/driver/current_delivery_screen.dart';
import 'package:frontend/screens/user/driver/earnings/earnings_screen.dart';
import 'package:frontend/screens/user/driver/driver_profile_screen.dart';
import 'package:frontend/screens/settings/driver_settings_screen.dart';
import 'package:frontend/screens/user/driver/ratings/ratings_screen.dart';
import 'package:frontend/screens/user/driver/scheduling/scheduling_screen.dart';
import 'package:frontend/screens/user/driver/notifications_screen.dart';
import 'package:frontend/screens/user/driver/communication/communication_screen.dart';
import '../../../core/theme/colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/driver_provider.dart';
import '../../../services/location_service.dart';
import '../../providers/dashboard_provider.dart';
import '../../../widgets/maps/driver_location_map.dart';

class DriverDashboard extends ConsumerStatefulWidget {
  const DriverDashboard({super.key});

  @override
  ConsumerState<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends ConsumerState<DriverDashboard> {
  int _currentIndex = 0;
  bool _isSidebarOpen = false;
  final LocationService _locationService = LocationService();
  late final PageController _pageController;

  final List<Widget> _pages = const [
    _DashboardContent(),      
    AvailableOrders(),      
    MyDeliveries(),         
    EarningsScreen(),         
    CurrentDeliveryScreen(),  
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(driverProvider.notifier).loadDriverData();
      ref.read(dashboardProvider.notifier).loadDashboardData();
      _updateLocation();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _updateLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null && mounted) {
      await ref.read(driverProvider.notifier).updateLocation(
            latitude: position.latitude,
            longitude: position.longitude,
          );
    }
  }

  void _toggleSidebar() => setState(() => _isSidebarOpen = !_isSidebarOpen);
  void _closeSidebar() => setState(() => _isSidebarOpen = false);

  void _navigateToPage(int index) {
    if (index == 5) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverProfileScreen()))
          .then((_) => ref.read(driverProvider.notifier).loadDriverData());
      _closeSidebar();
      return;
    }
    if (index == 6) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverSettingsScreen()));
      _closeSidebar();
      return;
    }
    if (index == 7) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const RatingsScreen()));
      _closeSidebar();
      return;
    }
    if (index == 8) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SchedulingScreen()));
      _closeSidebar();
      return;
    }
    if (index == 9) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
      _closeSidebar();
      return;
    }
    if (index == 10) {
      _openCommunication('1', 'Ahmed Mohammed', '+970599123456');
      _closeSidebar();
      return;
    }

    setState(() {
      _currentIndex = index;
      _isSidebarOpen = false;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _openCommunication(String customerId, String customerName, String phoneNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommunicationScreen(
          customerId: customerId.toString(),
          customerName: customerName,
          phoneNumber: phoneNumber,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverState = ref.watch(driverProvider);
    final user = ref.watch(authProvider).user;
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          Row(
            children: [
              if (isDesktop)
                DashboardSidebar(
                  user: user,
                  currentIndex: _currentIndex,
                  isOnline: driverState.isOnline,
                  onNavigate: _navigateToPage,
                  onLogout: _logout,
                ),
              Expanded(
                child: Column(
                  children: [
                    DashboardAppBar(
                      isDesktop: isDesktop,
                      isOnline: driverState.isOnline,
                      onToggleOnline: () => ref.read(driverProvider.notifier).toggleOnline(),
                      onToggleSidebar: isDesktop ? null : _toggleSidebar,
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) => setState(() => _currentIndex = index),
                        children: _pages,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isDesktop && _isSidebarOpen)
            GestureDetector(
              onTap: _closeSidebar,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          if (!isDesktop)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -280,
              top: 0,
              bottom: 0,
              child: DashboardSidebar(
                user: user,
                currentIndex: _currentIndex,
                isOnline: driverState.isOnline,
                onNavigate: _navigateToPage,
                onLogout: _logout,
                isMobile: true,
                onClose: _closeSidebar,
              ),
            ),
        ],
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final driverState = ref.watch(driverProvider);
    final user = ref.watch(authProvider).user;
    final tr = AppLocalizations.of(context)!;

    if (dashboardState.isLoading && dashboardState.stats == null) {
      return const SkeletonLoader();
    }

    if (dashboardState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(dashboardState.error!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(dashboardProvider.notifier).refreshData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final stats = dashboardState.stats ?? {};
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final profile = driverState.profile;
    
    final driverLat = profile?['current_latitude'] != null 
        ? double.tryParse(profile!['current_latitude'].toString()) 
        : null;
    final driverLng = profile?['current_longitude'] != null 
        ? double.tryParse(profile!['current_longitude'].toString()) 
        : null;

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardProvider.notifier).refreshData(),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeCard(user: user, isOnline: driverState.isOnline)
                .animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),

            const SizedBox(height: 16),

            QuickActions(
              onUpdateLocation: () => _updateLocation(context, ref, tr),
              onOpenCommunication: () => _openCommunication(context),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.2),

            const SizedBox(height: 16),

            _buildMapSection(
              context: context,
              ref: ref,
              tr: tr,
              driverLat: driverLat,
              driverLng: driverLng,
              isOnline: driverState.isOnline,
            ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideY(begin: 0.2),

            const SizedBox(height: 16),

            EarningsCard(stats: stats)
                .animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.2),

            const SizedBox(height: 16),

            LiveStatusCard(
              isOnline: driverState.isOnline,
              onToggle: () => ref.read(driverProvider.notifier).toggleOnline(),
              stats: stats,
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.2),

            const SizedBox(height: 16),

            StatsGrid(stats: stats)
                .animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.2),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocalizations tr,
    required double? driverLat,
    required double? driverLng,
    required bool isOnline,
  }) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.map_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr.t('your_location'),
                        style: AppTypography.display(14, weight: FontWeight.w700),
                      ),
                      Text(
                        isOnline 
                            ? tr.t('sharing_live_location')
                            : tr.t('location_offline'),
                        style: AppTypography.body(11, color: AppColors.ink500),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _updateLocation(context, ref, tr),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          color: AppColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tr.t('update'),
                          style: AppTypography.body(10, weight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: isDesktop ? 350 : 250,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: DriverLocationMap(
                latitude: driverLat,
                longitude: driverLng,
                isOnline: isOnline,
                interactive: true,
                onLocationChanged: (newPosition) async {
                  await ref.read(driverProvider.notifier).updateLocation(
                        latitude: newPosition.latitude,
                        longitude: newPosition.longitude,
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(tr.t('location_updated')),
                        backgroundColor: AppColors.success,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.my_location,
                  size: 14,
                  color: isOnline ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOnline 
                            ? '🟢 ${tr.t('live_tracking_active')}'
                            : '🔴 ${tr.t('location_not_sharing')}',
                        style: AppTypography.body(
                          11,
                          color: isOnline ? AppColors.success : AppColors.error,
                          weight: FontWeight.w600,
                        ),
                      ),
                      if (driverLat != null && driverLng != null)
                        Text(
                          '${driverLat.toStringAsFixed(6)}, ${driverLng.toStringAsFixed(6)}',
                          style: AppTypography.body(10, color: AppColors.ink900),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isOnline ? AppColors.successSoft : AppColors.errorSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isOnline ? 'Live' : 'Offline',
                    style: AppTypography.body(
                      9,
                      weight: FontWeight.w700,
                      color: isOnline ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

void _updateLocation(BuildContext context, WidgetRef ref, AppLocalizations tr) async {
  try {
    final locationService = LocationService();
    final position = await locationService.getCurrentLocation();
    if (position != null) {
      await ref.read(driverProvider.notifier).updateLocation(
            latitude: position.latitude,
            longitude: position.longitude,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr.t('location_updated_successfully')),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr.t('location_update_failed')),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

void _openCommunication(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const CommunicationScreen(
        customerId: '1',
        customerName: 'Ahmed Mohammed',
        phoneNumber: '+970599123456',
      ),
    ),
  );
}