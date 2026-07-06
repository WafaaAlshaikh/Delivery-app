// lib/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart'; 

class LocationService {
  Future<bool> checkAndRequestPermissions() async {
    if (kIsWeb) {
      try {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          final requested = await Geolocator.requestPermission();
          return requested != LocationPermission.denied;
        }
        return permission != LocationPermission.denied;
      } catch (e) {
        return true;
      }
    }

    final status = await Permission.location.request();
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      final newStatus = await Permission.location.request();
      return newStatus.isGranted;
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return false;
  }

Future<Position?> getCurrentLocation() async {
  try {
    final hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );

    return position;
  } catch (e) {
    print('❌ Error getting location: $e');
    return null;
  }
}
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        timeLimit: Duration(seconds: 5),
      ),
    );
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final street = place.street ?? '';
        final city = place.locality ?? place.administrativeArea ?? '';
        final country = place.country ?? '';
        return '$street, $city, $country';
      }
      return 'Unknown location';
    } catch (e) {
      print('❌ Error getting address: $e');
      return 'Unable to get address';
    }
  }

  Future<Placemark?> getPlacemarkFromLatLng(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        return placemarks.first;
      }
      return null;
    } catch (e) {
      print('❌ Error getting placemark: $e');
      return null;
    }
  }
}