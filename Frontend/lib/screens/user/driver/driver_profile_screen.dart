// lib/screens/user/driver/driver_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/driver_provider.dart';
import '../../../widgets/custom/custom_button.dart';
import '../../../widgets/custom/custom_text_field.dart';

class DriverProfileScreen extends ConsumerStatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  ConsumerState<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends ConsumerState<DriverProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _vehiclePlateController;
  late TextEditingController _vehicleColorController;
  late TextEditingController _vehicleModelController;
  late TextEditingController _licenseNumberController;
  
  bool _isLoading = false;
  String? _selectedVehicleType;

  final List<String> _vehicleTypes = ['Bicycle', 'Motorcycle', 'Car', 'Van', 'Company'];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    final profile = ref.read(driverProvider).profile;
    
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _vehiclePlateController = TextEditingController(text: profile?['vehicle_plate'] ?? '');
    _vehicleColorController = TextEditingController(text: profile?['vehicle_color'] ?? '');
    _vehicleModelController = TextEditingController(text: profile?['vehicle_model'] ?? '');
    _licenseNumberController = TextEditingController(text: profile?['license_number'] ?? '');
    _selectedVehicleType = profile?['vehicle_type'] ?? 'Motorcycle';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _vehiclePlateController.dispose();
    _vehicleColorController.dispose();
    _vehicleModelController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).updateProfile(
        fullName: _fullNameController.text,
        phone: _phoneController.text,
      );

      await ref.read(driverProvider.notifier).updateProfile(
        vehicle_type: _selectedVehicleType,
        vehicle_plate: _vehiclePlateController.text,
        vehicle_color: _vehicleColorController.text,
        vehicle_model: _vehicleModelController.text,
        license_number: _licenseNumberController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: AppTypography.display(18, weight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppColors.routeGradient,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.transparent,
                        backgroundImage: user?.profileImage != null
                            ? NetworkImage(user!.profileImage!)
                            : null,
                        child: user?.profileImage == null
                            ? Text(
                                user?.fullName?.isNotEmpty == true
                                    ? user!.fullName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              CustomTextField(
                controller: _fullNameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                prefixIcon: const Icon(Icons.person_outline),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: 'Enter your phone number',
                prefixIcon: const Icon(Icons.phone_outlined),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicle Information',
                      style: AppTypography.display(14, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    
                    DropdownButtonFormField<String>(
                      value: _selectedVehicleType,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Type',
                        border: OutlineInputBorder(),
                      ),
                      items: _vehicleTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedVehicleType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    
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
                    
                    CustomTextField(
                      controller: _licenseNumberController,
                      label: 'License Number',
                      hint: 'Enter your license number',
                      prefixIcon: const Icon(Icons.credit_card_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Save Changes',
                icon: Icons.save_outlined,
                isLoading: _isLoading,
                onPressed: _saveProfile,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}