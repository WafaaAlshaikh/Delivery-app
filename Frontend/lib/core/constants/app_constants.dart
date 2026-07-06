// lib/core/constants/app_constants.dart
class AppConstants {
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String tempTokenKey = 'temp_token';
  
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 15;
  
  static const int minPasswordLength = 6;
  
  static const String roleCustomer = 'Customer';
  static const String roleRestaurant = 'Restaurant';
  static const String roleDriver = 'Driver';
  static const String roleAdmin = 'Admin';
}