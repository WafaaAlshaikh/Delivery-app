// lib/services/scheduling_service.dart

import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../data/models/scheduled_order_model.dart';
import '../services/storage_service.dart';

class SchedulingService {
  final Dio _dio = Dio();
  final StorageService _storageService = StorageService();

  SchedulingService() {
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

  Future<List<ScheduledOrder>> getScheduledOrders({DateTime? date}) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, dynamic>{};
      if (date != null) {
        queryParams['date'] = date.toIso8601String().split('T')[0];
      }

      final response = await _dio.get(
        '/api/driver/scheduling/orders',
        queryParameters: queryParams,
        options: Options(headers: headers),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as List? ?? [];
        return data.map((e) => ScheduledOrder.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Get scheduled orders error: $e');
      return [];
    }
  }

  Future<RouteOptimization> optimizeRoute({DateTime? date}) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, dynamic>{};
      if (date != null) {
        queryParams['date'] = date.toIso8601String().split('T')[0];
      }

      final response = await _dio.get(
        '/api/driver/scheduling/optimize-route',
        queryParameters: queryParams,
        options: Options(headers: headers),
      );

      if (response.data['success'] == true) {
        return RouteOptimization.fromJson(response.data['data']);
      }
      return RouteOptimization(
        route: [],
        totalDistance: 0,
        totalTime: 0,
        estimatedEarnings: 0,
      );
    } catch (e) {
      print('❌ Optimize route error: $e');
      return RouteOptimization(
        route: [],
        totalDistance: 0,
        totalTime: 0,
        estimatedEarnings: 0,
      );
    }
  }

  Future<AISuggestion> suggestOptimalTime({required String orderId}) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '/api/driver/scheduling/suggest-time',
        data: {'order_id': orderId},
        options: Options(headers: headers),
      );

      if (response.data['success'] == true) {
        return AISuggestion.fromJson(response.data['data']);
      }
      return AISuggestion(
        suggestedTime: DateTime.now(),
        confidence: 0,
        reasoning: 'لا يمكن اقتراح وقت',
      );
    } catch (e) {
      print('❌ Suggest optimal time error: $e');
      return AISuggestion(
        suggestedTime: DateTime.now(),
        confidence: 0,
        reasoning: 'خطأ في الاقتراح',
      );
    }
  }

Future<ScheduledOrder?> createSchedule({
  required String orderId,
  required DateTime scheduledTime,
  int priority = 0,
}) async {
  try {
    final headers = await _getHeaders();
    
    final orderIdInt = int.tryParse(orderId);
    if (orderIdInt == null) {
      throw Exception('Invalid order ID');
    }

    final response = await _dio.post(
      '/api/driver/scheduling/create',
      data: {
        'order_id': orderIdInt, 
        'scheduled_time': scheduledTime.toIso8601String(),
        'priority': priority,
      },
      options: Options(headers: headers),
    );

    if (response.data['success'] == true) {
      return ScheduledOrder.fromJson(response.data['data']);
    }
    return null;
  } catch (e) {
    print('❌ Create schedule error: $e');
    return null;
  }
}
  Future<ScheduledOrder?> confirmSchedule({required String scheduledId}) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '/api/driver/scheduling/confirm/$scheduledId',
        options: Options(headers: headers),
      );

      if (response.data['success'] == true) {
        return ScheduledOrder.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('❌ Confirm schedule error: $e');
      return null;
    }
  }

  Future<ScheduledOrder?> cancelSchedule({
    required String scheduledId,
    String? reason,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '/api/driver/scheduling/cancel/$scheduledId',
        data: {'reason': reason},
        options: Options(headers: headers),
      );

      if (response.data['success'] == true) {
        return ScheduledOrder.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('❌ Cancel schedule error: $e');
      return null;
    }
  }
}