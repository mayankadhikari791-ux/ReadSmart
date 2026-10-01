import 'package:flutter/material.dart';

/// Centralized spacing tokens based on an 8-point geometric grid.
class AppSpacing {
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;

  // Insets shortcuts
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: 18.0,
    vertical: 12.0,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets compactCardPadding = EdgeInsets.all(12.0);
  static const EdgeInsets dialogPadding = EdgeInsets.all(24.0);
  static const EdgeInsets bottomSheetPadding = EdgeInsets.fromLTRB(20, 12, 20, 24);
}

/// Centralized border radius tokens for cohesive geometry across all UI elements.
class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double sheet = 24.0;
  static const double full = 999.0;

  // BorderRadius shortcuts
  static const BorderRadius roundedXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius roundedSheet = BorderRadius.vertical(top: Radius.circular(sheet));
  static const BorderRadius roundedPill = BorderRadius.all(Radius.circular(full));
}

/// Subtle, professional elevation shadows to avoid harsh drop-shadows.
class AppShadows {
  static List<BoxShadow> subtle = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevated = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> sheet = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      blurRadius: 24,
      offset: const Offset(0, -6),
    ),
  ];

  static List<BoxShadow> glow(Color color, {double radius = 12, double alpha = 0.25}) => [
    BoxShadow(
      color: color.withValues(alpha: alpha),
      blurRadius: radius,
      spreadRadius: 1,
    ),
  ];
}

/// Commercial-grade typography hierarchy:
/// Serif for editorial headings and book titles; Sans-Serif for interface UI.
class AppTypography {
  // Editorial Serif Headlines
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'serif',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'serif',
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'serif',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.35,
  );

  // Modern UI Titles & Subtitles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 17,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.35,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 15,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.1,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 13.5,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.1,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.2,
    height: 1.45,
  );

  // Labels & Badges
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  // Reading Passage Text (Book Content)
  static TextStyle bookBody({
    double fontSize = 16.0,
    double lineHeight = 1.6,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: 'serif',
      fontSize: fontSize,
      height: lineHeight,
      color: color,
      letterSpacing: 0.15,
    );
  }
}

