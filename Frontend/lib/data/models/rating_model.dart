// lib/data/models/rating_model.dart

import 'package:flutter/material.dart';

class RatingModel {
  final String id;
  final String orderId;
  final String customerName;
  final String customerImage;
  final double rating;
  final String comment;
  final DateTime date;
  final String deliveryTime; 
  final bool isAnonymous;

  RatingModel({
    required this.id,
    required this.orderId,
    required this.customerName,
    this.customerImage = '',
    required this.rating,
    required this.comment,
    required this.date,
    required this.deliveryTime,
    this.isAnonymous = false,
  });

  SentimentType get sentiment {
    if (rating >= 4.5) return SentimentType.positive;
    if (rating >= 3.0) return SentimentType.neutral;
    return SentimentType.negative;
  }

  String get sentimentEmoji {
    switch (sentiment) {
      case SentimentType.positive:
        return '😊';
      case SentimentType.neutral:
        return '😐';
      case SentimentType.negative:
        return '😞';
    }
  }

  Color get sentimentColor {
    switch (sentiment) {
      case SentimentType.positive:
        return Colors.green;
      case SentimentType.neutral:
        return Colors.orange;
      case SentimentType.negative:
        return Colors.red;
    }
  }

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      customerName: json['customer_name'] ?? 'Unknown',
      customerImage: json['customer_image'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      deliveryTime: json['delivery_time'] ?? 'on_time',
      isAnonymous: json['is_anonymous'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_id': orderId,
    'customer_name': customerName,
    'customer_image': customerImage,
    'rating': rating,
    'comment': comment,
    'date': date.toIso8601String(),
    'delivery_time': deliveryTime,
    'is_anonymous': isAnonymous,
  };
}

enum SentimentType {
  positive,
  neutral,
  negative,
}

class RatingsSummary {
  final double averageRating;
  final int totalRatings;
  final int fiveStarCount;
  final int fourStarCount;
  final int threeStarCount;
  final int twoStarCount;
  final int oneStarCount;
  final double positivePercentage;
  final double neutralPercentage;
  final double negativePercentage;
  final double monthlyChange; 
  final List<String> topKeywords; 

  RatingsSummary({
    required this.averageRating,
    required this.totalRatings,
    required this.fiveStarCount,
    required this.fourStarCount,
    required this.threeStarCount,
    required this.twoStarCount,
    required this.oneStarCount,
    required this.positivePercentage,
    required this.neutralPercentage,
    required this.negativePercentage,
    required this.monthlyChange,
    required this.topKeywords,
  });

  factory RatingsSummary.fromJson(Map<String, dynamic> json) {
    return RatingsSummary(
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      totalRatings: json['total_ratings'] ?? 0,
      fiveStarCount: json['five_star_count'] ?? 0,
      fourStarCount: json['four_star_count'] ?? 0,
      threeStarCount: json['three_star_count'] ?? 0,
      twoStarCount: json['two_star_count'] ?? 0,
      oneStarCount: json['one_star_count'] ?? 0,
      positivePercentage: (json['positive_percentage'] ?? 0.0).toDouble(),
      neutralPercentage: (json['neutral_percentage'] ?? 0.0).toDouble(),
      negativePercentage: (json['negative_percentage'] ?? 0.0).toDouble(),
      monthlyChange: (json['monthly_change'] ?? 0.0).toDouble(),
      topKeywords: List<String>.from(json['top_keywords'] ?? []),
    );
  }
}

class AIInsights {
  final List<String> strengths; 
  final List<String> weaknesses; 
  final List<String> suggestions; 
  final List<String> recommendations; 
  final String overallAssessment; 
  final double improvementScore; 
  final Map<String, double> categoryScores;

  AIInsights({
    required this.strengths,
    required this.weaknesses,
    required this.suggestions,
    required this.recommendations,
    required this.overallAssessment,
    required this.improvementScore,
    required this.categoryScores,
  });

  factory AIInsights.fromJson(Map<String, dynamic> json) {
    return AIInsights(
      strengths: List<String>.from(json['strengths'] ?? []),
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
      suggestions: List<String>.from(json['suggestions'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      overallAssessment: json['overall_assessment'] ?? '',
      improvementScore: (json['improvement_score'] ?? 0.0).toDouble(),
      categoryScores: Map<String, double>.from(json['category_scores'] ?? {}),
    );
  }
}