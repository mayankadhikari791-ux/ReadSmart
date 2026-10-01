import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_tokens.dart';

enum ReadingThemeMode {
  dark,
  sepia,
  light,
}

class AppTheme {
  /// Dark Theme (Default commercial dark mode)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGold,
        secondary: AppColors.secondaryAmber,
        tertiary: AppColors.brightFlame,
        surface: AppColors.darkSurface,
        onPrimary: Color(0xFF141414),
        onSurface: AppColors.textWhite,
      ),
      fontFamily: 'serif',

      // Card Design System
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.roundedMd,
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // App Bar Design System
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textWhite, size: 22),
        actionsIconTheme: IconThemeData(color: AppColors.primaryGold, size: 22),
        titleTextStyle: TextStyle(
          fontFamily: 'serif',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textWhite,
          letterSpacing: -0.3,
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        selectedItemColor: AppColors.primaryGold,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          fontFamily: 'sans-serif',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          fontFamily: 'sans-serif',
        ),
      ),

      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: const Color(0xFF141414),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.roundedLg,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'sans-serif',
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textWhite,
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.roundedLg,
          ),
          textStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            fontFamily: 'sans-serif',
          ),
        ),
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 13.5,
          fontFamily: 'sans-serif',
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
        ),
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkCard,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.roundedXl,
          side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
      ),

      // Bottom Sheets
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.roundedSheet,
        ),
      ),

      // SnackBars (Floating commercial toast)
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF262626),
        contentTextStyle: const TextStyle(
          color: AppColors.textWhite,
          fontSize: 13.5,
          fontFamily: 'sans-serif',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.roundedMd,
          side: const BorderSide(color: AppColors.darkBorder, width: 0.8),
        ),
        elevation: 8,
      ),

      // Tab Bar
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primaryGold,
        unselectedLabelColor: AppColors.textMuted,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.bold,
          fontFamily: 'sans-serif',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.normal,
          fontFamily: 'sans-serif',
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 0.8,
        space: 1,
      ),

      // Smooth Page Transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Sepia Theme for Reading
  static ThemeData get sepiaTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.sepiaBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.secondaryAmber,
        secondary: AppColors.primaryGold,
        surface: AppColors.sepiaSurface,
        onPrimary: AppColors.textWhite,
        onSurface: AppColors.sepiaText,
      ),
      fontFamily: 'serif',
      cardTheme: CardThemeData(
        color: AppColors.sepiaCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.roundedMd,
          side: BorderSide(
            color: AppColors.sepiaTextMuted.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.sepiaBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.sepiaText, size: 22),
        titleTextStyle: TextStyle(
          fontFamily: 'serif',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.sepiaText,
          letterSpacing: -0.3,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.sepiaCard,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedXl),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.sepiaSurface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedSheet),
      ),
    );
  }

  /// Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGold,
        secondary: AppColors.secondaryAmber,
        surface: AppColors.lightSurface,
        onPrimary: const Color(0xFF141414),
        onSurface: AppColors.lightText,
      ),
      fontFamily: 'serif',
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.roundedMd,
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.lightText, size: 22),
        titleTextStyle: TextStyle(
          fontFamily: 'serif',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.lightText,
          letterSpacing: -0.3,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightCard,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedXl),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedSheet),
      ),
    );
  }
}
