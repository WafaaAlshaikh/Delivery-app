// lib/services/admin_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../data/models/admin_models.dart';
import '../services/storage_service.dart';

class AdminResult {
  final bool success;
  final String message;

  AdminResult({required this.success, this.message = ''});
}

class AdminService {
  final Dio _dio = Dio();
  final StorageService _storageService = StorageService();

  AdminService() {
    print('🔍 [DEBUG] AdminService constructor called');
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🔍 [DEBUG] Dio Request: ${options.method} ${options.path}');
        print('🔍 [DEBUG] Headers: ${options.headers}');
        print('🔍 [DEBUG] Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('🔍 [DEBUG] Dio Response: ${response.statusCode}');
        print('🔍 [DEBUG] Data: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('❌ [DEBUG] Dio Error: ${error.message}');
        print('❌ [DEBUG] Response: ${error.response?.data}');
        return handler.next(error);
      },
    ));
  }

  Future<Map<String, String>> _getHeaders() async {
    print('🔍 [DEBUG] _getHeaders called');
    final token = await _storageService.getToken();
    print('🔍 [DEBUG] Token: ${token?.substring(0, 20)}...');
    return {
      'Authorization': 'Bearer $token',
    };
  }

  Future<AdminDashboardStats> getDashboardStats() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/admin/stats',
        options: Options(headers: headers),
      );
      if (response.data['success'] == true) {
        return AdminDashboardStats.fromJson(response.data);
      }
      return AdminDashboardStats.empty();
    } catch (e) {
      if (kDebugMode) print('❌ getDashboardStats error: $e');
      return AdminDashboardStats.empty();
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

  Future<Map<String, dynamic>> getUsers({
    String? role,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    print('🔍 [DEBUG] getUsers called');
    print('   ├─ role: $role');
    print('   ├─ search: $search');
    print('   ├─ page: $page');
    print('   └─ limit: $limit');

    try {
      final headers = await _getHeaders();
      final queryParams = {
        if (role != null) 'role': role,
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
        'limit': limit,
      };
      print('🔍 [DEBUG] Query Params: $queryParams');

      final response = await _dio.get(
        '/api/admin/users',
        queryParameters: queryParams,
        options: Options(headers: headers),
      );

      print('🔍 [DEBUG] Response status: ${response.statusCode}');
      print('🔍 [DEBUG] Response data: ${response.data}');
      return response.data;
    } catch (e) {
      print('❌ [DEBUG] getUsers error: $e');
      if (e is DioException) {
        print('❌ [DEBUG] Dio error type: ${e.type}');
        print('❌ [DEBUG] Dio error response: ${e.response?.data}');
        print('❌ [DEBUG] Dio error status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createUser({
    required String fullName,
    required String email,
    required String role,
    required String password,
    String? phone,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '/api/admin/users',
        data: {
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'role': role,
          'password': password,
        },
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Create user error: $e');
        if (e is DioException) {
          print('❌ Response: ${e.response?.data}');
        }
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

  Future<List<AdminStoreModel>> getStores() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/admin/stores',
        options: Options(headers: headers),
      );
      final data = response.data;
      if (data['success'] == true && data['stores'] != null) {
        return (data['stores'] as List)
            .map((s) => AdminStoreModel.fromJson(s))
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ getStores error: $e');
      return [];
    }
  }

  Future<AdminResult> approveStore(String storeId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '/api/admin/stores/$storeId/approve',
        options: Options(headers: headers),
      );
      final data = response.data;
      return AdminResult(success: data['success'] ?? false, message: data['message'] ?? '');
    } catch (e) {
      if (kDebugMode) print('❌ approveStore error: $e');
      return AdminResult(success: false, message: 'Network error while approving store');
    }
  }

  Future<AdminResult> rejectStore(String storeId, {String? reason}) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '/api/admin/stores/$storeId/reject',
        data: {'reason': reason},
        options: Options(headers: headers),
      );
      final data = response.data;
      return AdminResult(success: data['success'] ?? false, message: data['message'] ?? '');
    } catch (e) {
      if (kDebugMode) print('❌ rejectStore error: $e');
      return AdminResult(success: false, message: 'Network error while rejecting store');
    }
  }

  Future<AdminResult> deleteStore(String storeId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.delete(
        '/api/admin/stores/$storeId',
        options: Options(headers: headers),
      );
      final data = response.data;
      return AdminResult(success: data['success'] ?? false, message: data['message'] ?? '');
    } catch (e) {
      if (kDebugMode) print('❌ deleteStore error: $e');
      return AdminResult(success: false, message: 'Network error while deleting store');
    }
  }

  Future<List<AdminCategoryModel>> getCategories() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/admin/categories',
        options: Options(headers: headers),
      );
      final data = response.data;
      if (data['success'] == true && data['categories'] != null) {
        return (data['categories'] as List)
            .map((c) => AdminCategoryModel.fromJson(c))
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ getCategories error: $e');
      return [];
    }
  }

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

  Future<Map<String, dynamic>> reviewDriverApplication({
    required int profileId,
    required String action,
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
}