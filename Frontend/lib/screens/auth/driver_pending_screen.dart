// lib/screens/auth/driver_pending_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom/custom_button.dart';
import '../home/home_screen.dart';
import 'driver_onboarding_screen.dart';

class DriverPendingScreen extends ConsumerStatefulWidget {
  const DriverPendingScreen({super.key});

  @override
  ConsumerState<DriverPendingScreen> createState() => _DriverPendingScreenState();
}

class _DriverPendingScreenState extends ConsumerState<DriverPendingScreen> {
  bool _isChecking = false;
  Map<String, dynamic>? _driverStatus;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
    // ✅ نبدأ الـ polling بعد 5 ثواني فقط
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _startStatusCheck();
      }
    });
  }

  Future<void> _loadStatus() async {
    try {
      final status = await ref.read(authProvider.notifier).getDriverStatus();
      if (mounted) {
        setState(() {
          _driverStatus = status;
          _isInitialLoad = false;
        });
        
        // ✅ إذا كان Active، اذهب للـ Home فوراً
        if (status?['status'] == 'Active') {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      }
    } catch (e) {
      print('❌ Error loading status: $e');
      if (mounted) {
        setState(() {
          _isInitialLoad = false;
        });
      }
    }
  }

  void _startStatusCheck() {
    // ✅ منع التكرار المفرط
    if (_isChecking) return;
    
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _checkStatus();
      }
    });
  }

  Future<void> _checkStatus() async {
    if (_isChecking || !mounted) return;
    setState(() => _isChecking = true);

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final status = await authNotifier.getDriverStatus();
      
      if (mounted) {
        setState(() {
          _driverStatus = status;
          _isChecking = false;
        });
      }
      
      // ✅ إذا أصبح Active، اذهب للـ Home
      if (status?['status'] == 'Active' && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        return;
      }
      
      // ✅ استمر في الـ polling فقط إذا كان Pending
      if (mounted && status?['status'] == 'Pending') {
        _startStatusCheck();
      }
    } catch (e) {
      print('❌ Error checking status: $e');
      if (mounted) {
        setState(() => _isChecking = false);
        // ✅ نعيد المحاولة بعد 15 ثانية
        Future.delayed(const Duration(seconds: 15), () {
          if (mounted) {
            _startStatusCheck();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ إذا كان لا يزال يحمل
    if (_isInitialLoad) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading your application status...'),
            ],
          ),
        ),
      );
    }
    final status = _driverStatus ?? {};
    final statusText = status['status'] ?? 'Pending';
    final vehicleType = status['vehicleType'] ?? 'Not set';
    final autoApproved = status['autoApproved'] == true ? 'Yes' : 'No';
    final missingFields = (status['missingFields'] as List?) ?? [];
    final needsOnboarding = status['needsOnboarding'] ?? false;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: statusText == 'Active' 
                      ? AppColors.successSoft 
                      : (needsOnboarding ? AppColors.primarySoft : AppColors.goldSoft),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  needsOnboarding
                      ? Icons.edit_note_rounded
                      : (statusText == 'Active' 
                          ? Icons.check_circle_rounded 
                          : Icons.hourglass_top_rounded),
                  size: 64,
                  color: needsOnboarding
                      ? AppColors.primary
                      : (statusText == 'Active' 
                          ? AppColors.success 
                          : AppColors.gold),
                ),
              ),
              const SizedBox(height: 24),
              
              // ✅ Title
              Text(
                needsOnboarding
                    ? '📝 Complete Your Profile'
                    : (statusText == 'Active' 
                        ? '🎉 Account Approved!' 
                        : 'Application Under Review'),
                style: AppTypography.display(24, weight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // ✅ Subtitle
              Text(
                needsOnboarding
                    ? 'Please complete your driver profile to start delivering.'
                    : (status['message'] ?? 
                       'Your driver application is being reviewed. '
                       'We\'ll notify you once it\'s approved.'),
                style: AppTypography.body(14, color: AppColors.ink500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // ✅ Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _StatusItem(
                      label: 'Status',
                      value: needsOnboarding ? 'Incomplete' : statusText,
                      color: needsOnboarding 
                          ? AppColors.primary 
                          : (statusText == 'Active' 
                              ? AppColors.success 
                              : (statusText == 'Rejected' 
                                  ? AppColors.error 
                                  : AppColors.gold)),
                    ),
                    const Divider(height: 20),
                    _StatusItem(
                      label: 'Vehicle Type',
                      value: vehicleType,
                      color: AppColors.ink700,
                    ),
                    const Divider(height: 20),
                    _StatusItem(
                      label: 'Auto-Approved',
                      value: autoApproved,
                      color: status['autoApproved'] == true 
                        ? AppColors.success 
                        : AppColors.ink500,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // ✅ Missing Fields (if any)
              if (missingFields.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚠️ Need your attention:',
                        style: AppTypography.body(13, weight: FontWeight.w700, color: AppColors.error),
                      ),
                      const SizedBox(height: 4),
                      ...missingFields.map((field) => Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.circle, size: 4, color: AppColors.error),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                field,
                                style: AppTypography.body(12, color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // ✅ MAIN BUTTON: Complete Profile or Go to Home
              if (needsOnboarding || missingFields.isNotEmpty)
                CustomButton(
                  text: 'Complete Your Profile',
                  icon: Icons.edit_outlined,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DriverOnboardingScreen(),
                      ),
                    );
                  },
                )
              else if (statusText == 'Pending')
                // ✅ Show pending message with refresh
                CustomButton(
                  text: 'Refresh Status',
                  icon: Icons.refresh_rounded,
                  variant: CustomButtonVariant.outlined,
                  isLoading: _isChecking,
                  onPressed: _checkStatus,
                )
              else
                // ✅ Go to Home
                CustomButton(
                  text: 'Go to Home',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                ),
              const SizedBox(height: 8),
              
              // ✅ Loading indicator
              if (_isChecking)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Status Item Widget
class _StatusItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatusItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.body(12, color: AppColors.ink500),
        ),
        Text(
          value,
          style: AppTypography.body(14, weight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}