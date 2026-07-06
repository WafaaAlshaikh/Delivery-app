// lib/screens/user/driver/current_delivery_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../providers/driver_provider.dart';
import '../../../services/driver_service.dart';
import '../../../services/location_service.dart';
import '../../../widgets/maps/delivery_tracking_map.dart';
import 'widgets/status_update_button.dart';

class CurrentDeliveryScreen extends ConsumerStatefulWidget {
  const CurrentDeliveryScreen({super.key});

  @override
  ConsumerState<CurrentDeliveryScreen> createState() => _CurrentDeliveryScreenState();
}

class _CurrentDeliveryScreenState extends ConsumerState<CurrentDeliveryScreen> {
  Map<String, dynamic>? _deliveryData;
  bool _isLoading = true;
  String? _error;
  LatLng? _driverLocation;
  LatLng? _businessLocation;
  LatLng? _customerLocation;
  
  int _currentStatus = 5;
  
  final LocationService _locationService = LocationService();
  
  late Timer _locationTimer;

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    return 0.0;
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentDelivery();
    _startLocationUpdates();
  }

  Future<void> _loadCurrentDelivery() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final driverService = ref.read(driverServiceProvider);
      final response = await driverService.getCurrentDelivery();
      
      print('📦 Current delivery response: $response');
      
      if (response == null) {
        print('❌ Response is null');
        setState(() {
          _error = 'No active delivery';
          _isLoading = false;
        });
        return;
      }

      print('📦 Response success: ${response['success']}');
      print('📦 Response data: ${response['data']}');

      if (response['success'] == true) {
        final data = response['data'];
        print('📦 Data: $data');
        
        if (data == null) {
          print('❌ Data is null');
          setState(() {
            _error = 'No active delivery';
            _isLoading = false;
          });
          return;
        }
        
        final order = data['order'];
        print('📦 Order: $order');
        
        if (order == null) {
          print('❌ Order is null');
          setState(() {
            _error = 'No active delivery';
            _isLoading = false;
          });
          return;
        }
        
        final driverLoc = data['driverLocation'];
        
        setState(() {
          _deliveryData = data;
          _currentStatus = order['status_id'] ?? 5;
          
          _businessLocation = LatLng(
            _parseDouble(order['Business']?['latitude']),
            _parseDouble(order['Business']?['longitude']),
          );
          
          _customerLocation = LatLng(
            _parseDouble(order['UserAddress']?['latitude']),
            _parseDouble(order['UserAddress']?['longitude']),
          );
          
          _driverLocation = LatLng(
            _parseDouble(driverLoc?['latitude']),
            _parseDouble(driverLoc?['longitude']),
          );
          
          _isLoading = false;
        });
        
        print('✅ Current delivery loaded successfully!');
        print('📍 Business: ${_businessLocation?.latitude}, ${_businessLocation?.longitude}');
        print('📍 Customer: ${_customerLocation?.latitude}, ${_customerLocation?.longitude}');
        print('📍 Driver: ${_driverLocation?.latitude}, ${_driverLocation?.longitude}');
        
      } else {
        print('❌ Response success is false');
        setState(() {
          _error = response['message'] ?? 'No active delivery';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading current delivery: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateDriverLocation();
    });
  }

  Future<void> _updateDriverLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null && _deliveryData != null) {
        final orderId = _deliveryData!['order']['order_id'];
        final driverService = ref.read(driverServiceProvider);
        
        await driverService.updateDeliveryLocation(
          orderId: orderId,
          latitude: position.latitude,
          longitude: position.longitude,
        );
        
        setState(() {
          _driverLocation = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      // Silent fail - don't show error to user
    }
  }

 
  @override
  void dispose() {
    _locationTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _error == 'No active delivery') {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delivery_dining_outlined,
                size: 80,
                color: AppColors.ink300,
              ),
              const SizedBox(height: 16),
              Text(
                'No Active Delivery',
                style: AppTypography.display(20, weight: FontWeight.w700, color: AppColors.ink500),
              ),
              const SizedBox(height: 8),
              Text(
                'You don\'t have any active delivery right now',
                style: AppTypography.body(14, color: AppColors.ink300),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadCurrentDelivery,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: AppTypography.body(14, color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCurrentDelivery,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_deliveryData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final order = _deliveryData!['order'];
    final business = order['Business'];
    final customer = order['Customer'];
    final address = order['UserAddress'];
    final statusName = order['OrderStatus']['name'];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          'Current Delivery',
          style: AppTypography.display(18, weight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(_currentStatus).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getStatusColor(_currentStatus)),
            ),
            child: Text(
              statusName,
              style: AppTypography.body(
                12,
                weight: FontWeight.w600,
                color: _getStatusColor(_currentStatus),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: DeliveryTrackingMap(
              driverLocation: _driverLocation,
              businessLocation: _businessLocation,
              customerLocation: _customerLocation,
              status: _currentStatus,
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.storefront_outlined,
                        title: business['name'] ?? 'Unknown Store',
                        subtitle: 'Pickup Location',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.person_outline,
                        title: customer['full_name'] ?? 'Unknown Customer',
                        subtitle: address['street'] ?? 'Unknown Address',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                
                _buildStatusButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }


Widget _buildStatusButtons() {
  final current = _currentStatus;
  
  final canPickUp = current == 5; 
  final canOnTheWay = current == 6; 
  final canDeliver = current == 7;

  return Row(
    children: [
      Expanded(
        child: StatusUpdateButton(
          icon: Icons.shopping_bag_outlined,
          label: 'Picked Up',
          isActive: current >= 6,
          isCompleted: current > 6,
          onPressed: canPickUp ? () => _updateStatus(6) : null,
        ),
      ),
      const SizedBox(width: 8),
      
      Expanded(
        child: StatusUpdateButton(
          icon: Icons.directions_car_outlined,
          label: 'On The Way',
          isActive: current >= 7,
          isCompleted: current > 7,
          onPressed: canOnTheWay ? () => _updateStatus(7) : null,
        ),
      ),
      const SizedBox(width: 8),
      
      Expanded(
        child: StatusUpdateButton(
          icon: Icons.check_circle_outline,
          label: 'Delivered',
          isActive: current >= 8,
          isCompleted: current >= 8,
          onPressed: canDeliver ? () => _updateStatus(8) : null,
          isPrimary: true,
        ),
      ),
    ],
  );
}

Future<void> _updateStatus(int newStatus) async {
  if (newStatus == _currentStatus) {
    print('⚠️ Status is already $newStatus, ignoring...');
    return;
  }
  
  if (newStatus < _currentStatus) {
    print('⚠️ Cannot go backwards from $_currentStatus to $newStatus');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Cannot go backwards in status'),
        backgroundColor: AppColors.error,
      ),
    );
    return;
  }

  if (newStatus == 6 && _currentStatus != 5) {
    print('⚠️ Can only go to Picked Up (6) from Driver Assigned (5)');
    return;
  }
  if (newStatus == 7 && _currentStatus != 6) {
    print('⚠️ Can only go to On The Way (7) from Picked Up (6)');
    return;
  }
  if (newStatus == 8 && _currentStatus != 7) {
    print('⚠️ Can only go to Delivered (8) from On The Way (7)');
    return;
  }

  try {
    final orderId = _deliveryData!['order']['order_id'];
    final driverService = ref.read(driverServiceProvider);
    
    print('📨 Updating status to: $newStatus for order: $orderId');
    
    final position = await _locationService.getCurrentLocation();
    
    final response = await driverService.updateOrderStatus(
      orderId: orderId,
      statusId: newStatus,
      latitude: position?.latitude,
      longitude: position?.longitude,
    );
    
    print('✅ Update status response: $response');
    
    if (response['success']) {
      setState(() {
        _currentStatus = newStatus;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${response['message']}'),
          backgroundColor: AppColors.success,
        ),
      );
      
      if (newStatus == 8) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      }
    }
  } catch (e) {
    print('❌ Failed to update status: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Failed to update status: ${e.toString()}'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

  Color _getStatusColor(int status) {
    switch (status) {
      case 5: return AppColors.warning;
      case 6: return AppColors.primary;
      case 7: return AppColors.accent;
      case 8: return AppColors.success;
      default: return AppColors.ink500;
    }
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.ink500),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body(13, weight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: AppTypography.body(11, color: AppColors.ink500),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}