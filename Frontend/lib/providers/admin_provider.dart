// lib/providers/admin_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_service.dart';

final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService();
});

// ============================================
// 📊 DASHBOARD PROVIDER
// ============================================

final adminDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(adminServiceProvider);
  final response = await service.getDashboardStats();
  return response['data'];
});

final adminChartDataProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, period) async {
  final service = ref.read(adminServiceProvider);
  final response = await service.getChartData(period: period);
  return response['data'];
});

// ============================================
// 👥 USERS PROVIDER
// ============================================

final adminUsersProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final service = ref.read(adminServiceProvider);
  final response = await service.getUsers(
    role: params['role'],
    search: params['search'],
    page: params['page'] ?? 1,
    limit: params['limit'] ?? 20,
  );
  return response['data'];
});

final adminUserDetailsProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, userId) async {
  final service = ref.read(adminServiceProvider);
  final response = await service.getUserDetails(userId);
  return response['data'];
});

// ============================================
// 🏪 MERCHANTS PROVIDER
// ============================================

final adminMerchantsProvider = FutureProvider<List<dynamic>>((ref) async {
  final service = ref.read(adminServiceProvider);
  final response = await service.getMerchants();
  return response['data'];
});

// ============================================
// 🚗 DRIVERS PROVIDER
// ============================================

final adminDriversProvider = FutureProvider<List<dynamic>>((ref) async {
  final service = ref.read(adminServiceProvider);
  final response = await service.getDrivers();
  return response['data'];
});

// ============================================
// 📦 ORDERS PROVIDER
// ============================================

final adminOrdersProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final service = ref.read(adminServiceProvider);
  final response = await service.getOrders(
    status: params['status'],
    page: params['page'] ?? 1,
    limit: params['limit'] ?? 20,
  );
  return response['data'];
});

final adminOrderDetailsProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, orderId) async {
  final service = ref.read(adminServiceProvider);
  final response = await service.getOrderDetails(orderId);
  return response['data'];
});

// ============================================
// 📊 ADMIN STATE (للتحميل والأخطاء)
// ============================================

class AdminState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? dashboardData;
  final List<dynamic>? users;
  final List<dynamic>? merchants;
  final List<dynamic>? drivers;
  final List<dynamic>? orders;

  AdminState({
    this.isLoading = false,
    this.error,
    this.dashboardData,
    this.users,
    this.merchants,
    this.drivers,
    this.orders,
  });

  AdminState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? dashboardData,
    List<dynamic>? users,
    List<dynamic>? merchants,
    List<dynamic>? drivers,
    List<dynamic>? orders,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      dashboardData: dashboardData ?? this.dashboardData,
      users: users ?? this.users,
      merchants: merchants ?? this.merchants,
      drivers: drivers ?? this.drivers,
      orders: orders ?? this.orders,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  AdminNotifier() : super(AdminState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: جلب البيانات من الـ API
      // final data = await _adminService.getDashboardStats();
      // state = state.copyWith(isLoading: false, dashboardData: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier();
});