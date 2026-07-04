// lib/screens/auth/driver_onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom/custom_button.dart';
import '../../widgets/custom/custom_text_field.dart';
import 'driver_pending_screen.dart';
import '../home/home_screen.dart';

class DriverOnboardingScreen extends ConsumerStatefulWidget {
  const DriverOnboardingScreen({super.key});

  @override
  ConsumerState<DriverOnboardingScreen> createState() => _DriverOnboardingScreenState();
}

class _DriverOnboardingScreenState extends ConsumerState<DriverOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _vehiclePlateController = TextEditingController();
  final _vehicleColorController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  
  // State
  String? _selectedVehicleType;
  String? _licenseImagePath;
  File? _licenseImageFile;
  bool _isLoading = false;
  
  // Vehicle types
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
      // Use the static pickFiles API to avoid referencing `platform` getter
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _licenseImagePath = file.path;
          if (file.path != null) {
            _licenseImageFile = File(file.path!);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }

  Future<void> _submitOnboarding() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ Validate vehicle type
    if (_selectedVehicleType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a vehicle type'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.completeDriverOnboarding(
      vehicleType: _selectedVehicleType!,
      vehiclePlate: _vehiclePlateController.text,
      vehicleColor: _vehicleColorController.text,
      vehicleModel: _vehicleModelController.text,
      licenseNumber: _licenseNumberController.text,
      licenseImage: _licenseImagePath,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      // ✅ Navigate to appropriate screen based on approval status
      final driverStatus = await authNotifier.getDriverStatus();
      
      if (driverStatus?['status'] == 'Active') {
        // ✅ Auto-approved! Go to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // ✅ Pending or needs review
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
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          'Complete Driver Profile',
          style: AppTypography.display(18, weight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            // Show confirmation dialog
            _showExitConfirmation();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Header
                _buildHeader(),
                const SizedBox(height: 24),
                
                // ✅ Vehicle Type
                _buildVehicleTypeDropdown(),
                const SizedBox(height: 16),
                
                // ✅ Vehicle Details
                CustomTextField(
                  controller: _vehiclePlateController,
                  label: 'Vehicle Plate',
                  hint: 'ABC 1234',
                  prefixIcon: const Icon(Icons.car_rental_outlined),
                ),
                const SizedBox(height: 12),
                
                CustomTextField(
                  controller: _vehicleColorController,
                  label: 'Vehicle Color',
                  hint: 'Red, Blue, etc.',
                  prefixIcon: const Icon(Icons.palette_outlined),
                ),
                const SizedBox(height: 12),
                
                CustomTextField(
                  controller: _vehicleModelController,
                  label: 'Vehicle Model',
                  hint: 'Toyota Camry 2020',
                  prefixIcon: const Icon(Icons.model_training),
                ),
                const SizedBox(height: 12),
                
                // ✅ License Information
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
                const SizedBox(height: 12),
                
                // ✅ License Image Upload
                _buildLicenseImageUpload(),
                const SizedBox(height: 24),
                
                // ✅ Requirements Check
                _buildRequirementsCheck(),
                const SizedBox(height: 24),
                
                // ✅ Submit Button
                CustomButton(
                  text: 'Submit for Approval',
                  icon: Icons.send_outlined,
                  isLoading: _isLoading,
                  onPressed: _submitOnboarding,
                ),
                const SizedBox(height: 16),
                
                // ✅ Info Text
                _buildInfoText(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.delivery_dining_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Almost there! 🚗',
          style: AppTypography.display(20, weight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Complete your driver profile to start delivering. '
          'Your application will be automatically reviewed.',
          style: AppTypography.body(14, color: AppColors.ink500),
        ),
      ],
    );
  }

  Widget _buildVehicleTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicle Type *',
          style: AppTypography.body(14, weight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedVehicleType,
              isExpanded: true,
              hint: Text(
                'Select vehicle type',
                style: AppTypography.body(14, color: AppColors.ink300),
              ),
              items: _vehicleTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    type,
                    style: AppTypography.body(14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVehicleType = value;
                });
              },
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (_selectedVehicleType == null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Please select a vehicle type',
              style: AppTypography.body(12, color: AppColors.error),
            ),
          ),
      ],
    );
  }

  Widget _buildLicenseImageUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'License Image',
          style: AppTypography.body(14, weight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickLicenseImage,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _licenseImagePath != null ? AppColors.success : AppColors.border,
              ),
            ),
            child: Column(
              children: [
                if (_licenseImagePath != null) ...[
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Image uploaded',
                    style: AppTypography.body(14, weight: FontWeight.w600, color: AppColors.success),
                  ),
                ] else ...[
                  Icon(
                    Icons.upload_file_outlined,
                    color: AppColors.ink300,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to upload license image',
                    style: AppTypography.body(14, color: AppColors.ink300),
                  ),
                  Text(
                    '(Optional - Recommended)',
                    style: AppTypography.body(12, color: AppColors.ink300),
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
            style: AppTypography.body(14, weight: FontWeight.w700, color: AppColors.accentDark),
          ),
          const SizedBox(height: 8),
          _RequirementItem(
            text: 'Valid license number (6+ characters)',
            checked: _licenseNumberController.text.length >= 6,
          ),
          _RequirementItem(
            text: 'Vehicle type selected',
            checked: _selectedVehicleType != null,
          ),
          _RequirementItem(
            text: 'Vehicle plate number',
            checked: _vehiclePlateController.text.isNotEmpty,
          ),
          _RequirementItem(
            text: 'Completed all required fields',
            checked: isValid,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'If all requirements are met, your account will be approved '
              'automatically. You\'ll receive a confirmation email.',
              style: AppTypography.body(12, color: AppColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Onboarding?'),
        content: const Text(
          'You can complete your profile later from the settings. '
          'You won\'t be able to start delivering until it\'s complete.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

// ✅ Requirement Item Widget
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
            style: AppTypography.body(12, 
              color: checked ? AppColors.ink900 : AppColors.ink500,
              weight: checked ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}