// lib/services/driver_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../services/storage_service.dart';

class DriverService {
  final Dio _dio = Dio();
  final StorageService _storageService = StorageService();

  DriverService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Authorization': 'Bearer $token',
    };
  }

  // ✅ Get Driver Profile
  Future<Map<String, dynamic>> getDriverProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/driver/profile',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get driver profile error: $e');
      }
      rethrow;
    }
  }

  // ✅ Update Driver Profile
  Future<Map<String, dynamic>> updateDriverProfile({
    String? vehicle_type,
    String? vehicle_plate,
    String? vehicle_color,
    String? vehicle_model,
    String? license_number,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '/api/driver/profile',
        data: {
          if (vehicle_type != null) 'vehicle_type': vehicle_type,
          if (vehicle_plate != null) 'vehicle_plate': vehicle_plate,
          if (vehicle_color != null) 'vehicle_color': vehicle_color,
          if (vehicle_model != null) 'vehicle_model': vehicle_model,
          if (license_number != null) 'license_number': license_number,
        },
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Update driver profile error: $e');
      }
      rethrow;
    }
  }

  // ✅ Toggle Online Status
  Future<Map<String, dynamic>> toggleOnline({bool? isOnline}) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '/api/driver/online',
        data: {
          'is_online': isOnline,
        },
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Toggle online error: $e');
      }
      rethrow;
    }
  }

  // ✅ Update Location
  Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '/api/driver/location',
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Update location error: $e');
      }
      rethrow;
    }
  }

  // ✅ Get Driver Stats
  Future<Map<String, dynamic>> getDriverStats() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/driver/stats',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get driver stats error: $e');
      }
      rethrow;
    }
  }
}