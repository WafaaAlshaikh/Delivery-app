// lib/screens/auth/driver_onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom/custom_button.dart';
import '../../widgets/custom/custom_text_field.dart';
import 'driver_pending_screen.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class DriverOnboardingScreen extends ConsumerStatefulWidget {
  const DriverOnboardingScreen({super.key});

  @override
  ConsumerState<DriverOnboardingScreen> createState() =>
      _DriverOnboardingScreenState();
}

class _DriverOnboardingScreenState
    extends ConsumerState<DriverOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _vehiclePlateController = TextEditingController();
  final _vehicleColorController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  String? _licenseImagePath;
  bool _isLoading = false;

  static const List<String> _vehicleTypes = [
    'Bicycle',
    'Motorcycle',
    'Car',
    'Van',
    'Company'
  ];

  @override
  void dispose() {
    _vehiclePlateController.dispose();
    _vehicleColorController.dispose();
    _vehicleModelController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickLicenseImage() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _licenseImagePath = file.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _submitOnboarding() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authProvider);
    final driverStatus = authState.driverStatus;
    final vehicleType = driverStatus?['vehicle_type'] as String?;

    if (vehicleType == null || vehicleType.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle type not found. Please sign up again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.completeDriverOnboarding(
      vehicleType: vehicleType,
      vehiclePlate: _vehiclePlateController.text,
      vehicleColor: _vehicleColorController.text,
      vehicleModel: _vehicleModelController.text,
      licenseNumber: _licenseNumberController.text,
      licenseImage: _licenseImagePath,
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (!mounted) return;

    if (success) {
      final driverStatus = await authNotifier.getDriverStatus();

      if (driverStatus?['status'] == 'Active') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DriverPendingScreen(),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit onboarding. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final driverStatus = authState.driverStatus;
    final vehicleType = driverStatus?['vehicle_type'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8), 
      appBar: AppBar(
        title: Text(
          'Complete Driver Profile',
          style: AppTypography.display(18, weight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _showExitConfirmation,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560), 
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildFormCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.delivery_dining_rounded,
            size: 28,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Complete Your Driver Profile',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Complete your driver profile to start delivering. '
          'Your application will be automatically reviewed.',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    final authState = ref.watch(authProvider);
    final driverStatus = authState.driverStatus;
    final vehicleType = driverStatus?['vehicle_type'] as String?;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildVehicleTypeDisplay(vehicleType),
          const SizedBox(height: 16),

          _fieldLabel('Vehicle Details'),
          const SizedBox(height: 6),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _vehiclePlateController,
                  label: 'Plate Number',
                  hint: 'ABC 1234',
                  prefixIcon: const Icon(Icons.car_rental_outlined),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: _vehicleColorController,
                  label: 'Color',
                  hint: 'Red, Blue, etc.',
                  prefixIcon: const Icon(Icons.palette_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          CustomTextField(
            controller: _vehicleModelController,
            label: 'Vehicle Model',
            hint: 'Toyota Camry 2020',
            prefixIcon: const Icon(Icons.model_training),
          ),
          const SizedBox(height: 12),

          CustomTextField(
            controller: _licenseNumberController,
            label: 'License Number *',
            hint: 'Enter your license number',
            prefixIcon: const Icon(Icons.credit_card_outlined),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'License number is required';
              }
              if (value.length < 6) {
                return 'License number must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildLicenseImageUpload(),
          const SizedBox(height: 24),

          _buildRequirementsCheck(),
          const SizedBox(height: 24),

          CustomButton(
            text: 'Submit for Approval',
            icon: Icons.send_outlined,
            isLoading: _isLoading,
            onPressed: _submitOnboarding,
          ),
          const SizedBox(height: 12),
          Text(
            'Your application will be reviewed automatically if all requirements are met.',
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleTypeDisplay(String? vehicleType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Vehicle Type *'),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected from signup',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                    Text(
                      vehicleType ?? 'Not selected',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildLicenseImageUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'License Image',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickLicenseImage,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _licenseImagePath != null ? AppColors.success : Colors.grey.shade300,
                width: _licenseImagePath != null ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                if (_licenseImagePath != null) ...[
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Image uploaded',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to change',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ] else ...[
                  const Icon(
                    Icons.upload_file_outlined,
                    color: Colors.grey,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to upload license image',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '(Optional - Recommended)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementsCheck() {
    final isValid = _formKey.currentState?.validate() ?? false;
    final hasPlate = _vehiclePlateController.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✅ Requirements for Auto-Approval',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.accentDark,
            ),
          ),
          const SizedBox(height: 8),
          _RequirementItem(
            text: 'Vehicle type selected (from signup)',
            checked: true,
          ),
          _RequirementItem(
            text: 'Valid license number (6+ characters)',
            checked: _licenseNumberController.text.length >= 6,
          ),
          _RequirementItem(
            text: 'Vehicle plate number',
            checked: hasPlate,
          ),
          _RequirementItem(
            text: 'Completed all required fields',
            checked: isValid,
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Exit Onboarding?'),
        content: const Text(
          'You can complete your profile later from the settings. '
          'You won\'t be able to start delivering until it\'s complete.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String text;
  final bool checked;

  const _RequirementItem({
    required this.text,
    required this.checked,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_circle : Icons.circle_outlined,
            color: checked ? AppColors.success : AppColors.ink300,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: checked ? AppColors.ink900 : AppColors.ink500,
              fontWeight: checked ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}