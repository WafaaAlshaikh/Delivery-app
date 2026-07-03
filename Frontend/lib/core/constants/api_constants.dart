// lib/core/constants/api_constants.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // ✅ Base URL - Auto-detect environment
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000';  // Android Emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:5000';  // iOS Simulator
    }
    
    // Real device - change this to your computer's IP
    return 'http://192.168.1.100:5000';
  }
  
  // ✅ Auth Endpoints (already correct)
  static const String signup = '/api/auth/signup';
  static const String verifySignup = '/api/auth/verify-signup';
  static const String resendOtp = '/api/auth/resend-otp';
  static const String login = '/api/auth/login';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String logout = '/api/auth/logout';
  static const String profile = '/api/auth/profile';
  static const String updateProfile = '/api/auth/profile';
  
  // ✅ Headers
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}