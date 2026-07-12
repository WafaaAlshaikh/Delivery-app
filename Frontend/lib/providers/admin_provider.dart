// lib/providers/admin_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/admin_service.dart';
import '../data/models/admin_models.dart';

final adminServiceProvider = Provider<AdminService>((ref) {
  print('🔍 [DEBUG] adminServiceProvider created');
  return AdminService();
});


final adminDashboardProvider = FutureProvider<AdminDashboardStats>((ref) async {
  final service = ref.read(adminServiceProvider);
  final stats = await service.getDashboardStats();
  return stats;
});

final adminChartDataProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, period) async {
  final service = ref.read(adminServiceProvider);
  final response = await service.getChartData(period: period);
  return response['data'];
});


final adminUsersProvider = FutureProvider.family<Map<String, dynamic>, ({String? role, String? search, int page, int limit})>((ref, params) async {
  final service = ref.read(adminServiceProvider);
  final response = await service.getUsers(
    role: params.role,
    search: params.search,
    page: params.page,
    limit: params.limit,
  );
  return response['data'];
});

final adminUserDetailsProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, userId) async {
  final service = ref.read(adminServiceProvider);
  final response = await service.getUserDetails(userId);
  return response['data'];
});


final adminMerchantsProvider = FutureProvider<List<dynamic>>((ref) async {
  final service = ref.read(adminServiceProvider);
  final response = await service.getMerchants();
  return response['data'];
});


final adminDriversProvider = FutureProvider<List<dynamic>>((ref) async {
  final service = ref.read(adminServiceProvider);
  final response = await service.getDrivers();
  return response['data'];
});

final adminAllDriversProvider = FutureProvider.family<Map<String, dynamic>, String?>((ref, status) async {
  final service = ref.read(adminServiceProvider);
  final response = await service.getAllDrivers(status: status);
  return response;
});

final adminDriverApplicationsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(adminServiceProvider);
  final response = await service.getDriverApplications();
  return response;
});


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


final adminStoresProvider = FutureProvider<List<AdminStoreModel>>((ref) async {
  final service = ref.read(adminServiceProvider);
  final stores = await service.getStores();
  return stores;
});

final adminCategoriesProvider = FutureProvider<List<AdminCategoryModel>>((ref) async {
  final service = ref.read(adminServiceProvider);
  final categories = await service.getCategories();
  return categories;
});

class AdminState {
  final bool isLoading;
  final String? error;
  final AdminDashboardStats? dashboardData;
  final List<AdminStoreModel>? stores;
  final List<AdminCategoryModel>? categories;
  final List<dynamic>? users;
  final List<dynamic>? merchants;
  final List<dynamic>? drivers;
  final List<dynamic>? orders;

  AdminState({
    this.isLoading = false,
    this.error,
    this.dashboardData,
    this.stores,
    this.categories,
    this.users,
    this.merchants,
    this.drivers,
    this.orders,
  });

  AdminState copyWith({
    bool? isLoading,
    String? error,
    AdminDashboardStats? dashboardData,
    List<AdminStoreModel>? stores,
    List<AdminCategoryModel>? categories,
    List<dynamic>? users,
    List<dynamic>? merchants,
    List<dynamic>? drivers,
    List<dynamic>? orders,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      dashboardData: dashboardData ?? this.dashboardData,
      stores: stores ?? this.stores,
      categories: categories ?? this.categories,
      users: users ?? this.users,
      merchants: merchants ?? this.merchants,
      drivers: drivers ?? this.drivers,
      orders: orders ?? this.orders,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  final AdminService _adminService;

  AdminNotifier(this._adminService) : super(AdminState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _adminService.getDashboardStats();
      state = state.copyWith(
        isLoading: false,
        dashboardData: data,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadStores() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final stores = await _adminService.getStores();
      state = state.copyWith(
        isLoading: false,
        stores: stores,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final categories = await _adminService.getCategories();
      state = state.copyWith(
        isLoading: false,
        categories: categories,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadUsers({String? role, String? search}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _adminService.getUsers(role: role, search: search);
      state = state.copyWith(
        isLoading: false,
        users: data['data']['users'],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadDrivers({String? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _adminService.getAllDrivers(status: status);
      state = state.copyWith(
        isLoading: false,
        drivers: data['data'],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMerchants() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _adminService.getMerchants();
      state = state.copyWith(
        isLoading: false,
        merchants: data['data'],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> reviewDriverApplication({
    required int profileId,
    required String action,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _adminService.reviewDriverApplication(
        profileId: profileId,
        action: action,
        notes: notes,
      );
      state = state.copyWith(isLoading: false);
      await loadDrivers();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> approveStore(String storeId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _adminService.approveStore(storeId);
      if (result.success) {
        await loadStores();
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

  Future<void> rejectStore(String storeId, {String? reason}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _adminService.rejectStore(storeId, reason: reason);
      if (result.success) {
        await loadStores();
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

  Future<void> deleteStore(String storeId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _adminService.deleteStore(storeId);
      if (result.success) {
        await loadStores();
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

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final service = ref.read(adminServiceProvider);
  return AdminNotifier(service);
});