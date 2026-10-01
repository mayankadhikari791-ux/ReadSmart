import 'package:flutter/material.dart';

/// Design tokens matching the ReadSmart Stitch Design System
class AppColors {
  // Brand Accents
  static const Color primaryGold = Color(0xFFE8A020);
  static const Color secondaryAmber = Color(0xFFC47A1A);
  static const Color brightFlame = Color(0xFFF5C842);

  // Dark Theme Backgrounds & Surfaces (Default)
  static const Color darkBackground = Color(0xFF141414);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF252525);
  static const Color darkCardElevated = Color(0xFF2E2E2E);
  static const Color darkBorder = Color(0xFF2E2E2E);

  // Text Colors (Dark Mode)
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFB0B0B0);
  static const Color textWarmParchment = Color(0xFFE8E0D0);

  // Sepia Reading Theme
  static const Color sepiaBackground = Color(0xFFF8F0DC);
  static const Color sepiaSurface = Color(0xFFEFE4C8);
  static const Color sepiaCard = Color(0xFFE8DCC0);
  static const Color sepiaText = Color(0xFF3D2B1F);
  static const Color sepiaTextMuted = Color(0xFF7A624E);

  // Light Theme
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFF0F0F0);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E5E5);
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightTextMuted = Color(0xFF6E6E6E);

  // Semantic Status Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF38BDF8);
  static const Color purpleAccent = Color(0xFFA855F7);

  // Gradients & Shimmers
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primaryGold, secondaryAmber],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF272727), Color(0xFF1F1F1F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient spineCreaseGradient = LinearGradient(
    colors: [
      Color(0x33000000),
      Color(0x0D000000),
      Colors.transparent,
      Color(0x0D000000),
      Color(0x33000000),
    ],
    stops: [0.0, 0.05, 0.5, 0.95, 1.0],
  );
}
