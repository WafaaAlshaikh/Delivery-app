// lib/services/order_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../data/models/order_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class OrderResult {
  final bool success;
  final String message;
  final OrderModel? order;

  OrderResult({required this.success, required this.message, this.order});
}

class OrdersListResult {
  final bool success;
  final String message;
  final List<OrderModel> orders;

  OrdersListResult({
    required this.success,
    this.message = '',
    this.orders = const [],
  });
}

class OrderService {
  final ApiService _apiService = ApiService();
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

  Future<OrderResult> createOrder({
    required String storeId,
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    double? deliveryLat,
    double? deliveryLng,
    required String paymentMethod,
    String? specialInstructions,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.orders,
        data: {
          'restaurant_id': storeId,
          'items': items,
          'delivery_address': deliveryAddress,
          'delivery_lat': deliveryLat,
          'delivery_lng': deliveryLng,
          'payment_method': paymentMethod,
          'special_instructions': specialInstructions,
        },
      );

      final data = response.data;
      return OrderResult(
        success: data['success'] ?? false,
        message: data['message'] ?? '',
        order: data['order'] != null ? OrderModel.fromJson(data['order']) : null,
      );
    } catch (e) {
      if (kDebugMode) print('createOrder error: $e');
      return OrderResult(
        success: false,
        message: 'Network error while placing your order',
      );
    }
  }

  Future<OrdersListResult> getMyOrders() async {
    try {
      final response = await _apiService.get(ApiConstants.myOrders);
      final data = response.data;
      if (data['success'] == true && data['orders'] != null) {
        return OrdersListResult(
          success: true,
          orders: (data['orders'] as List)
              .map((o) => OrderModel.fromJson(o))
              .toList(),
        );
      }
      return OrdersListResult(success: true, orders: []);
    } catch (e) {
      if (kDebugMode) print('getMyOrders error: $e');
      return OrdersListResult(
        success: false,
        message: 'Network error while fetching your orders',
      );
    }
  }

  Future<OrdersListResult> getAvailableOrders({
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
          return OrdersListResult(
            success: true,
            orders: ordersData
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
                .toList(),
          );
        }
        return OrdersListResult(success: true, orders: []);
      } else {
        return OrdersListResult(
          success: false,
          message: response.data['message'] ?? 'Failed to load orders',
        );
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
      return OrdersListResult(
        success: false,
        message: 'Network error while fetching available orders',
      );
    }
  }

  Future<OrderResult> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final response = await _apiService.put(
        ApiConstants.orderStatus(orderId),
        data: {'status': status},
      );
      final data = response.data;
      return OrderResult(
        success: data['success'] ?? false,
        message: data['message'] ?? '',
        order: data['order'] != null ? OrderModel.fromJson(data['order']) : null,
      );
    } catch (e) {
      if (kDebugMode) print('updateOrderStatus error: $e');
      return OrderResult(
        success: false,
        message: 'Network error while updating order status',
      );
    }
  }

  Future<OrderModel> getOrderDetails(String orderId) async {
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

  Future<OrderModel> getOrderDetailsById(int orderId) async {
    return getOrderDetails(orderId.toString());
  }
}