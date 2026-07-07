// lib/screens/user/driver/ratings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../providers/driver_provider.dart';

class RatingsScreen extends ConsumerStatefulWidget {
  const RatingsScreen({super.key});

  @override
  ConsumerState<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends ConsumerState<RatingsScreen> {
  String _selectedFilter = 'all';

  @override
  @override
Widget build(BuildContext context) {
  final tr = context.tr;
  final driverState = ref.watch(driverProvider);
  final stats = driverState.stats ?? {};
  
  final ratingValue = stats['rating'] ?? 0.0;
  final totalRatings = stats['totalRatings'] ?? 0;

  final ratingsData = _getDummyRatings();

  return Scaffold(
    backgroundColor: AppColors.canvas,
    appBar: AppBar(
      title: Text(
        '⭐ ${tr.t('ratings')}',
        style: AppTypography.display(18, weight: FontWeight.w700),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            ref.read(driverProvider.notifier).loadDriverData();
          },
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRatingSummaryCard(tr, ratingValue, totalRatings),
          const SizedBox(height: 20),

          _buildRatingDistribution(tr, ratingsData),
          const SizedBox(height: 20),

          _buildFilterButtons(tr),
          const SizedBox(height: 12),

          _buildRatingsList(tr, ratingsData, _selectedFilter),
        ],
      ),
    ),
  );
}

  Widget _buildRatingSummaryCard(AppLocalizations tr, dynamic ratingValue, int totalRatings) {
  double rating = 0.0;
  if (ratingValue is double) {
    rating = ratingValue;
  } else if (ratingValue is int) {
    rating = ratingValue.toDouble();
  } else if (ratingValue is String) {
    rating = double.tryParse(ratingValue) ?? 0.0;
  } else if (ratingValue is num) {
    rating = ratingValue.toDouble();
  }

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: AppColors.routeGradient,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.25),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    final filled = starValue <= rating.round();
                    return Icon(
                      filled ? Icons.star_rounded : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalRatings ${tr.t('reviews')}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildRatingDistribution(AppLocalizations tr, List<Map<String, dynamic>> ratings) {
    final distribution = {
      5: 0,
      4: 0,
      3: 0,
      2: 0,
      1: 0,
    };

    for (final rating in ratings) {
      final stars = rating['rating'] ?? 0;
      if (stars >= 1 && stars <= 5) {
        distribution[stars] = (distribution[stars] ?? 0) + 1;
      }
    }

    final total = ratings.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr.t('rating_distribution'),
            style: AppTypography.display(14, weight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...distribution.entries.map((entry) {
            final percentage = total > 0 ? (entry.value / total) * 100 : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${entry.key} ⭐',
                      style: AppTypography.body(12, color: AppColors.ink700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 8,
                        backgroundColor: AppColors.surfaceSunken,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getRatingColor(entry.key),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 35,
                    child: Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: AppTypography.body(12, color: AppColors.ink500),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterButtons(AppLocalizations tr) {
    final filters = [
      {'key': 'all', 'label': tr.t('all')},
      {'key': '5', 'label': '5 ⭐'},
      {'key': '4', 'label': '4 ⭐'},
      {'key': '3', 'label': '3 ⭐'},
      {'key': '2', 'label': '2 ⭐'},
      {'key': '1', 'label': '1 ⭐'},
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['key'];
          return ChoiceChip(
            label: Text(filter['label']!),
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                _selectedFilter = filter['key']!;
              });
            },
            selectedColor: AppColors.primary,
            backgroundColor: Colors.white,
            labelStyle: AppTypography.body(
              12,
              weight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.ink700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingsList(
    AppLocalizations tr,
    List<Map<String, dynamic>> ratings,
    String filter,
  ) {
    final filteredRatings = ratings.where((rating) {
      if (filter == 'all') return true;
      return rating['rating'].toString() == filter;
    }).toList();

    if (filteredRatings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 64,
                color: AppColors.ink300,
              ),
              const SizedBox(height: 16),
              Text(
                tr.t('no_ratings_found'),
                style: AppTypography.body(14, color: AppColors.ink500),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredRatings.length,
      itemBuilder: (context, index) {
        final rating = filteredRatings[index];
        return _RatingCard(rating: rating);
      },
    );
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 5:
        return AppColors.success;
      case 4:
        return Colors.lightGreen;
      case 3:
        return AppColors.gold;
      case 2:
        return Colors.orange;
      case 1:
        return AppColors.error;
      default:
        return AppColors.ink500;
    }
  }

  List<Map<String, dynamic>> _getDummyRatings() {
    return [
      {
        'customerName': 'Ahmed Mohamed',
        'rating': 5,
        'comment': 'Excellent service! Driver was very professional and on time.',
        'date': '2024-01-20 14:30',
        'orderId': 'ORD-2024-001',
      },
      {
        'customerName': 'Sara Ali',
        'rating': 4,
        'comment': 'Good delivery, but a little late.',
        'date': '2024-01-19 18:45',
        'orderId': 'ORD-2024-002',
      },
      {
        'customerName': 'Mohammed Hassan',
        'rating': 5,
        'comment': 'Perfect delivery! Fast and friendly driver.',
        'date': '2024-01-18 12:15',
        'orderId': 'ORD-2024-003',
      },
      {
        'customerName': 'Nora Khalid',
        'rating': 3,
        'comment': 'Average service. Could improve communication.',
        'date': '2024-01-17 20:00',
        'orderId': 'ORD-2024-004',
      },
      {
        'customerName': 'Omar Youssef',
        'rating': 5,
        'comment': 'Always great service! Highly recommended.',
        'date': '2024-01-16 09:30',
        'orderId': 'ORD-2024-005',
      },
    ];
  }
}

class _RatingCard extends StatelessWidget {
  final Map<String, dynamic> rating;

  const _RatingCard({required this.rating});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final stars = rating['rating'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink900.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.7),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      (rating['customerName'] ?? '?')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rating['customerName'] ?? 'Unknown',
                        style: AppTypography.body(13, weight: FontWeight.w600),
                      ),
                      Text(
                        rating['date'] ?? '',
                        style: AppTypography.body(11, color: AppColors.ink500),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRatingColor(stars).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    ...List.generate(stars, (index) => const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 14,
                    )),
                  ],
                ),
              ),
            ],
          ),
          if (rating['comment'] != null) ...[
            const SizedBox(height: 8),
            Text(
              rating['comment'] ?? '',
              style: AppTypography.body(13, color: AppColors.ink700),
            ),
          ],
          if (rating['orderId'] != null) ...[
            const SizedBox(height: 4),
            Text(
              '${tr.t('order')}: ${rating['orderId']}',
              style: AppTypography.body(11, color: AppColors.ink500),
            ),
          ],
        ],
      ),
    );
  }

  static Color _getRatingColor(int rating) {
    switch (rating) {
      case 5:
        return AppColors.success;
      case 4:
        return Colors.lightGreen;
      case 3:
        return AppColors.gold;
      case 2:
        return Colors.orange;
      case 1:
        return AppColors.error;
      default:
        return AppColors.ink500;
    }
  }
}