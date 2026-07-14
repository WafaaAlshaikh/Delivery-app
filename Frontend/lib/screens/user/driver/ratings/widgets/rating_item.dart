// lib/screens/user/driver/ratings/widgets/rating_item.dart

import 'package:flutter/material.dart';
import 'package:frontend/data/models/sentiment_model.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/typography.dart';
import '../../../../../data/models/rating_model.dart';
import '../../../../../services/sentiment_analyzer.dart';

class RatingItem extends StatelessWidget {
  final RatingModel rating;

  const RatingItem({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SentimentAnalysis>(
      future: SentimentAnalyzer.analyzeText(rating.comment),
      builder: (context, snapshot) {
        final sentiment = snapshot.data ?? SentimentAnalysis(
          text: rating.comment,
          result: SentimentResult.neutral,
          scores: {},
          keywords: [],
          analyzedAt: DateTime.now(),
        );

        if (snapshot.connectionState == ConnectionState.done) {
          print('🔍 Analysis type: ${SentimentAnalyzer.useAdvancedNLP ? "🧠 NLP" : "📝 Fallback"}');
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: rating.customerImage.isNotEmpty
                        ? NetworkImage(rating.customerImage)
                        : null,
                    child: rating.customerImage.isEmpty
                        ? Text(
                            rating.customerName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                    backgroundColor: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rating.customerName,
                          style: AppTypography.body(14, weight: FontWeight.w600),
                        ),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              final filled = index < rating.rating.round();
                              return Icon(
                                filled ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 14,
                              );
                            }),
                            const SizedBox(width: 6),
                            Text(
                              rating.rating.toStringAsFixed(1),
                              style: AppTypography.body(12, weight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: sentiment.result.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          sentiment.result.icon,
                          color: sentiment.result.color,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          sentiment.result.label.split(' ')[0],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: sentiment.result.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (rating.comment.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rating.comment,
                        style: AppTypography.body(13, color: AppColors.ink700),
                      ),
                      if (sentiment.keywords.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 2,
                          children: sentiment.keywords.map((keyword) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '#$keyword',
                                style: AppTypography.body(9, color: AppColors.ink500),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        rating.deliveryTime == 'on_time' ? Icons.check_circle :
                        rating.deliveryTime == 'early' ? Icons.access_time : Icons.warning,
                        size: 14,
                        color: rating.deliveryTime == 'on_time' ? Colors.green :
                               rating.deliveryTime == 'early' ? Colors.blue : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.deliveryTime == 'on_time' ? 'في الوقت' :
                        rating.deliveryTime == 'early' ? 'مبكراً' : 'متأخراً',
                        style: AppTypography.body(11, color: AppColors.ink500),
                      ),
                    ],
                  ),
                  Text(
                    _formatDate(rating.date),
                    style: AppTypography.body(11, color: AppColors.ink300),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return 'منذ ${difference.inMinutes} دقيقة';
      }
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}