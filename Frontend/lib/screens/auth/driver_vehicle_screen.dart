// lib/screens/auth/driver_vehicle_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import '../../widgets/custom/custom_button.dart';
import 'signup_screen.dart';

class DriverVehicleScreen extends ConsumerStatefulWidget { 
  const DriverVehicleScreen({super.key});

  @override
  ConsumerState<DriverVehicleScreen> createState() => _DriverVehicleScreenState();
}

class _DriverVehicleScreenState extends ConsumerState<DriverVehicleScreen> {
  String _selectedVehicle = 'Motorcycle';
  bool _isLoading = false;

  final Color _driverColor = const Color(0xFF0288D1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Delivery Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _driverColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delivery_dining_rounded,
                        size: 64,
                        color: _driverColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    const Text(
                      'Select Vehicle Type',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please choose the transport method you will use for deliveries',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 32),

                    _buildVehicleCard(
                      type: 'Bicycle',
                      title: 'Bicycle',
                      description: 'Eco-friendly, perfect for short distances',
                      icon: Icons.pedal_bike_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildVehicleCard(
                      type: 'Motorcycle',
                      title: 'Motorcycle / Scooter',
                      description: 'Fast, agile, and best for city traffic',
                      icon: Icons.two_wheeler_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildVehicleCard(
                      type: 'Car',
                      title: 'Personal Car',
                      description: 'Comfortable, handles secure or large orders',
                      icon: Icons.directions_car_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildVehicleCard(
                      type: 'Van',
                      title: 'Van / Cargo',
                      description: 'Ideal for bulk logistics and heavy goods',
                      icon: Icons.airport_shuttle_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildVehicleCard(
                      type: 'Company Driver',
                      title: 'Company Driver',
                      description: 'Using an official corporate fleet vehicle',
                      icon: Icons.business_center_rounded,
                    ),
                    
                    const SizedBox(height: 40),

                    CustomButton(
                      text: 'Complete Registration',
                      isLoading: _isLoading,
                      onPressed: _submitDriverData,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard({
    required String type,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedVehicle == type;

    return InkWell(
      onTap: () => setState(() => _selectedVehicle = type),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _driverColor.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _driverColor : Colors.grey.shade200,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? _driverColor.withOpacity(0.12) 
                  : Colors.black.withOpacity(0.01),
              blurRadius: isSelected ? 10 : 4,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? _driverColor : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? _driverColor : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? _driverColor.withOpacity(0.8) : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: _driverColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  void _submitDriverData() async {
    setState(() => _isLoading = true);

   
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SignupScreen(
          role: 'Driver',
          businessType: _selectedVehicle,
        ),
      ),
    );

    setState(() => _isLoading = false);
  }
}