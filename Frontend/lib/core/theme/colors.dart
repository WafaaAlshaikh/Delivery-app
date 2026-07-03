// lib/core/theme/colors.dart
//
// Palette: "Route" — built around the idea of a delivery path.
// Coral (the drive) + Teal (the drop-off) + deep ink neutrals.
// Deliberately avoids the generic purple/cream AI-defaults.
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Ink (text) — cool, near-black, never pure black
  static const Color ink900 = Color(0xFF12141A);
  static const Color ink700 = Color(0xFF33363F);
  static const Color ink500 = Color(0xFF5B6472);
  static const Color ink300 = Color(0xFF98A1AF);
  static const Color ink100 = Color(0xFFE7E9ED);

  // Canvas / surfaces
  static const Color canvas = Color(0xFFF6F7F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSunken = Color(0xFFF0F1F4);
  static const Color border = Color(0xFFE6E8ED);

  // Primary — Coral (the moving order / urgency / appetite)
  static const Color primary = Color(0xFFFF5A36);
  static const Color primaryDark = Color(0xFFE0431F);
  static const Color primarySoft = Color(0xFFFFEBE4);

  // Accent — Teal (arrival / trust / freshness)
  static const Color accent = Color(0xFF00B8A9);
  static const Color accentDark = Color(0xFF00968A);
  static const Color accentSoft = Color(0xFFDFF6F3);

  // Gold — ratings / highlights
  static const Color gold = Color(0xFFFFB020);
  static const Color goldSoft = Color(0xFFFFF3DA);

  // Status
  static const Color success = Color(0xFF1FAA59);
  static const Color successSoft = Color(0xFFE3F7EB);
  static const Color error = Color(0xFFE23D3D);
  static const Color errorSoft = Color(0xFFFDEAEA);
  static const Color warning = Color(0xFFFFB020);

  // Role tags (home screen chips)
  static const Color roleAdmin = Color(0xFF6B4EFF);
  static const Color roleMerchant = Color(0xFF00B8A9);
  static const Color roleDriver = Color(0xFFFF5A36);
  static const Color roleCustomer = Color(0xFF2B7FFF);

  // Gradients
  static const LinearGradient routeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFFFF8A5C)],
  );

  static const LinearGradient duskGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B1D2A), Color(0xFF2A2E42)],
  );

  static Color overlay(double opacity) => ink900.withOpacity(opacity);
}
