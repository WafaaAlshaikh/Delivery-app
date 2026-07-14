// lib/services/ratings_service.dart

import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../data/models/rating_model.dart';
import '../services/storage_service.dart';

class RatingsService {
  final Dio _dio = Dio();
  final StorageService _storageService = StorageService();

  RatingsService() {
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

  Future<List<RatingModel>> getRatings({
    int page = 1,
    int limit = 20,
    String? sentiment,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/ratings/driver', 
        queryParameters: {
          'page': page,
          'limit': limit,
          if (sentiment != null) 'sentiment': sentiment,
        },
        options: Options(headers: headers),
      );

      print('✅ Ratings Response: ${response.data}');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final ratings = data['ratings'] as List? ?? [];
        return ratings.map((e) => RatingModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Get ratings error: $e');
      return [];
    }
  }

  Future<RatingsSummary> getRatingsSummary() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/ratings/driver/summary', 
        options: Options(headers: headers),
      );

      print('✅ Ratings Summary Response: ${response.data}');

      if (response.data['success'] == true) {
        return RatingsSummary.fromJson(response.data['data']);
      }
      return RatingsSummary(
        averageRating: 0,
        totalRatings: 0,
        fiveStarCount: 0,
        fourStarCount: 0,
        threeStarCount: 0,
        twoStarCount: 0,
        oneStarCount: 0,
        positivePercentage: 0,
        neutralPercentage: 0,
        negativePercentage: 0,
        monthlyChange: 0,
        topKeywords: [],
      );
    } catch (e) {
      print('❌ Get ratings summary error: $e');
      rethrow;
    }
  }

  Future<AIInsights> getAIInsights() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/ratings/driver/insights', 
        options: Options(headers: headers),
      );

      print('✅ AI Insights Response: ${response.data}');

      if (response.data['success'] == true) {
        return AIInsights.fromJson(response.data['data']);
      }
      return AIInsights(
        strengths: [],
        weaknesses: [],
        suggestions: [],
        recommendations: [],
        overallAssessment: 'Not enough data for analysis',
        improvementScore: 0,
        categoryScores: {},
      );
    } catch (e) {
      print('❌ Get AI insights error: $e');
      rethrow;
    }
  }
}