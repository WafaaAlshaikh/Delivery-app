// lib/providers/scheduling_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/models/scheduled_order_model.dart';
import '../services/scheduling_service.dart';

final schedulingServiceProvider = Provider<SchedulingService>((ref) {
  return SchedulingService();
});

class SchedulingState {
  final bool isLoading;
  final String? error;
  final List<ScheduledOrder> scheduledOrders;
  final RouteOptimization? routeOptimization;
  final AISuggestion? aiSuggestion;
  final DateTime selectedDate;
  final bool isRefreshing;

  SchedulingState({
    this.isLoading = false,
    this.error,
    this.scheduledOrders = const [],
    this.routeOptimization,
    this.aiSuggestion,
    required this.selectedDate,
    this.isRefreshing = false,
  });

  SchedulingState copyWith({
    bool? isLoading,
    String? error,
    List<ScheduledOrder>? scheduledOrders,
    RouteOptimization? routeOptimization,
    AISuggestion? aiSuggestion,
    DateTime? selectedDate,
    bool? isRefreshing,
  }) {
    return SchedulingState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      scheduledOrders: scheduledOrders ?? this.scheduledOrders,
      routeOptimization: routeOptimization ?? this.routeOptimization,
      aiSuggestion: aiSuggestion ?? this.aiSuggestion,
      selectedDate: selectedDate ?? this.selectedDate,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class SchedulingNotifier extends StateNotifier<SchedulingState> {
  final SchedulingService _service;

  SchedulingNotifier(this._service)
      : super(SchedulingState(selectedDate: DateTime.now()));

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.wait([
        loadScheduledOrders(),
        loadRouteOptimization(),
      ]);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load data: ${e.toString()}',
      );
    }
  }

  Future<void> loadScheduledOrders() async {
    try {
      final orders = await _service.getScheduledOrders(date: state.selectedDate);
      state = state.copyWith(scheduledOrders: orders);
    } catch (e) {
      print('❌ Load scheduled orders error: $e');
      rethrow;
    }
  }

  Future<void> loadRouteOptimization() async {
    try {
      final optimization = await _service.optimizeRoute(date: state.selectedDate);
      state = state.copyWith(routeOptimization: optimization);
    } catch (e) {
      print('❌ Load route optimization error: $e');
      rethrow;
    }
  }

  Future<void> changeDate(DateTime date) async {
    state = state.copyWith(selectedDate: date, isLoading: true);
    try {
      await loadScheduledOrders();
      await loadRouteOptimization();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load data for selected date',
      );
    }
  }

  Future<void> suggestOptimalTime(String orderId) async {
    try {
      final suggestion = await _service.suggestOptimalTime(orderId: orderId);
      state = state.copyWith(aiSuggestion: suggestion);
    } catch (e) {
      print('❌ Suggest optimal time error: $e');
    }
  }

  Future<bool> confirmSchedule(String scheduledId) async {
    try {
      final result = await _service.confirmSchedule(scheduledId: scheduledId);
      if (result != null) {
        await loadData();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Confirm schedule error: $e');
      return false;
    }
  }

  Future<bool> cancelSchedule(String scheduledId, {String? reason}) async {
    try {
      final result = await _service.cancelSchedule(
        scheduledId: scheduledId,
        reason: reason,
      );
      if (result != null) {
        await loadData();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Cancel schedule error: $e');
      return false;
    }
  }

  Future<bool> createSchedule({
    required String orderId,
    required DateTime scheduledTime,
  }) async {
    try {
      final result = await _service.createSchedule(
        orderId: orderId,
        scheduledTime: scheduledTime,
      );
      if (result != null) {
        await loadData();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Create schedule error: $e');
      return false;
    }
  }

  Future<void> refreshData() async {
    state = state.copyWith(isRefreshing: true);
    await loadData();
    state = state.copyWith(isRefreshing: false);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final schedulingProvider = StateNotifierProvider<SchedulingNotifier, SchedulingState>(
  (ref) {
    final service = ref.read(schedulingServiceProvider);
    return SchedulingNotifier(service);
  },
);