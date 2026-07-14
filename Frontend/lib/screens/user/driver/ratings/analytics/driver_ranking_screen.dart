// lib/screens/user/driver/ratings/analytics/driver_ranking_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/typography.dart';
import '../../../../../services/rating_analytics_service.dart';

class DriverRankingScreen extends ConsumerStatefulWidget {
  const DriverRankingScreen({super.key});

  @override
  ConsumerState<DriverRankingScreen> createState() => _DriverRankingScreenState();
}

class _DriverRankingScreenState extends ConsumerState<DriverRankingScreen> {
  DriverRanking? _ranking;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = RatingAnalyticsService();
      final ranking = await service.getDriverRanking();
      setState(() {
        _ranking = ranking;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_ranking == null || _ranking!.totalDrivers == 0) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.leaderboard, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text('No ranking data available'),
              Text(
                'Complete more deliveries to appear in rankings',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🏆 Driver Ranking',
          style: AppTypography.display(18, weight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildYourRankCard(),
              const SizedBox(height: 16),

              Text(
                '🏅 Top Drivers',
                style: AppTypography.display(16, weight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ..._ranking!.topDrivers.asMap().entries.map((entry) {
                final index = entry.key;
                final driver = entry.value;
                return _TopDriverCard(
                  rank: index + 1,
                  driver: driver,
                  isYou: driver.driverId == _ranking!.currentRank, 
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYourRankCard() {
    final rank = _ranking!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '🎯 Your Ranking',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rank.rankLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'of ${rank.totalDrivers} drivers',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _statItem('⭐ Rating', rank.averageRating.toStringAsFixed(1)),
              const SizedBox(width: 32),
              _statItem('📦 Deliveries', '${rank.topDrivers.fold(0, (sum, d) => sum + d.totalDeliveries)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _TopDriverCard extends StatelessWidget {
  final int rank;
  final TopDriver driver;
  final bool isYou;

  const _TopDriverCard({
    required this.rank,
    required this.driver,
    required this.isYou,
  });

  @override
  Widget build(BuildContext context) {
    final color = rank == 1
        ? Colors.amber
        : rank == 2
            ? Colors.grey
            : rank == 3
                ? Colors.brown
                : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isYou ? AppColors.primarySoft : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isYou ? AppColors.primary : Colors.grey.shade200,
          width: isYou ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundImage: driver.image != null
                ? NetworkImage(driver.image!)
                : null,
            child: driver.image == null
                ? Text(
                    driver.name[0].toUpperCase(),
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
                Row(
                  children: [
                    Text(
                      driver.name,
                      style: AppTypography.body(14, weight: FontWeight.w600),
                    ),
                    if (isYou) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'You',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '⭐ ${driver.rating.toStringAsFixed(1)} • 📦 ${driver.totalDeliveries} deliveries',
                  style: AppTypography.body(12, color: AppColors.ink500),
                ),
              ],
            ),
          ),
          Icon(
            rank == 1 ? Icons.emoji_events : Icons.chevron_right,
            color: rank == 1 ? Colors.amber : Colors.grey,
          ),
        ],
      ),
    );
  }
}