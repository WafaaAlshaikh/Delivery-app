// lib/providers/order_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/models/order_model.dart';
import '../services/order_service.dart';
import '../services/location_service.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final availableOrdersProvider = FutureProvider.family<List<OrderModel>, Map<String, dynamic>>((ref, params) async {
  final orderService = ref.read(orderServiceProvider);
  final locationService = ref.read(locationServiceProvider);
  
  final position = await locationService.getCurrentLocation();
  
  final sortBy = params['sortBy'] ?? 'distance';
  final filterBy = params['filterBy'] ?? 'all';
  final radius = params['radius'] ?? 10;
  
  final result = await orderService.getAvailableOrders(
    latitude: position?.latitude,
    longitude: position?.longitude,
    radius: radius,
    sortBy: sortBy,
    filterBy: filterBy,
  );
  
  return result.orders;
});

final orderDetailsProvider = FutureProvider.family<OrderModel, int>((ref, orderId) async {
  final orderService = ref.read(orderServiceProvider);
  return orderService.getOrderDetails(orderId as String);
});

class OrderState {
  final bool isLoading;
  final List<OrderModel> orders;
  final String? error;
  final bool isRefreshing;
  final String currentSort;
  final String currentFilter;

  OrderState({
    this.isLoading = false,
    this.orders = const [],
    this.error,
    this.isRefreshing = false,
    this.currentSort = 'distance',
    this.currentFilter = 'all',
  });

  OrderState copyWith({
    bool? isLoading,
    List<OrderModel>? orders,
    String? error,
    bool? isRefreshing,
    String? currentSort,
    String? currentFilter,
  }) {
    return OrderState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      error: error ?? this.error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      currentSort: currentSort ?? this.currentSort,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderService _orderService;
  final LocationService _locationService;

  OrderNotifier(this._orderService, this._locationService) : super(OrderState());

  Future<void> loadAvailableOrders({
    String sortBy = 'distance',
    String filterBy = 'all',
    double radius = 10,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final position = await _locationService.getCurrentLocation();
      
      final result = await _orderService.getAvailableOrders(
        latitude: position?.latitude,
        longitude: position?.longitude,
        radius: radius,
        sortBy: sortBy,
        filterBy: filterBy,
      );
      
      if (result.success) {
        state = state.copyWith(
          isLoading: false,
          orders: result.orders,
          error: null,
          currentSort: sortBy,
          currentFilter: filterBy,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshOrders() async {
    state = state.copyWith(isRefreshing: true);
    
    try {
      final position = await _locationService.getCurrentLocation();
      
      final result = await _orderService.getAvailableOrders(
        latitude: position?.latitude,
        longitude: position?.longitude,
        radius: 10,
        sortBy: state.currentSort,
        filterBy: state.currentFilter,
      );
      
      if (result.success) {
        state = state.copyWith(
          isRefreshing: false,
          orders: result.orders,
          error: null,
        );
      } else {
        state = state.copyWith(
          isRefreshing: false,
          error: result.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final orderService = ref.read(orderServiceProvider);
  final locationService = ref.read(locationServiceProvider);
  return OrderNotifier(orderService, locationService);
});