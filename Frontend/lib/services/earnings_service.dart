// lib/services/earnings_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../core/constants/api_constants.dart';
import '../data/models/earning_model.dart';
import '../services/storage_service.dart';
import 'dart:html' as html if (dart.library.html) 'dart:html';

class EarningsService {
  final Dio _dio = Dio();
  final StorageService _storageService = StorageService();

  EarningsService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🔍 [Earnings API] Request: ${options.method} ${options.path}');
        print('📦 Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ [Earnings API] Response: ${response.statusCode}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('❌ [Earnings API] Error: ${error.message}');
        if (error.response != null) {
          print('📦 Response data: ${error.response?.data}');
        }
        return handler.next(error);
      },
    ));
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Authorization': 'Bearer $token',
    };
  }

Future<void> sendReportByEmail({
  required String toEmail,
  required String filePath,
  required String period,
}) async {
  try {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found');
    }

    final attachment = FileAttachment(file)
      ..fileName = 'earnings_report_${DateTime.now().millisecondsSinceEpoch}.pdf';

    final message = Message()
      ..from = Address('your-email@gmail.com', 'PickNGo Driver')
      ..recipients.add(toEmail)
      ..subject = '📊 تقرير الأرباح - ${DateTime.now().toLocal().toString().split(' ')[0]}'
      ..text = '''
مرحباً،

هذا تقرير الأرباح الخاص بك لفترة $period.

التقرير الكامل مرفق مع هذا البريد.

شكراً لك على عملك المميز،
فريق PickNGo
'''
      ..attachments.add(attachment);

  
    print('✅ Report ready to send to $toEmail');
    
  } catch (e) {
    print('❌ Send report by email error: $e');
    rethrow;
  }
}

  Future<void> shareReport(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: '📊 My Earnings Report\n'
                 'Generated: ${DateTime.now().toLocal().toString().split('.')[0]}',
        );
      } else {
        throw Exception('File not found');
      }
    } catch (e) {
      print('❌ Share report error: $e');
      rethrow;
    }
  }

  Future<void> shareReportWithOptions(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found');
      }

      await Share.shareXFiles(
        [XFile(filePath)],
        text: '📊 My Earnings Report',
        subject: 'Earnings Report',
      );
    } catch (e) {
      print('❌ Share report with options error: $e');
      rethrow;
    }
  }


  Future<EarningsSummary> getEarningsSummary() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/driver/earnings/summary',
        options: Options(headers: headers),
      );

      print('📊 Earnings Summary Response: ${response.data}');

      if (response.data['success'] == true) {
        return EarningsSummary.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to load earnings');
    } catch (e) {
      print('❌ Get earnings summary error: $e');
      if (e is DioException) {
        print('📦 Dio error: ${e.response?.data}');
      }
      rethrow;
    }
  }

  Future<EarningsChartData> getEarningsChart({
    required String period, 
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/driver/earnings/chart',
        queryParameters: {'period': period},
        options: Options(headers: headers),
      );

      print('📈 Chart Response: ${response.data}');

      if (response.data['success'] == true) {
        return EarningsChartData.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to load chart data');
    } catch (e) {
      print('❌ Get earnings chart error: $e');
      rethrow;
    }
  }

Future<List<EarningModel>> getEarningsHistory({
  int page = 1,
  int limit = 20,
  String? status,
  DateTime? from,
  DateTime? to,
}) async {
  try {
    final headers = await _getHeaders();
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status,
      if (from != null) 'from': from.toIso8601String(),
      if (to != null) 'to': to.toIso8601String(),
    };

    final response = await _dio.get(
      '/api/driver/earnings/history',
      queryParameters: queryParams,
      options: Options(headers: headers),
    );

    print('📋 History Response: ${response.data}');

    if (response.data['success'] == true) {
      final data = response.data['data'];
      
      if (data is Map && data.containsKey('earnings')) {
        final earningsList = data['earnings'] as List? ?? [];
        return earningsList.map((e) => EarningModel.fromJson(e)).toList();
      } else if (data is List) {
        return data.map((e) => EarningModel.fromJson(e)).toList();
      }
    }
    return [];
  } catch (e) {
    print('❌ Get earnings history error: $e');
    return [];
  }
}

Future<Map<String, dynamic>> getAIPrediction() async {
  try {
    final headers = await _getHeaders();
    final response = await _dio.get(
      '/api/driver/earnings/prediction',
      options: Options(headers: headers),
    );

    print('🤖 Prediction Response: ${response.data}');

    if (response.data['success'] == true) {
      final data = response.data['data'];
      
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data is int) {
        return {
          'predicted_earnings': data,
          'best_time': 'N/A',
          'trend': 0,
          'day_factor': 1,
          'total_samples': 0,
          'tips': ['Prediction based on limited data']
        };
      }
    }
    
    return {
      'predicted_earnings': 0,
      'best_time': '6-9 PM',
      'trend': 0,
      'day_factor': 1,
      'total_samples': 0,
      'tips': ['No prediction available']
    };
  } catch (e) {
    print('❌ Get AI prediction error: $e');
    return {
      'predicted_earnings': 0,
      'best_time': '6-9 PM',
      'trend': 0,
      'day_factor': 1,
      'total_samples': 0,
      'tips': ['Error generating prediction']
    };
  }
}

Future<String> exportReport({
  required String format,
  required String period,
}) async {
  try {
    final headers = await _getHeaders();
    
    if (format != 'pdf') {
      throw Exception('Only PDF format is supported currently');
    }
    
    final response = await _dio.post(
      '/api/driver/earnings/export',
      data: {
        'format': format,
        'period': period,
      },
      options: Options(
        headers: headers,
        responseType: ResponseType.bytes,
      ),
    );

    if (response.data is List<int>) {
      final bytes = response.data as List<int>;
      
      if (kIsWeb) {
        final base64 = base64Encode(bytes);
        final anchor = html.AnchorElement(
          href: 'data:application/pdf;base64,$base64'
        )
          ..target = '_blank'
          ..download = 'earnings_report_${DateTime.now().millisecondsSinceEpoch}.pdf'
          ..click();
        return 'Report downloaded successfully';
      }
      
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'earnings_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${directory.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      print('📄 Report saved to: $filePath');
      return filePath;
    }
    throw Exception('Failed to export report');
  } catch (e) {
    print('❌ Export report error: $e');
    rethrow;
  }
}

}