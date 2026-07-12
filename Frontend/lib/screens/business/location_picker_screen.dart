// lib/screens/business/location_picker_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/colors.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late GoogleMapController _mapController;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation ?? const LatLng(31.9038, 35.2034);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Store Location'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              if (_selectedLocation != null) {
                Navigator.pop(context, _selectedLocation);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation!,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (latLng) {
              setState(() {
                _selectedLocation = latLng;
              });
            },
            markers: {
              if (_selectedLocation != null)
                Marker(
                  markerId: const MarkerId('selected'),
                  position: _selectedLocation!,
                  draggable: true,
                  onDragEnd: (newPosition) {
                    setState(() {
                      _selectedLocation = newPosition;
                    });
                  },
                ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
          ),

          Center(
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                if (_selectedLocation != null) {
                  Navigator.pop(context, _selectedLocation);
                }
              },
              child: const Text('Confirm Location'),
            ),
          ),
        ],
      ),
    );
  }
}