// lib/providers/driver_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/driver_service.dart';

final driverServiceProvider = Provider<DriverService>((ref) {
  return DriverService();
});

final driverProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(driverServiceProvider);
  final response = await service.getDriverProfile();
  return response['data'];
});

final driverStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(driverServiceProvider);
  final response = await service.getDriverStats();
  return response['data'];
});

class DriverState {
  final bool isLoading;
  final bool isOnline;
  final String? error;
  final Map<String, dynamic>? profile;
  final Map<String, dynamic>? stats;

  DriverState({
    this.isLoading = false,
    this.isOnline = false,
    this.error,
    this.profile,
    this.stats,
  });

  DriverState copyWith({
    bool? isLoading,
    bool? isOnline,
    String? error,
    Map<String, dynamic>? profile,
    Map<String, dynamic>? stats,
  }) {
    return DriverState(
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      error: error ?? this.error,
      profile: profile ?? this.profile,
      stats: stats ?? this.stats,
    );
  }
}

class DriverNotifier extends StateNotifier<DriverState> {
  final DriverService _service;

  DriverNotifier(this._service) : super(DriverState());

  Future<void> loadDriverData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profileResponse = await _service.getDriverProfile();
      final statsResponse = await _service.getDriverStats();

      state = state.copyWith(
        isLoading: false,
        profile: profileResponse['data'],
        stats: statsResponse['data'],
        isOnline: profileResponse['data']?['is_online'] ?? false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> toggleOnline() async {
    try {
      state = state.copyWith(isLoading: true);
      final response = await _service.toggleOnline(
        isOnline: !state.isOnline,
      );
      state = state.copyWith(
        isLoading: false,
        isOnline: response['data']?['is_online'] ?? false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _service.updateLocation(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      if (state.error == null) {
        state = state.copyWith(error: 'Failed to update location');
      }
    }
  }

  Future<void> updateProfile({
    String? vehicleType,
    String? vehiclePlate,
    String? vehicleColor,
    String? vehicleModel,
    String? licenseNumber,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      final response = await _service.updateDriverProfile(
        vehicle_type: vehicleType,
        vehicle_plate: vehiclePlate,
        vehicle_color: vehicleColor,
        vehicle_model: vehicleModel,
        license_number: licenseNumber,
      );
      
      final updatedProfile = response['data'];
      state = state.copyWith(
        isLoading: false,
        profile: updatedProfile,
      );
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

final driverProvider = StateNotifierProvider<DriverNotifier, DriverState>((ref) {
  final service = ref.read(driverServiceProvider);
  return DriverNotifier(service);
});