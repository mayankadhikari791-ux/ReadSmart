import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Page transition animations supported by the e-book reader.
enum PageTransitionType {
  animatedCurl,
  instantFade,
  verticalContinuous;

  String get label {
    switch (this) {
      case PageTransitionType.animatedCurl:
        return 'Page Turn (Curl)';
      case PageTransitionType.instantFade:
        return 'Instant Fade';
      case PageTransitionType.verticalContinuous:
        return 'Continuous Scroll';
    }
  }

  IconData get icon {
    switch (this) {
      case PageTransitionType.animatedCurl:
        return Icons.auto_stories_rounded;
      case PageTransitionType.instantFade:
        return Icons.flash_on_rounded;
      case PageTransitionType.verticalContinuous:
        return Icons.swap_vert_rounded;
    }
  }
}

/// Paper margin layouts to simulate physical book dimensions.
enum PageMarginLayout {
  bookLike,
  spacious,
  compact;

  String get label {
    switch (this) {
      case PageMarginLayout.bookLike:
        return 'Book-like (Spine)';
      case PageMarginLayout.spacious:
        return 'Spacious Margins';
      case PageMarginLayout.compact:
        return 'Edge-to-Edge';
    }
  }

  EdgeInsets get padding {
    switch (this) {
      case PageMarginLayout.bookLike:
        return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
      case PageMarginLayout.spacious:
        return const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0);
      case PageMarginLayout.compact:
        return const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0);
    }
  }
}

/// Standard line spacing multipliers.
enum LineSpacingPreset {
  compact(1.2, 'Compact (1.2x)'),
  normal(1.5, 'Normal (1.5x)'),
  relaxed(1.8, 'Relaxed (1.8x)'),
  spacious(2.2, 'Spacious (2.2x)');

  final double multiplier;
  final String label;
  const LineSpacingPreset(this.multiplier, this.label);
}

/// Typography font families for comfortable reading.
enum ReaderFontPreset {
  serif('Serif Book', 'serif'),
  sans('Modern Sans', 'sans-serif'),
  monospace('Typewriter', 'monospace'),
  accessible('Accessible High-Legibility', 'serif');

  final String label;
  final String fontFamily;
  const ReaderFontPreset(this.label, this.fontFamily);
}

/// Comprehensive configuration state for the e-book reader.
class ReaderSettings {
  final double fontSize;
  final LineSpacingPreset lineSpacing;
  final double brightness; // 0.0 = normal, 0.6 = dark overlay
  final ReadingThemeMode themeMode;
  final PageTransitionType transition;
  final PageMarginLayout layout;
  final ReaderFontPreset font;
  final double zoom;
  final bool highContrast;
  final bool autoHideControls;
  final bool tapZonesEnabled;
  final bool showFooter;

  const ReaderSettings({
    this.fontSize = 16.0,
    this.lineSpacing = LineSpacingPreset.normal,
    this.brightness = 0.0,
    this.themeMode = ReadingThemeMode.dark,
    this.transition = PageTransitionType.animatedCurl,
    this.layout = PageMarginLayout.bookLike,
    this.font = ReaderFontPreset.serif,
    this.zoom = 1.0,
    this.highContrast = false,
    this.autoHideControls = true,
    this.tapZonesEnabled = true,
    this.showFooter = true,
  });

  ReaderSettings copyWith({
    double? fontSize,
    LineSpacingPreset? lineSpacing,
    double? brightness,
    ReadingThemeMode? themeMode,
    PageTransitionType? transition,
    PageMarginLayout? layout,
    ReaderFontPreset? font,
    double? zoom,
    bool? highContrast,
    bool? autoHideControls,
    bool? tapZonesEnabled,
    bool? showFooter,
  }) {
    return ReaderSettings(
      fontSize: fontSize ?? this.fontSize,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      brightness: brightness ?? this.brightness,
      themeMode: themeMode ?? this.themeMode,
      transition: transition ?? this.transition,
      layout: layout ?? this.layout,
      font: font ?? this.font,
      zoom: zoom ?? this.zoom,
      highContrast: highContrast ?? this.highContrast,
      autoHideControls: autoHideControls ?? this.autoHideControls,
      tapZonesEnabled: tapZonesEnabled ?? this.tapZonesEnabled,
      showFooter: showFooter ?? this.showFooter,
    );
  }

  Map<String, dynamic> toJson() => {
        'fontSize': fontSize,
        'lineSpacing': lineSpacing.name,
        'brightness': brightness,
        'themeMode': themeMode.name,
        'transition': transition.name,
        'layout': layout.name,
        'font': font.name,
        'zoom': zoom,
        'highContrast': highContrast,
        'autoHideControls': autoHideControls,
        'tapZonesEnabled': tapZonesEnabled,
        'showFooter': showFooter,
      };

  factory ReaderSettings.fromJson(Map<String, dynamic> json) {
    return ReaderSettings(
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
      lineSpacing: LineSpacingPreset.values.firstWhere(
        (e) => e.name == json['lineSpacing'],
        orElse: () => LineSpacingPreset.normal,
      ),
      brightness: (json['brightness'] as num?)?.toDouble() ?? 0.0,
      themeMode: ReadingThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => ReadingThemeMode.dark,
      ),
      transition: PageTransitionType.values.firstWhere(
        (e) => e.name == json['transition'],
        orElse: () => PageTransitionType.animatedCurl,
      ),
      layout: PageMarginLayout.values.firstWhere(
        (e) => e.name == json['layout'],
        orElse: () => PageMarginLayout.bookLike,
      ),
      font: ReaderFontPreset.values.firstWhere(
        (e) => e.name == json['font'],
        orElse: () => ReaderFontPreset.serif,
      ),
      zoom: (json['zoom'] as num?)?.toDouble() ?? 1.0,
      highContrast: json['highContrast'] as bool? ?? false,
      autoHideControls: json['autoHideControls'] as bool? ?? true,
      tapZonesEnabled: json['tapZonesEnabled'] as bool? ?? true,
      showFooter: json['showFooter'] as bool? ?? true,
    );
  }
}

