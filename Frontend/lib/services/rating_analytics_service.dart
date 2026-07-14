// lib/services/rating_analytics_service.dart

import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../services/storage_service.dart';

class RatingAnalyticsService {
  final Dio _dio = Dio();
  final StorageService _storageService = StorageService();

  RatingAnalyticsService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, CityRatingStats>> getAverageRatingByCity() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/ratings/driver/analytics/cities',
        options: Options(headers: headers),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final result = <String, CityRatingStats>{};
        
        for (final entry in data.entries) {
          result[entry.key] = CityRatingStats.fromJson(entry.value);
        }
        return result;
      }
      return {};
    } catch (e) {
      print('❌ Get city ratings error: $e');
      return {};
    }
  }

  Future<DriverRanking> getDriverRanking() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/ratings/driver/analytics/ranking',
        options: Options(headers: headers),
      );

      if (response.data['success'] == true) {
        return DriverRanking.fromJson(response.data['data']);
      }
      return DriverRanking(
        currentRank: 0,
        totalDrivers: 0,
        averageRating: 0,
        topDrivers: [],
      );
    } catch (e) {
      print('❌ Get driver ranking error: $e');
      return DriverRanking(
        currentRank: 0,
        totalDrivers: 0,
        averageRating: 0,
        topDrivers: [],
      );
    }
  }
}

class CityRatingStats {
  final String city;
  final double averageRating;
  final int totalRatings;
  final int positiveCount;
  final int negativeCount;
  final int neutralCount;
  final List<String> topKeywords;
  final Map<String, double> sentimentBreakdown;

  CityRatingStats({
    required this.city,
    required this.averageRating,
    required this.totalRatings,
    required this.positiveCount,
    required this.negativeCount,
    required this.neutralCount,
    required this.topKeywords,
    required this.sentimentBreakdown,
  });

  factory CityRatingStats.fromJson(Map<String, dynamic> json) {
    return CityRatingStats(
      city: json['city'] ?? '',
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      totalRatings: json['total_ratings'] ?? 0,
      positiveCount: json['positive_count'] ?? 0,
      negativeCount: json['negative_count'] ?? 0,
      neutralCount: json['neutral_count'] ?? 0,
      topKeywords: List<String>.from(json['top_keywords'] ?? []),
      sentimentBreakdown: Map<String, double>.from(json['sentiment_breakdown'] ?? {}),
    );
  }

  double get positivePercentage => totalRatings > 0 ? (positiveCount / totalRatings) * 100 : 0;
  double get negativePercentage => totalRatings > 0 ? (negativeCount / totalRatings) * 100 : 0;
  double get neutralPercentage => totalRatings > 0 ? (neutralCount / totalRatings) * 100 : 0;
}

class DriverRanking {
  final int currentRank;
  final int totalDrivers;
  final double averageRating;
  final List<TopDriver> topDrivers;

  DriverRanking({
    required this.currentRank,
    required this.totalDrivers,
    required this.averageRating,
    required this.topDrivers,
  });

  factory DriverRanking.fromJson(Map<String, dynamic> json) {
    return DriverRanking(
      currentRank: json['current_rank'] ?? 0,
      totalDrivers: json['total_drivers'] ?? 0,
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      topDrivers: (json['top_drivers'] as List?)
          ?.map((e) => TopDriver.fromJson(e))
          .toList() ?? [],
    );
  }

  String get rankLabel {
    if (currentRank == 1) return '🥇 #1';
    if (currentRank == 2) return '🥈 #2';
    if (currentRank == 3) return '🥉 #3';
    return '#$currentRank';
  }

  Color get rankColor {
    if (currentRank == 1) return Colors.amber;
    if (currentRank == 2) return Colors.grey;
    if (currentRank == 3) return Colors.brown;
    return Colors.blue;
  }
}

class TopDriver {
  final int driverId;
  final String name;
  final double rating;
  final int totalDeliveries;
  final String? image;

  TopDriver({
    required this.driverId,
    required this.name,
    required this.rating,
    required this.totalDeliveries,
    this.image,
  });

  factory TopDriver.fromJson(Map<String, dynamic> json) {
    return TopDriver(
      driverId: json['driver_id'] ?? 0,
      name: json['name'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalDeliveries: json['total_deliveries'] ?? 0,
      image: json['image'],
    );
  }
}