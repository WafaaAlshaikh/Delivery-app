// lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/auth_response.dart';
import '../data/models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService);
});

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;
  final AuthResponse? authResponse;
  final bool isInitialized;
  final Map<String, dynamic>? driverStatus;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.authResponse,
    this.isInitialized = false,
    this.driverStatus,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
    AuthResponse? authResponse,
    bool? isInitialized,
    Map<String, dynamic>? driverStatus,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
      authResponse: authResponse ?? this.authResponse,
      isInitialized: isInitialized ?? this.isInitialized,
      driverStatus: driverStatus ?? this.driverStatus,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final StorageService _storageService = StorageService();

  AuthNotifier(this._authService) : super(AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      final user = await _authService.getCurrentUser();

      if (isLoggedIn && user != null) {
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          isInitialized: true,
        );
        
        if (user.isDriver) {
          final driverStatus = await getDriverStatus();
          state = state.copyWith(driverStatus: driverStatus);
        }
      } else {
        state = state.copyWith(isInitialized: true);
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        user: null,
        isInitialized: true,
        error: 'Error checking auth state',
      );
    }
  }

  Future<void> initialize() async {
    await _checkAuth();
  }


  Future<void> signup({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String role = 'Customer',
    String? businessType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.signup(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        role: role,
        businessType: businessType,
      );

      state = state.copyWith(
        isLoading: false,
        authResponse: response,
        error: response.success ? null : response.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }


  Future<Map<String, dynamic>> verifySignup({
    required String email,
    required String otp,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.verifySignup(
        email: email,
        otp: otp,
      );

      if (response.success && response.user != null) {
        await _storageService.saveUser(response.user!);
        if (response.token != null) {
          await _storageService.saveToken(response.token!);
        }

        final driverStatus = response.driverStatus;
        final needsOnboarding = driverStatus?['needsOnboarding'] ?? false;
        final driverStatusText = driverStatus?['status'] ?? 'Pending';

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: response.user,
          authResponse: response,
          error: null,
          driverStatus: driverStatus,
        );

        return {
          'success': true,
          'needsOnboarding': needsOnboarding,
          'driverStatus': driverStatusText,
          'user': response.user,
        };
      } else {
        state = state.copyWith(
          isLoading: false,
          authResponse: response,
          error: response.message,
        );
        return {
          'success': false,
          'message': response.message,
        };
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  Future<void> verifyOTP({
    required String email,
    required String otp,
    String type = 'Verification',
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.verifyOTP(
        email: email,
        otp: otp,
        type: type,
      );

      state = state.copyWith(
        isLoading: false,
        authResponse: response,
        error: response.success ? null : response.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  Future<void> resendOTP({required String email}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.resendOtp(email: email);

      state = state.copyWith(
        isLoading: false,
        authResponse: response,
        error: response.success ? null : response.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response.success && response.user != null) {
        await _storageService.saveUser(response.user!);
        if (response.token != null) {
          await _storageService.saveToken(response.token!);
        }

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: response.user,
          authResponse: response,
          error: null,
        );
        
        if (response.user!.isDriver) {
          final driverStatus = await getDriverStatus();
          state = state.copyWith(driverStatus: driverStatus);
        }
      } else if (response.requireVerification == true) {
        state = state.copyWith(
          isLoading: false,
          authResponse: response,
          error: response.message,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          authResponse: response,
          error: response.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.logout();

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        authResponse: null,
        error: null,
        driverStatus: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        authResponse: null,
        error: null,
        driverStatus: null,
      );
    }
  }

  Future<void> forgotPassword({required String email}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.forgotPassword(email: email);

      state = state.copyWith(
        isLoading: false,
        authResponse: response,
        error: response.success ? null : response.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );

      state = state.copyWith(
        isLoading: false,
        authResponse: response,
        error: response.success ? null : response.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  Future<void> getProfile() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _authService.getProfile();

      if (response.success && response.data != null) {
        await _storageService.saveUser(response.data!);
        state = state.copyWith(
          isLoading: false,
          user: response.data,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? locationAddress,
    String? city,
    String? region,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.updateProfile(
        fullName: fullName,
        phone: phone,
        locationAddress: locationAddress,
        city: city,
        region: region,
      );

      if (response.success && response.data != null) {
        await _storageService.saveUser(response.data!);
        state = state.copyWith(
          isLoading: false,
          user: response.data,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  Future<bool> completeDriverOnboarding({
    required String vehicleType,
    String? vehiclePlate,
    String? vehicleColor,
    String? vehicleModel,
    required String licenseNumber,
    String? licenseImage,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.completeDriverOnboarding(
        vehicleType: vehicleType,
        vehiclePlate: vehiclePlate,
        vehicleColor: vehicleColor,
        vehicleModel: vehicleModel,
        licenseNumber: licenseNumber,
        licenseImage: licenseImage,
      );

      if (response.success && response.data != null) {
        final newDriverStatus = response.data;
        state = state.copyWith(
          isLoading: false,
          error: null,
          driverStatus: newDriverStatus,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      return false;
    }
  }

Future<Map<String, dynamic>?> getDriverStatus() async {
  try {
    final response = await _authService.getDriverStatus();
    if (response['success'] == true) {
      final data = response['data'];
      state = state.copyWith(driverStatus: data);
      return data;
    }
    return null;
  } catch (e) {
    print('❌ Get driver status error: $e');
    return {
      'status': 'Pending',
      'needsOnboarding': true,
      'hasCompleteInfo': false,
    };
  }
}
  Future<bool> canGoOnline() async {
    try {
      final response = await _authService.canGoOnline();
      return response['data']?['canGoOnline'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resubmitDriverApplication({
    required String vehicleType,
    String? vehiclePlate,
    String? vehicleColor,
    String? vehicleModel,
    required String licenseNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.resubmitDriverApplication(
        vehicleType: vehicleType,
        vehiclePlate: vehiclePlate,
        vehicleColor: vehicleColor,
        vehicleModel: vehicleModel,
        licenseNumber: licenseNumber,
      );

      if (response.success && response.data != null) {
        final newDriverStatus = response.data;
        state = state.copyWith(
          isLoading: false,
          error: null,
          driverStatus: newDriverStatus,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      return false;
    }
  }


  void clearError() {
    state = state.copyWith(error: null);
  }

  void resetAuthResponse() {
    state = state.copyWith(authResponse: null);
  }

  bool get isAuthenticatedSync => state.isAuthenticated;
}