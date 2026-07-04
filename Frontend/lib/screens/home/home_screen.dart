// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'customer_home.dart';
import 'merchant_dashboard.dart';
import 'driver_dashboard.dart';
import '../user/admin/admin_dashboard.dart';
import '../auth/driver_pending_screen.dart';
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
    // ✅ تأخير بسيط للتأكد من أن كل شيء جاهز
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
            
            // ✅ إذا كان السائق Active، نذهب للـ Dashboard فوراً
            if (_driverStatus == 'Active') {
              // لا حاجة لفعل شيء، الـ build سيعرض DriverDashboard
            }
          }
        } catch (e) {
          print('❌ Error getting driver status: $e');
          if (mounted) {
            setState(() {
              _isChecking = false;
              _hasError = true;
              // ✅ في حالة الخطأ، نفترض أنه يحتاج إلى إكمال الملف
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
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // ✅ إذا كان auth لا يزال يتحقق
    if (!authState.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ إذا كان هناك مستخدم
    if (user == null) {
      // ✅ المستخدم غير مسجل دخول → اذهب لتسجيل الدخول
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

    // ✅ إذا كان لا يزال يتحقق من حالة السائق
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking your account status...'),
            ],
          ),
        ),
      );
    }

    // ✅ في حالة الخطأ
    if (_hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Something went wrong'),
              const SizedBox(height: 8),
              Text(
                'Please try again',
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
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Driver specific check
    if (user.isDriver) {
      // ✅ إذا كان السائق يحتاج إلى إكمال الملف
      if (_needsOnboarding || _driverStatus == 'Pending' || _driverStatus == null) {
        return const DriverOnboardingScreen();
      }
      
      // ✅ إذا تم رفض السائق
      if (_driverStatus == 'Rejected') {
        return const DriverRejectedScreen();
      }
      
      // ✅ إذا كان السائق نشطاً
      if (_driverStatus == 'Active') {
        return const DriverDashboard();
      }
      
      // ✅ Fallback: أي حالة أخرى → اذهب لإكمال الملف
      return const DriverOnboardingScreen();
    }

    // ✅ Role-based navigation for other users
    if (user.isAdmin) {
      return const AdminDashboard();
    } else if (user.isMerchant) {
      return const MerchantDashboard();
    } else if (user.isDriver) {
      return const DriverDashboard();
    } else {
      // Customer (default)
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