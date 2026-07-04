// lib/services/admin_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../services/storage_service.dart';

class AdminService {
  final Dio _dio = Dio();
  final StorageService _storageService = StorageService();

  AdminService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  // ✅ إضافة الـ Token للطلبات
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Authorization': 'Bearer $token',
    };
  }

  // ============================================
  // 📊 DASHBOARD
  // ============================================

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/admin/stats',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Dashboard stats error: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getChartData({String period = 'week'}) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/admin/chart-data',
        queryParameters: {'period': period},
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Chart data error: $e');
      }
      rethrow;
    }
  }

  // ============================================
  // 👥 USERS
  // ============================================

  Future<Map<String, dynamic>> getUsers({
    String? role,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/admin/users',
        queryParameters: {
          if (role != null) 'role': role,
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
          'limit': limit,
        },
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get users error: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserDetails(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/admin/users/$userId',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get user details error: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUserStatus(int userId, bool isActive) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '/api/admin/users/$userId/status',
        data: {'is_active': isActive},
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Update user status error: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUserRole(int userId, String role) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '/api/admin/users/$userId/role',
        data: {'role': role},
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Update user role error: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.delete(
        '/api/admin/users/$userId',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Delete user error: $e');
      }
      rethrow;
    }
  }

  // ============================================
  // 🏪 MERCHANTS
  // ============================================

  Future<Map<String, dynamic>> getMerchants() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/admin/merchants',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get merchants error: $e');
      }
      rethrow;
    }
  }

  // ============================================
  // 🚗 DRIVERS
  // ============================================

  Future<Map<String, dynamic>> getDrivers() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/admin/drivers',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get drivers error: $e');
      }
      rethrow;
    }
  }

  // ============================================
  // 📦 ORDERS
  // ============================================

  Future<Map<String, dynamic>> getOrders({
    int? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/admin/orders',
        queryParameters: {
          if (status != null) 'status': status,
          'page': page,
          'limit': limit,
        },
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get orders error: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/admin/orders/$orderId',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get order details error: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(int orderId, int statusId, {String? notes}) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '/api/admin/orders/$orderId/status',
        data: {
          'status_id': statusId,
          if (notes != null) 'notes': notes,
        },
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Update order status error: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDriverApplications({String status = 'Pending'}) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/admin/driver-applications',
        queryParameters: {'status': status},
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get driver applications error: $e');
      }
      rethrow;
    }
  }

  // ✅ Review driver application
  Future<Map<String, dynamic>> reviewDriverApplication({
    required int profileId,
    required String action, // 'approve', 'reject', 'suspend'
    String? notes,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '/api/admin/driver-applications/$profileId',
        data: {
          'action': action,
          if (notes != null) 'notes': notes,
        },
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Review driver application error: $e');
      }
      rethrow;
    }
  }

  // ✅ Get driver stats
  Future<Map<String, dynamic>> getDriverStats() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/admin/drivers/stats',
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

  // ✅ Get all drivers
  Future<Map<String, dynamic>> getAllDrivers({String? status}) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/admin/drivers/all',
        queryParameters: status != null ? {'status': status} : null,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get all drivers error: $e');
      }
      rethrow;
    }
  }
}