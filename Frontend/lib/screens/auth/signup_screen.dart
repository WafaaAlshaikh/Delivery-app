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
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _RoleDetailOption {
  final String value; 
  final String label;
  final IconData icon;
  const _RoleDetailOption(this.value, this.label, this.icon);
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreeTerms = false;
  bool _obscureConfirmPassword = true;
  int _step = 0;

  String _selectedRole = 'Customer'; 
  String? _selectedDetail; 

  static const _roles = [
    RoleOption(value: 'Customer', icon: Icons.person_outline_rounded, label: 'Customer'),
    RoleOption(value: 'Merchant', icon: Icons.storefront_outlined, label: 'Merchant'),
    RoleOption(value: 'Driver', icon: Icons.two_wheeler_rounded, label: 'Driver'),
  ];

  static const _businessCategories = [
    _RoleDetailOption('Restaurant', 'Restaurant', Icons.restaurant_outlined),
    _RoleDetailOption('Pharmacy', 'Pharmacy', Icons.local_pharmacy_outlined),
    _RoleDetailOption('Furniture', 'Furniture', Icons.chair_outlined),
    _RoleDetailOption('Other', 'Other Business', Icons.category_outlined),
  ];

  static const _vehicleTypes = [
    _RoleDetailOption('Bicycle', 'Bicycle', Icons.pedal_bike_rounded),
    _RoleDetailOption('Motorcycle', 'Motorcycle / Scooter', Icons.two_wheeler_rounded),
    _RoleDetailOption('Car', 'Car', Icons.directions_car_rounded),
    _RoleDetailOption('Van', 'Van / Cargo', Icons.airport_shuttle_rounded),
    _RoleDetailOption('Company', 'Company Fleet', Icons.business_center_rounded),
  ];

  List<_RoleDetailOption> get _detailOptions =>
      _selectedRole == 'Merchant' ? _businessCategories : _vehicleTypes;

  bool get _needsDetailStep => _selectedRole == 'Merchant' || _selectedRole == 'Driver';

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _goToDetailStepOrSubmit(AuthNotifier authNotifier) {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms of Service')),
      );
      return;
    }

    if (_needsDetailStep) {
      setState(() => _step = 1);
    } else {
      _submit(authNotifier);
    }
  }

  void _submit(AuthNotifier authNotifier) {
    authNotifier.signup(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      phone: _phoneController.text.trim(),
      role: _selectedRole,
      businessType: _selectedDetail,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    if (authState.authResponse?.tempToken != null && authState.authResponse?.success == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
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
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _step == 0
                ? _buildStepOne(context, authState, authNotifier)
                : _buildStepTwo(context, authState, authNotifier),
          ),
        ),
      ),
    );
  }

  Widget _buildStepOne(BuildContext context, dynamic authState, AuthNotifier authNotifier) {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('step0'),
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
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Re-enter your password',
            obscureText: _obscureConfirmPassword,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.ink300,
              ),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please confirm your password';
              if (value != _passwordController.text) return 'Passwords do not match';
              return null;
            },
          ),
          
          const SizedBox(height: 20),
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
          Text('I want to sign up as',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.ink500)),
          const SizedBox(height: 10),
          RoleSelector(
            options: _roles,
            selected: _selectedRole,
            onChanged: (value) => setState(() {
              _selectedRole = value;
              _selectedDetail = null; 
            }),
          ),
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
            text: _needsDetailStep ? 'Continue' : 'Create account',
            icon: Icons.arrow_forward_rounded,
            isLoading: authState.isLoading,
            onPressed: () => _goToDetailStepOrSubmit(authNotifier),
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
    );
  }

  Widget _buildStepTwo(BuildContext context, dynamic authState, AuthNotifier authNotifier) {
    final isMerchant = _selectedRole == 'Merchant';

    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        IconButton(
          onPressed: () => setState(() => _step = 0),
          icon: const Icon(Icons.arrow_back_rounded),
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        AuthHeader(
          icon: isMerchant ? Icons.storefront_outlined : Icons.two_wheeler_rounded,
          title: isMerchant ? 'Business category' : 'Vehicle type',
          subtitle: isMerchant
              ? 'Select the category that best describes your store'
              : 'Select the vehicle you\'ll use for deliveries',
        ),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.15,
          children: _detailOptions.map((option) {
            final isSelected = _selectedDetail == option.value;
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _selectedDetail = option.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(option.icon, color: AppColors.primary, size: 26),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      option.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.primary : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (authState.error != null) ...[
          const SizedBox(height: 14),
          AuthErrorBanner(message: authState.error!),
        ],
        const SizedBox(height: 24),
        CustomButton(
          text: 'Create account',
          icon: Icons.check_rounded,
          isLoading: authState.isLoading,
          onPressed: _selectedDetail == null ? null : () => _submit(authNotifier),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}