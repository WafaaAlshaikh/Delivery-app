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


Future<Map<String, dynamic>> getAvailableOffers() async {
  try {
    final headers = await _getHeaders();
    final response = await _dio.get(
      '/api/driver/offers',
      options: Options(headers: headers),
    );
    return response.data;
  } catch (e) {
    if (kDebugMode) {
      print('❌ Get available offers error: $e');
    }
    rethrow;
  }
}

Future<Map<String, dynamic>> acceptOffer(int offerId) async {
  try {
    final headers = await _getHeaders();
    final response = await _dio.put(
      '/api/driver/offers/$offerId/accept',
      options: Options(headers: headers),
    );
    return response.data;
  } catch (e) {
    if (kDebugMode) {
      print('❌ Accept offer error: $e');
    }
    rethrow;
  }
}

Future<Map<String, dynamic>> rejectOffer(int offerId, {String? reason}) async {
  try {
    final headers = await _getHeaders();
    final response = await _dio.put(
      '/api/driver/offers/$offerId/reject',
      data: {'reason': reason},
      options: Options(headers: headers),
    );
    return response.data;
  } catch (e) {
    if (kDebugMode) {
      print('❌ Reject offer error: $e');
    }
    rethrow;
  }
}


Future<Map<String, dynamic>> updateOrderStatus({
  required int orderId,
  required int statusId,
  String? notes,
  double? latitude,
  double? longitude,
}) async {
  try {
    final headers = await _getHeaders();
    print('📨 Updating order status:');
    print('  orderId: $orderId');
    print('  statusId: $statusId');
    print('  latitude: $latitude');
    print('  longitude: $longitude');
    
    final response = await _dio.put(
      '/api/driver/orders/$orderId/status',
      data: {
        'status_id': statusId,
        'notes': notes,
        'latitude': latitude,
        'longitude': longitude,
      },
      options: Options(headers: headers),
    );
    
    print('✅ Update order status response: ${response.data}');
    return response.data;
  } catch (e) {
    print('❌ Update order status error: $e');
    if (e is DioException) {
      print('❌ Response data: ${e.response?.data}');
      print('❌ Status code: ${e.response?.statusCode}');
    }
    rethrow;
  }
}

Future<Map<String, dynamic>> updateDeliveryLocation({
  required int orderId,
  required double latitude,
  required double longitude,
}) async {
  try {
    final headers = await _getHeaders();
    final response = await _dio.put(
      '/api/driver/orders/$orderId/location',
      data: {
        'latitude': latitude,
        'longitude': longitude,
      },
      options: Options(headers: headers),
    );
    return response.data;
  } catch (e) {
    if (kDebugMode) {
      print('❌ Update delivery location error: $e');
    }
    rethrow;
  }
}


Future<Map<String, dynamic>?> getCurrentDelivery() async {
  try {
    final headers = await _getHeaders();
    print('🔍 Fetching current delivery...');
    
    final response = await _dio.get(
      '/api/driver/delivery/current',
      options: Options(
        headers: headers,
        validateStatus: (status) {
          return status! < 500;
        },
      ),
    );
    
    print('📦 Current delivery response status: ${response.statusCode}');
    print('📦 Current delivery response data: ${response.data}');
    
    if (response.statusCode == 404) {
      print('❌ No active delivery (404)');
      return null;
    }
    
    return response.data;
  } catch (e) {
    print('❌ Get current delivery error: $e');
    return null;
  }
}
}