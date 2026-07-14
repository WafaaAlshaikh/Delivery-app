// lib/screens/auth/post_auth_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/screens/home/driver_dashboard.dart';
import '../../providers/auth_provider.dart';
import '../../providers/store_provider.dart';
import '../home/home_screen.dart';
import '../business/store_setup_screen.dart';
import '../business/pending_approval_screen.dart';
import '../business/business_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import 'driver_pending_screen.dart';
import 'driver_onboarding_screen.dart'; 

class PostAuthRouter extends ConsumerStatefulWidget {
  const PostAuthRouter({super.key});

  @override
  ConsumerState<PostAuthRouter> createState() => _PostAuthRouterState();
}

class _PostAuthRouterState extends ConsumerState<PostAuthRouter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user?.role == 'Merchant') {
        ref.read(storeProvider.notifier).fetchMyStore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final driverStatus = authState.driverStatus; 

    if (user?.role == 'Admin') {
      return const AdminDashboardScreen();
    }

    if (user?.role == 'Driver') {
  final hasCompleteInfo = driverStatus?['hasCompleteInfo'] ?? false;
  final status = driverStatus?['status'] ?? 'Pending';

  print('🔍 Driver Status:');
  print('  - hasCompleteInfo: $hasCompleteInfo');
  print('  - status: $status');
  print('  - driverStatus: $driverStatus');

  if (!hasCompleteInfo) {
    return const DriverOnboardingScreen();
  }

  if (status == 'Pending' || status == 'Rejected') {
    return const DriverPendingScreen();
  }

  return const DriverDashboard();
}


    if (user?.role == 'Customer') {
      return const HomeScreen();
    }

    if (user?.role == 'Merchant') {
      final storeState = ref.watch(storeProvider);

      if (!storeState.isInitialized) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final store = storeState.store;
      if (store == null) {
        return const StoreSetupScreen();
      }

      switch (store.approvalStatus) {
        case 'Verified':
          return const BusinessDashboardScreen();
        case 'Rejected':
        case 'Pending':
        case 'Unverified':
        default:
          return const PendingApprovalScreen();
      }
    }

    return const Scaffold(
      body: Center(
        child: Text('Unknown role. Please contact support.'),
      ),
    );
  }
}