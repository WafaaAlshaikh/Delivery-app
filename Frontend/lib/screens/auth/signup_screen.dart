// lib/screens/auth/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:email_validator/email_validator.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom/custom_button.dart';
import '../../widgets/custom/custom_text_field.dart';
import '../../widgets/motif/auth_bits.dart';
import '../../widgets/motif/auth_shell.dart';
import 'verify_otp_screen.dart';
import 'login_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  final String? role; // ✅ إضافة role كـ parameter اختياري
  final String? businessType; // ✅ إضافة businessType كـ parameter اختياري

  const SignupScreen({
    super.key,
    this.role,
    this.businessType,
  });

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  late String _selectedRole; // ✅ تغيير إلى late String
  bool _agreeTerms = false;

  static const _roles = [
    RoleOption(value: 'Customer', icon: Icons.person_outline_rounded, label: 'Customer'),
    RoleOption(value: 'Merchant', icon: Icons.storefront_outlined, label: 'Merchant'),
    RoleOption(value: 'Driver', icon: Icons.two_wheeler_rounded, label: 'Driver'),
  ];

  @override
  void initState() {
    super.initState();
    // ✅ تعيين الدور الافتراضي من widget.role أو 'Customer'
    _selectedRole = widget.role ?? 'Customer';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    if (authState.authResponse?.tempToken != null && authState.authResponse?.success == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyOtpScreen(
              email: _emailController.text,
              tempToken: authState.authResponse!.tempToken!,
              isVerification: true,
            ),
          ),
        );
      });
    }

    return AuthShell(
      brandHeadline: 'Join the network\nmoving your city.',
      brandCaption: 'Order, sell or deliver — one account, three ways to be part of it.',
      child: ResponsiveCenter(
        maxWidth: 480,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Responsive.isMobile(context)) ...[
                  const SizedBox(height: 8),
                  IconButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    ),
                    icon: const Icon(Icons.arrow_back_rounded),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                ],
                const SizedBox(height: 12),
                const AuthHeader(
                  icon: Icons.rocket_launch_rounded,
                  title: 'Create your account',
                  subtitle: 'Set up your profile and start in under a minute.',
                ),
                const SizedBox(height: 28),
                CustomTextField(
                  controller: _fullNameController,
                  label: 'Full name',
                  hint: 'Enter your full name',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your full name';
                    if (value.length < 2) return 'Name must be at least 2 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
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
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'At least 6 characters',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.ink300,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your password';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone number',
                  hint: 'Optional',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // ✅ إظهار الدور المحدد مسبقاً أو اختياره
                if (widget.role == null) ...[
                  Text('I want to sign up as', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.ink500)),
                  const SizedBox(height: 10),
                  RoleSelector(
                    options: _roles,
                    selected: _selectedRole,
                    onChanged: (value) => setState(() => _selectedRole = value),
                  ),
                ] else ...[
                  // ✅ إذا كان الدور محدداً مسبقاً، عرضه فقط
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _roles.firstWhere((r) => r.value == _selectedRole).icon,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _roles.firstWhere((r) => r.value == _selectedRole).label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        if (widget.businessType != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.businessType!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _agreeTerms,
                        onChanged: (value) => setState(() => _agreeTerms = value ?? false),
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'I agree to the Terms of Service and Privacy Policy',
                        style: TextStyle(fontSize: 12.5, color: AppColors.ink500, height: 1.4),
                      ),
                    ),
                  ],
                ),
                if (authState.error != null) ...[
                  const SizedBox(height: 14),
                  AuthErrorBanner(message: authState.error!),
                ],
                const SizedBox(height: 22),
                CustomButton(
                  text: 'Create account',
                  icon: Icons.arrow_forward_rounded,
                  isLoading: authState.isLoading,
                  onPressed: _agreeTerms
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            // ✅ إرسال البيانات مع role و businessType
                            authNotifier.signup(
                              fullName: _fullNameController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                              phone: _phoneController.text.trim(),
                              role: _selectedRole,
                              businessType: widget.businessType, // ✅ إرسال businessType
                            );
                          }
                        }
                      : null,
                ),
                const SizedBox(height: 20),
                AuthFooterLink(
                  question: 'Already have an account? ',
                  actionText: 'Log in',
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}