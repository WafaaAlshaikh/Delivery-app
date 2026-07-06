// lib/core/constants/api_constants.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000'; 
    } else if (Platform.isIOS) {
      return 'http://localhost:5000';  
    }
    
    return 'http://192.168.1.100:5000';
  }
  
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
  
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}