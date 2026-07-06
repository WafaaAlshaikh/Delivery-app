// lib/screens/auth/driver_rejected_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom/custom_button.dart';
import '../home/home_screen.dart';
import 'driver_onboarding_screen.dart';

class DriverRejectedScreen extends ConsumerStatefulWidget {
  const DriverRejectedScreen({super.key});

  @override
  ConsumerState<DriverRejectedScreen> createState() => _DriverRejectedScreenState();
}

class _DriverRejectedScreenState extends ConsumerState<DriverRejectedScreen> {
  bool _isResubmitting = false;
  Map<String, dynamic>? _driverStatus;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final status = await ref.read(authProvider.notifier).getDriverStatus();
      if (mounted) {
        setState(() {
          _driverStatus = status;
        });
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> _resubmit() async {
    setState(() => _isResubmitting = true);

    try {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DriverOnboardingScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }

    setState(() => _isResubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final status = _driverStatus ?? {};
    final rejectionReason = status['rejectionReason'] ?? 'No reason provided';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.errorSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_rounded,
                  size: 64,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'Application Rejected',
                style: AppTypography.display(24, weight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              Text(
                'Your driver application was not approved at this time.',
                style: AppTypography.body(14, color: AppColors.ink500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📝 Reason:',
                      style: AppTypography.body(13, weight: FontWeight.w700, color: AppColors.error),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rejectionReason,
                      style: AppTypography.body(14, color: AppColors.ink700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              CustomButton(
                text: 'Update & Resubmit',
                icon: Icons.refresh_rounded,
                isLoading: _isResubmitting,
                onPressed: _resubmit,
              ),
              const SizedBox(height: 12),
              
              CustomButton(
                text: 'Go to Home',
                variant: CustomButtonVariant.outlined,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
              ),
              const SizedBox(height: 8),
              
              TextButton(
                onPressed: () {
                  // TODO: Open support chat or email
                },
                child: const Text('Contact Support'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}