// lib/screens/auth/verify_otp_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom/custom_button.dart';
import '../../widgets/custom/custom_text_field.dart';
import '../../widgets/motif/auth_bits.dart';
import '../../widgets/motif/auth_shell.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  final String email;
  final String tempToken;
  final bool isVerification;

  const VerifyOtpScreen({
    super.key,
    required this.email,
    required this.tempToken,
    this.isVerification = true,
  });

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  String _error = '';
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 30);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          if (_resendCooldown > 0) _resendCooldown--;
        });
      }
      return _resendCooldown > 0 && mounted;
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  PinTheme _pinTheme({required Color background, required Color border, Color? text}) {
    return PinTheme(
      width: 52,
      height: 56,
      textStyle: GoogleFonts.jetBrainsMono(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: text ?? AppColors.ink900,
      ),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border, width: 1.6),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    if (authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      });
    }

    return AuthShell(
      brandHeadline: 'One code away\nfrom your account.',
      brandCaption: 'We sent a 6-digit code to keep your account secure. Check your inbox.',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              ),
              icon: const Icon(Icons.arrow_back_rounded),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            AuthHeader(
              icon: Icons.mark_email_read_outlined,
              title: widget.isVerification ? 'Verify your email' : 'Reset your password',
              subtitle: widget.isVerification ? 'Enter the code sent to ' : 'Enter the code sent to your email',
              highlight: widget.isVerification ? widget.email : null,
            ),
            const SizedBox(height: 32),
            Center(
              child: Pinput(
                controller: _otpController,
                length: AppConstants.otpLength,
                defaultPinTheme: _pinTheme(background: AppColors.surfaceSunken, border: Colors.transparent),
                focusedPinTheme: _pinTheme(background: Colors.white, border: AppColors.primary),
                submittedPinTheme: _pinTheme(
                  background: AppColors.successSoft,
                  border: AppColors.success,
                  text: AppColors.success,
                ),
                errorPinTheme: _pinTheme(
                  background: AppColors.errorSoft,
                  border: AppColors.error,
                  text: AppColors.error,
                ),
                onChanged: (_) => setState(() => _error = ''),
              ),
            ),
            const SizedBox(height: 16),
            if (authState.error != null || _error.isNotEmpty)
              AuthErrorBanner(message: authState.error ?? _error),
            const SizedBox(height: 20),
            CustomButton(
              text: widget.isVerification ? 'Verify email' : 'Verify code',
              isLoading: authState.isLoading,
              onPressed: () {
                final otp = _otpController.text.trim();
                if (otp.length != AppConstants.otpLength) {
                  setState(() => _error = 'Please enter all 6 digits');
                  return;
                }
                if (widget.isVerification) {
                  authNotifier.verifySignup(email: widget.email, otp: otp);
                } else {
                  _showResetPasswordDialog(context, otp);
                }
              },
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Didn't receive the code?", style: TextStyle(color: AppColors.ink500, fontSize: 13.5)),
                TextButton(
                  onPressed: _resendCooldown > 0 || authState.isLoading
                      ? null
                      : () {
                          if (widget.isVerification) {
                            authNotifier.resendOTP(email: widget.email);
                          } else {
                            authNotifier.forgotPassword(email: widget.email);
                          }
                          _startCooldown();
                        },
                  child: Text(_resendCooldown > 0 ? 'Resend (${_resendCooldown}s)' : 'Resend'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, String otp) {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Reset password', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: newPasswordController,
                label: 'New password',
                hint: 'Enter new password',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a password';
                  if (value.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: confirmPasswordController,
                label: 'Confirm password',
                hint: 'Confirm new password',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please confirm your password';
                  if (value != newPasswordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          Consumer(
            builder: (context, ref, child) {
              final dialogAuthState = ref.watch(authProvider);
              return CustomButton(
                text: 'Reset password',
                width: 140,
                height: 48,
                isLoading: dialogAuthState.isLoading,
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final authNotifier = ref.read(authProvider.notifier);
                    authNotifier.resetPassword(
                      email: widget.email,
                      otp: otp,
                      newPassword: newPasswordController.text.trim(),
                    );
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (!context.mounted) return;
                      if (dialogAuthState.authResponse?.success == true) {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      }
                    });
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
