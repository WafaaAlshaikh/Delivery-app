// lib/core/theme/typography.dart
//
// Type system: Sora (display, geometric/confident) + Inter (body, quiet
// workhorse) + JetBrains Mono (order codes, OTP digits, prices).
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle display(double size, {FontWeight? weight, Color? color, double? letterSpacing}) {
    return GoogleFonts.sora(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w700,
      letterSpacing: letterSpacing ?? -0.5,
      height: 1.15,
      color: color ?? AppColors.ink900,
    );
  }

  static TextStyle body(double size, {FontWeight? weight, Color? color, double? height}) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w400,
      height: height ?? 1.5,
      color: color ?? AppColors.ink700,
    );
  }

  static TextStyle mono(double size, {FontWeight? weight, Color? color, double? letterSpacing}) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w600,
      letterSpacing: letterSpacing ?? 2,
      color: color ?? AppColors.ink900,
    );
  }

  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: display(34, weight: FontWeight.w800),
      displayMedium: display(28, weight: FontWeight.w800),
      displaySmall: display(24),
      headlineLarge: display(22),
      headlineMedium: display(20),
      headlineSmall: display(18),
      titleLarge: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.ink900),
      titleMedium: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink900),
      titleSmall: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink700),
      bodyLarge: body(16),
      bodyMedium: body(14),
      bodySmall: body(12, color: AppColors.ink500),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink900),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink500),
      labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink500),
    );
  }
}
