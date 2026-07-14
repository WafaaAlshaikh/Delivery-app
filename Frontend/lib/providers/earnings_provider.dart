// lib/providers/earnings_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/models/earning_model.dart';
import '../services/earnings_service.dart';

final earningsServiceProvider = Provider<EarningsService>((ref) {
  return EarningsService();
});

class EarningsState {
  final bool isLoading;
  final String? error;
  final EarningsSummary? summary;
  final EarningsChartData? chartData;
  final List<EarningModel> history;
  final Map<String, dynamic>? aiPrediction;
  final String selectedPeriod;
  final bool isExporting;
  final int currentPage;
  final bool hasMoreData;

  EarningsState({
    this.isLoading = false,
    this.error,
    this.summary,
    this.chartData,
    this.history = const [],
    this.aiPrediction,
    this.selectedPeriod = 'daily',
    this.isExporting = false,
    this.currentPage = 1,
    this.hasMoreData = true,
  });

  EarningsState copyWith({
    bool? isLoading,
    String? error,
    EarningsSummary? summary,
    EarningsChartData? chartData,
    List<EarningModel>? history,
    Map<String, dynamic>? aiPrediction,
    String? selectedPeriod,
    bool? isExporting,
    int? currentPage,
    bool? hasMoreData,
  }) {
    return EarningsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      summary: summary ?? this.summary,
      chartData: chartData ?? this.chartData,
      history: history ?? this.history,
      aiPrediction: aiPrediction ?? this.aiPrediction,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      isExporting: isExporting ?? this.isExporting,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}

class EarningsNotifier extends StateNotifier<EarningsState> {
  final EarningsService _service;

  EarningsNotifier(this._service) : super(EarningsState());

  Future<void> loadAllData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.wait([
        loadSummary(),
        loadChartData(state.selectedPeriod),
        loadHistory(reset: true),
        loadAIPrediction(),
      ]);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load earnings data: ${e.toString()}',
      );
    }
  }

  Future<void> loadSummary() async {
    try {
      final summary = await _service.getEarningsSummary();
      state = state.copyWith(summary: summary);
    } catch (e) {
      print('❌ Load summary error: $e');
      rethrow;
    }
  }

  Future<void> loadChartData(String period) async {
    try {
      final chartData = await _service.getEarningsChart(period: period);
      state = state.copyWith(
        chartData: chartData,
        selectedPeriod: period,
      );
    } catch (e) {
      print('❌ Load chart error: $e');
      rethrow;
    }
  }

  Future<void> loadHistory({bool reset = false}) async {
    try {
      final page = reset ? 1 : state.currentPage;
      final history = await _service.getEarningsHistory(
        page: page,
        limit: 20,
      );

      if (reset) {
        state = state.copyWith(
          history: history,
          currentPage: page,
          hasMoreData: history.length >= 20,
        );
      } else {
        state = state.copyWith(
          history: [...state.history, ...history],
          currentPage: page,
          hasMoreData: history.length >= 20,
        );
      }
    } catch (e) {
      print('❌ Load history error: $e');
      rethrow;
    }
  }

  Future<void> loadAIPrediction() async {
    try {
      final prediction = await _service.getAIPrediction();
      state = state.copyWith(aiPrediction: prediction);
    } catch (e) {
      print('❌ Load AI prediction error: $e');
      state = state.copyWith(aiPrediction: {
        'predicted_earnings': 0,
        'best_time': '6-9 PM',
        'tips': ['📊 Not enough data for accurate predictions yet.']
      });
    }
  }

  Future<void> changePeriod(String period) async {
    if (state.selectedPeriod == period) return;
    state = state.copyWith(isLoading: true);
    try {
      await loadChartData(period);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load chart data: ${e.toString()}',
      );
    }
  }

  Future<void> loadMoreHistory() async {
    if (!state.hasMoreData || state.isLoading) return;
    await loadHistory(reset: false);
  }

  Future<void> exportReport(String format) async {
    state = state.copyWith(isExporting: true, error: null);
    try {
      final filePath = await _service.exportReport(
        format: format,
        period: state.selectedPeriod,
      );
      
      await _service.shareReport(filePath);
      
      state = state.copyWith(isExporting: false);
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        error: 'Failed to export report: ${e.toString()}',
      );
    }
  }

  Future<void> refreshData() async {
    await loadAllData();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final earningsProvider = StateNotifierProvider<EarningsNotifier, EarningsState>(
  (ref) {
    final service = ref.read(earningsServiceProvider);
    return EarningsNotifier(service);
  },
);