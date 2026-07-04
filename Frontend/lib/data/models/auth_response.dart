// lib/data/models/auth_response.dart
import 'user_model.dart';

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final String? tempToken;
  final UserModel? user;
  final bool? requireVerification;
  final String? expiresIn;
  final Map<String, dynamic>? driverStatus; // ✅ جديد
  final Map<String, dynamic>? data;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.tempToken,
    this.user,
    this.requireVerification,
    this.expiresIn,
    this.driverStatus, // ✅ جديد
    this.data, // ✅ جديد
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
      tempToken: json['tempToken'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      requireVerification: json['requireVerification'],
      expiresIn: json['expiresIn'],
      driverStatus: json['driverStatus'] != null 
          ? Map<String, dynamic>.from(json['driverStatus']) 
          : null,
      // ✅ استخراج data إذا وجد
      data: json['data'] != null 
          ? Map<String, dynamic>.from(json['data']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'tempToken': tempToken,
      'user': user?.toJson(),
      'requireVerification': requireVerification,
      'expiresIn': expiresIn,
      'driverStatus': driverStatus,
      'data': data,
    };
  }
}