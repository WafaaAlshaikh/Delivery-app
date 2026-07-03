// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'customer_home.dart';
import 'merchant_dashboard.dart';
import 'driver_dashboard.dart';
import '../user/admin/admin_dashboard.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ اختيار الشاشة المناسبة حسب الـ Role
    Widget dashboard;

    if (user.isAdmin) {
      dashboard = const AdminDashboard();
    } else if (user.isMerchant) {
      dashboard = const MerchantDashboard();
    } else if (user.isDriver) {
      dashboard = const DriverDashboard();
    } else {
      // Customer (افتراضي)
      dashboard = CustomerHome(
        user: user,
        onLogout: () async {
          await authNotifier.logout();
          if (!context.mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
      );
    }

    return dashboard;
  }
}