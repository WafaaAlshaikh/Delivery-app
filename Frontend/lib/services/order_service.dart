// frontend/lib/services/order_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../data/models/order_model.dart';
import 'storage_service.dart';

class OrderService {
  final Dio _dio = Dio();
  final StorageService _storageService = StorageService();

  OrderService() {
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



Future<List<OrderModel>> getAvailableOrders({
  double? latitude,
  double? longitude,
  double radius = 10,
  String sortBy = 'distance',
  String filterBy = 'all',
}) async {
  try {
    final headers = await _getHeaders();
    
    final queryParams = <String, dynamic>{};
    if (latitude != null) queryParams['latitude'] = latitude;
    if (longitude != null) queryParams['longitude'] = longitude;
    queryParams['radius'] = radius;
    queryParams['sortBy'] = sortBy;
    queryParams['filterBy'] = filterBy;
    queryParams['limit'] = 50;

    final response = await _dio.get(
      '/api/driver/orders/available',
      queryParameters: queryParams,
      options: Options(headers: headers),
    );

    if (kDebugMode) {
      print('📦 Response status: ${response.statusCode}');
      print('📦 Response data: ${response.data}');
    }

    if (response.data['success'] == true) {
      final data = response.data['data'];
      if (data != null) {
        final ordersData = data['orders'] as List? ?? [];
        if (kDebugMode) {
          print('📦 Found ${ordersData.length} orders');
        }
        return ordersData
            .map((json) {
              try {
                return OrderModel.fromJson(json);
              } catch (e) {
                print('❌ Error parsing order: $e');
                print('❌ JSON: $json');
                return null;
              }
            })
            .where((order) => order != null)
            .cast<OrderModel>()
            .toList();
      }
      return [];
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load orders');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Get available orders error: $e');
      if (e is DioException) {
        print('❌ Dio error type: ${e.type}');
        print('❌ Dio error message: ${e.message}');
        print('❌ Dio error response: ${e.response?.data}');
      }
    }
    rethrow;
  }
}

  Future<OrderModel> getOrderDetails(int orderId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/driver/orders/$orderId',
        options: Options(headers: headers),
      );

      if (response.data['success'] == true) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load order details');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get order details error: $e');
      }
      rethrow;
    }
  }
}