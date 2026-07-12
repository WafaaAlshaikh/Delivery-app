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

  static const String stores = '/api/stores';
  static const String myStore = '/api/stores/my-store';
  static const String storeCategories = '/api/stores/categories';


  static const String orders = '/api/orders';
  static const String myOrders = '/api/orders/my';
  static const String availableOrders = '/api/orders/available';
  static String orderStatus(String orderId) => '/api/orders/$orderId/status';

  static const String adminDashboard = '/api/admin/dashboard';
  static const String adminStores = '/api/admin/stores';
  static const String adminUsers = '/api/admin/users';
  static const String adminCategories = '/api/admin/categories';
  static String adminApproveStore(String storeId) => '/api/admin/stores/$storeId/approve';
  static String adminRejectStore(String storeId) => '/api/admin/stores/$storeId/reject';
  static String adminDeleteStore(String storeId) => '/api/admin/stores/$storeId';

  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';

}