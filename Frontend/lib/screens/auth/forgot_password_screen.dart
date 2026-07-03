// lib/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:email_validator/email_validator.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom/custom_button.dart';
import '../../widgets/custom/custom_text_field.dart';
import '../../widgets/motif/auth_bits.dart';
import '../../widgets/motif/auth_shell.dart';
import 'verify_otp_screen.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    if (!authState.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authState.authResponse?.success == true &&
        authState.authResponse?.message.contains('OTP') == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyOtpScreen(
              email: _emailController.text,
              tempToken: '',
              isVerification: false,
            ),
          ),
        );
      });
    }

    return AuthShell(
      brandHeadline: 'Forgot something?\nHappens to the best.',
      brandCaption: "We'll send a reset code to your inbox — you'll be back in seconds.",
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              const AuthHeader(
                icon: Icons.key_outlined,
                title: 'Reset your password',
                subtitle: "Enter your email and we'll send a verification code to reset it.",
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _emailController,
                label: 'Email address',
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.mail_outline_rounded),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your email';
                  if (!EmailValidator.validate(value)) return 'Please enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              if (authState.error != null) ...[
                AuthErrorBanner(message: authState.error!),
                const SizedBox(height: 16),
              ],
              CustomButton(
                text: 'Send reset code',
                isLoading: authState.isLoading,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    authNotifier.forgotPassword(email: _emailController.text.trim());
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
