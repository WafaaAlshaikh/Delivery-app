// lib/data/models/sentiment_model.dart

import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' hide IconData;

class SentimentAnalysis {
  final String text;
  final SentimentResult result;
  final Map<String, double> scores; 
  final List<String> keywords;
  final DateTime analyzedAt;

  SentimentAnalysis({
    required this.text,
    required this.result,
    required this.scores,
    required this.keywords,
    required this.analyzedAt,
  });

  factory SentimentAnalysis.fromJson(Map<String, dynamic> json) {
    return SentimentAnalysis(
      text: json['text'] ?? '',
      result: SentimentResult.values.firstWhere(
        (e) => e.toString() == json['result'],
        orElse: () => SentimentResult.neutral,
      ),
      scores: Map<String, double>.from(json['scores'] ?? {}),
      keywords: List<String>.from(json['keywords'] ?? []),
      analyzedAt: DateTime.tryParse(json['analyzed_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'result': result.toString(),
    'scores': scores,
    'keywords': keywords,
    'analyzed_at': analyzedAt.toIso8601String(),
  };
}

enum SentimentResult {
  positive,
  negative,
  neutral,
}

extension SentimentResultExtension on SentimentResult {
  String get label {
    switch (this) {
      case SentimentResult.positive:
        return '😊 إيجابي';
      case SentimentResult.negative:
        return '😞 سلبي';
      case SentimentResult.neutral:
        return '😐 محايد';
    }
  }

  Color get color {
    switch (this) {
      case SentimentResult.positive:
        return Colors.green;
      case SentimentResult.negative:
        return Colors.red;
      case SentimentResult.neutral:
        return Colors.orange;
    }
  }

  IconData get icon {
    switch (this) {
      case SentimentResult.positive:
        return Icons.sentiment_very_satisfied;
      case SentimentResult.negative:
        return Icons.sentiment_very_dissatisfied;
      case SentimentResult.neutral:
        return Icons.sentiment_neutral;
    }
  }
}