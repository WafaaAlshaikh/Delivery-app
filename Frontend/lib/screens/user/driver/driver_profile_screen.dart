// lib/screens/user/driver/driver_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/models/user_model.dart';
import '../../../core/localization/app_localizations.dart';
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

  late List<String> _vehicleTypes;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    final profile = ref.read(driverProvider).profile;
    
    _vehicleTypes = ['Bicycle', 'Motorcycle', 'Car', 'Van', 'Company'];
    
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
    final tr = context.tr;
    
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).updateProfile(
        fullName: _fullNameController.text,
        phone: _phoneController.text,
      );

      await ref.read(driverProvider.notifier).updateProfile(
        vehicleType: _selectedVehicleType,
        vehiclePlate: _vehiclePlateController.text,
        vehicleColor: _vehicleColorController.text,
        vehicleModel: _vehicleModelController.text,
        licenseNumber: _licenseNumberController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${tr.t('profile_updated_success')}'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${tr.t('error_occurred')}: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final user = ref.watch(authProvider).user;
    
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          tr.t('edit_profile'),
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
              _buildProfileImage(user),
              const SizedBox(height: 24),

              CustomTextField(
                controller: _fullNameController,
                label: tr.t('full_name'),
                hint: tr.t('enter_full_name'),
                prefixIcon: const Icon(Icons.person_outline),
                validator: (v) => v!.isEmpty ? tr.t('validation_name_required') : null,
              ),
              const SizedBox(height: 12),
              
              CustomTextField(
                controller: _phoneController,
                label: tr.t('phone_number'),
                hint: tr.t('enter_phone'),
                prefixIcon: const Icon(Icons.phone_outlined),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              _buildVehicleSection(tr),
              const SizedBox(height: 24),

              CustomButton(
                text: tr.t('save_changes'),
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

  Widget _buildProfileImage(UserModel? user) {
    return Center(
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
    );
  }

  Widget _buildVehicleSection(AppLocalizations tr) {
    final vehicleTypeLabels = {
      'Bicycle': tr.t('vehicle_bicycle'),
      'Motorcycle': tr.t('vehicle_motorcycle'),
      'Car': tr.t('vehicle_car'),
      'Van': tr.t('vehicle_van'),
      'Company': tr.t('vehicle_company'),
    };

    return Container(
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
            tr.t('vehicle_information'),
            style: AppTypography.display(14, weight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          
          DropdownButtonFormField<String>(
            value: _selectedVehicleType,
            decoration: InputDecoration(
              labelText: tr.t('vehicle_type'),
              border: const OutlineInputBorder(),
            ),
            items: _vehicleTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(vehicleTypeLabels[type] ?? type),
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
            label: tr.t('vehicle_plate'),
            hint: tr.t('vehicle_plate_hint'),
            prefixIcon: const Icon(Icons.car_rental_outlined),
          ),
          const SizedBox(height: 12),
          
          CustomTextField(
            controller: _vehicleColorController,
            label: tr.t('vehicle_color'),
            hint: tr.t('vehicle_color_hint'),
            prefixIcon: const Icon(Icons.palette_outlined),
          ),
          const SizedBox(height: 12),
          
          CustomTextField(
            controller: _vehicleModelController,
            label: tr.t('vehicle_model'),
            hint: tr.t('vehicle_model_hint'),
            prefixIcon: const Icon(Icons.model_training),
          ),
          const SizedBox(height: 12),
          
          CustomTextField(
            controller: _licenseNumberController,
            label: tr.t('license_number'),
            hint: tr.t('license_number_hint'),
            prefixIcon: const Icon(Icons.credit_card_outlined),
          ),
        ],
      ),
    );
  }
}