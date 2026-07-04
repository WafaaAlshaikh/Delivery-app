// frontend/lib/providers/order_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/order_model.dart';
import '../services/order_service.dart';
import '../services/location_service.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// ============================================
// 📌 AVAILABLE ORDERS PROVIDER (مع بارامترات)
// ============================================

final availableOrdersProvider = FutureProvider.family<List<OrderModel>, Map<String, dynamic>>((ref, params) async {
  final orderService = ref.read(orderServiceProvider);
  final locationService = ref.read(locationServiceProvider);
  
  // ✅ جلب الموقع الحالي
  final position = await locationService.getCurrentLocation();
  
  // ✅ قراءة البارامترات
  final sortBy = params['sortBy'] ?? 'distance';
  final filterBy = params['filterBy'] ?? 'all';
  final radius = params['radius'] ?? 10;
  
  return orderService.getAvailableOrders(
    latitude: position?.latitude,
    longitude: position?.longitude,
    radius: radius,
    sortBy: sortBy,
    filterBy: filterBy,
  );
});

// ============================================
// 📌 ORDER DETAILS PROVIDER
// ============================================

final orderDetailsProvider = FutureProvider.family<OrderModel, int>((ref, orderId) async {
  final orderService = ref.read(orderServiceProvider);
  return orderService.getOrderDetails(orderId);
});

// ============================================
// 📌 ORDER STATE (مع الفلاتر)
// ============================================

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

  // ✅ Load available orders with filters
  Future<void> loadAvailableOrders({
    String sortBy = 'distance',
    String filterBy = 'all',
    double radius = 10,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final position = await _locationService.getCurrentLocation();
      
      final orders = await _orderService.getAvailableOrders(
        latitude: position?.latitude,
        longitude: position?.longitude,
        radius: radius,
        sortBy: sortBy,
        filterBy: filterBy,
      );
      
      state = state.copyWith(
        isLoading: false,
        orders: orders,
        error: null,
        currentSort: sortBy,
        currentFilter: filterBy,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // ✅ Refresh orders
  Future<void> refreshOrders() async {
    state = state.copyWith(isRefreshing: true);
    
    try {
      final position = await _locationService.getCurrentLocation();
      
      final orders = await _orderService.getAvailableOrders(
        latitude: position?.latitude,
        longitude: position?.longitude,
        radius: 10,
        sortBy: state.currentSort,
        filterBy: state.currentFilter,
      );
      
      state = state.copyWith(
        isRefreshing: false,
        orders: orders,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: e.toString(),
      );
    }
  }

  // ✅ Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final orderService = ref.read(orderServiceProvider);
  final locationService = ref.read(locationServiceProvider);
  return OrderNotifier(orderService, locationService);
});