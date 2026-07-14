// lib/screens/user/driver/dashboard/providers/dashboard_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});

class DashboardState {
  final bool isLoading;
  final bool isRefreshing;
  final Map<String, dynamic>? stats;
  final String? error;

  DashboardState({
    this.isLoading = true,
    this.isRefreshing = false,
    this.stats,
    this.error,
  });

  DashboardState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    Map<String, dynamic>? stats,
    String? error,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      stats: stats ?? this.stats,
      error: error ?? this.error,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(DashboardState());

  Future<void> loadDashboardData() async {
    if (state.stats != null && !state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 800));

      final mockStats = {
        'total_earnings': 1250.75,
        'weekly_earnings': 320.50,
        'total_deliveries': 42,
        'current_orders': 3,
        'rating': 4.8,
        'change_percentage': 5.2,
      };

      state = state.copyWith(
        isLoading: false,
        stats: mockStats,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshData() async {
    state = state.copyWith(isRefreshing: true);
    await loadDashboardData();
    state = state.copyWith(isRefreshing: false);
  }
}