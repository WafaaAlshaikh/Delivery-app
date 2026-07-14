// lib/providers/ratings_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/services/rating_socket_service.dart';
import '../data/models/rating_model.dart';
import '../services/ratings_service.dart';
import '../services/sentiment_analyzer.dart';

final ratingsServiceProvider = Provider<RatingsService>((ref) {
  return RatingsService();
});

class RatingsState {
  final bool isLoading;
  final String? error;
  final List<RatingModel> ratings;
  final RatingsSummary? summary;
  final AIInsights? aiInsights;
  final String selectedFilter; 
  final int currentPage;
  final bool hasMoreData;

  RatingsState({
    this.isLoading = false,
    this.error,
    this.ratings = const [],
    this.summary,
    this.aiInsights,
    this.selectedFilter = 'all',
    this.currentPage = 1,
    this.hasMoreData = true,
  });

  RatingsState copyWith({
    bool? isLoading,
    String? error,
    List<RatingModel>? ratings,
    RatingsSummary? summary,
    AIInsights? aiInsights,
    String? selectedFilter,
    int? currentPage,
    bool? hasMoreData,
  }) {
    return RatingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      ratings: ratings ?? this.ratings,
      summary: summary ?? this.summary,
      aiInsights: aiInsights ?? this.aiInsights,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}

class RatingsNotifier extends StateNotifier<RatingsState> {
  final RatingsService _service;
  bool _isListening = false;

   RatingsNotifier(this._service) : super(RatingsState()) {
    _initSocketListeners();
  }

  void _initSocketListeners() {
    if (_isListening) return;
    _isListening = true;

    RatingSocketService.onNewRating((data) {
      final newRating = RatingModel.fromJson(data);
      state = state.copyWith(
        ratings: [newRating, ...state.ratings],
      );
      
      loadSummary();
      loadAIInsights();
    });

    RatingSocketService.onRatingUpdated((data) {
      final updatedRating = RatingModel.fromJson(data);
      final updatedList = state.ratings.map((r) {
        return r.id == updatedRating.id ? updatedRating : r;
      }).toList();
      state = state.copyWith(ratings: updatedList);
    });

    RatingSocketService.onRatingDeleted((data) {
      final deletedId = data['rating_id']?.toString() ?? '';
      state = state.copyWith(
        ratings: state.ratings.where((r) => r.id != deletedId).toList(),
      );
      
      loadSummary();
      loadAIInsights();
    });
  }
@override
  void dispose() {
    RatingSocketService.dispose();
    super.dispose();
  }


  Future<void> loadAllData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.wait([
        loadSummary(),
        loadAIInsights(),
        loadRatings(reset: true),
      ]);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load ratings: ${e.toString()}',
      );
    }
  }

  Future<void> loadRatings({bool reset = false}) async {
    try {
      final page = reset ? 1 : state.currentPage;
      final ratings = await _service.getRatings(
        page: page,
        limit: 20,
        sentiment: state.selectedFilter == 'all' ? null : state.selectedFilter,
      );

      if (reset) {
        state = state.copyWith(
          ratings: ratings,
          currentPage: page,
          hasMoreData: ratings.length >= 20,
        );
      } else {
        state = state.copyWith(
          ratings: [...state.ratings, ...ratings],
          currentPage: page,
          hasMoreData: ratings.length >= 20,
        );
      }
    } catch (e) {
      print('❌ Load ratings error: $e');
      rethrow;
    }
  }

  Future<void> loadSummary() async {
    try {
      final summary = await _service.getRatingsSummary();
      state = state.copyWith(summary: summary);
    } catch (e) {
      print('❌ Load summary error: $e');
      rethrow;
    }
  }

  Future<void> loadAIInsights() async {
    try {
      final insights = await _service.getAIInsights();
      state = state.copyWith(aiInsights: insights);
    } catch (e) {
      print('❌ Load AI insights error: $e');
      rethrow;
    }
  }

  Future<void> changeFilter(String filter) async {
    if (state.selectedFilter == filter) return;
    state = state.copyWith(
      selectedFilter: filter,
      isLoading: true,
    );
    try {
      await loadRatings(reset: true);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to change filter: ${e.toString()}',
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMoreData || state.isLoading) return;
    await loadRatings(reset: false);
  }

  Future<void> refreshData() async {
    await loadAllData();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final ratingsProvider = StateNotifierProvider<RatingsNotifier, RatingsState>(
  (ref) {
    final service = ref.read(ratingsServiceProvider);
    return RatingsNotifier(service);
  },
);