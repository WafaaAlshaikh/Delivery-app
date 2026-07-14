// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/screens/admin/admin_dashboard_screen.dart';
import 'package:frontend/screens/stores/stores_screen.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'customer_home.dart';
import 'merchant_dashboard.dart';
import 'driver_dashboard.dart';
import '../user/admin/admin_dashboard.dart';
import '../auth/driver_rejected_screen.dart';
import '../auth/driver_onboarding_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isChecking = true;
  String? _driverStatus;
  bool _needsOnboarding = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDriverStatus();
    });
  }

  Future<void> _checkDriverStatus() async {
    try {
      final authState = ref.read(authProvider);
      final user = authState.user;
      
      if (user != null && user.isDriver) {
        try {
          final statusData = await ref.read(authProvider.notifier).getDriverStatus();
          if (mounted) {
            setState(() {
              _driverStatus = statusData?['status'] ?? 'Pending';
              _needsOnboarding = statusData?['needsOnboarding'] ?? 
                                 (statusData?['hasCompleteInfo'] == false);
              _isChecking = false;
              _hasError = false;
            });
            
            if (_driverStatus == 'Active') {
            }
          }
        } catch (e) {
          print('❌ Error getting driver status: $e');
          if (mounted) {
            setState(() {
              _isChecking = false;
              _hasError = true;
              _needsOnboarding = true;
              _driverStatus = 'Pending';
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isChecking = false;
          });
        }
      }
    } catch (e) {
      print('❌ Error in _checkDriverStatus: $e');
      if (mounted) {
        setState(() {
          _isChecking = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizationsExtension(context).tr;
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (!authState.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isChecking) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(tr.t('checking_account_status')), 
            ],
          ),
        ),
      );
    }

    if (_hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(tr.t('something_went_wrong')), 
              const SizedBox(height: 8),
              Text(
                tr.t('please_try_again'), 
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isChecking = true;
                    _hasError = false;
                  });
                  _checkDriverStatus();
                },
                child: Text(tr.t('retry')),
              ),
            ],
          ),
        ),
      );
    }

    if (user.isDriver) {
      if (_needsOnboarding || _driverStatus == 'Pending' || _driverStatus == null) {
        return const DriverOnboardingScreen();
      }
      
      if (_driverStatus == 'Rejected') {
        return const DriverRejectedScreen();
      }
      
      if (_driverStatus == 'Active') {
        return const DriverDashboard();
      }
      
      return const DriverOnboardingScreen();
    }

    if (user.isAdmin) {
      return const AdminDashboardScreen();
    } else if (user.isMerchant) {
      return const StoresScreen();
    } else if (user.isDriver) {
      return const DriverDashboard();
    } else {
      final authNotifier = ref.read(authProvider.notifier);
    return CustomerHome(
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
  }
}