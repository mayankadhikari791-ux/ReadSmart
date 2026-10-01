import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';

/// Commercial-grade bottom control overlay for the PDF reader.
/// Designed after modern reading apps (Apple Books / Kindle):
/// - Clean, high-precision page scrubber
/// - Clear progress percentage & page counter
/// - Four essential, well-spaced reading tools:
///   1. Jump / Navigation
///   2. Display & Typography Settings
///   3. Smart Dictionary
///   4. Reading Timer Pill
class PdfReaderControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final double brightness;
  final ReadingThemeMode themeMode;
  final bool isBookmarked;
  final bool isTimerRunning;
  final String elapsedTime;
  final double fontSize;

  final ValueChanged<int> onPageChanged;
  final ValueChanged<double> onBrightnessChanged;
  final ValueChanged<ReadingThemeMode> onThemeChanged;
  final VoidCallback onBookmarkToggled;
  final VoidCallback onTimerToggled;
  final ValueChanged<double> onFontSizeChanged;
  final VoidCallback? onDictionaryToggled;
  final VoidCallback? onSettingsToggled;
  final VoidCallback? onNavigationToggled;

  const PdfReaderControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.brightness,
    required this.themeMode,
    required this.isBookmarked,
    required this.isTimerRunning,
    required this.elapsedTime,
    required this.fontSize,
    required this.onPageChanged,
    required this.onBrightnessChanged,
    required this.onThemeChanged,
    required this.onBookmarkToggled,
    required this.onTimerToggled,
    required this.onFontSizeChanged,
    this.onDictionaryToggled,
    this.onSettingsToggled,
    this.onNavigationToggled,
  });

  @override
  Widget build(BuildContext context) {
    final bg = _surfaceColor;
    final textColor = _textColor;
    final accentColor = AppColors.primaryGold;
    final progress = totalPages > 0
        ? ((currentPage / totalPages) * 100).toInt()
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: _borderColor, width: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Page Info & Progress Header ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Page $currentPage of $totalPages',
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.85),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'sans-serif',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.14),
                      borderRadius: AppRadius.roundedSm,
                    ),
                    child: Text(
                      '$progress%',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'sans-serif',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Precision Page Scrubber ────────────────────────────────────
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, size: 24),
                  color: currentPage > 1 ? accentColor : _mutedColor.withValues(alpha: 0.4),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: currentPage > 1
                      ? () => onPageChanged(currentPage - 1)
                      : null,
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      activeTrackColor: accentColor,
                      inactiveTrackColor: _mutedColor.withValues(alpha: 0.25),
                      thumbColor: accentColor,
                      overlayColor: accentColor.withValues(alpha: 0.15),
                    ),
                    child: Slider(
                      min: 1,
                      max: totalPages > 1 ? totalPages.toDouble() : 2.0,
                      value: currentPage.toDouble().clamp(1.0, totalPages.toDouble()),
                      onChanged: (v) => onPageChanged(v.round()),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, size: 24),
                  color: currentPage < totalPages ? accentColor : _mutedColor.withValues(alpha: 0.4),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: currentPage < totalPages
                      ? () => onPageChanged(currentPage + 1)
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ── Essential Reading Tools Row ────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 1. Table of Contents / Jump
                if (onNavigationToggled != null)
                  _toolButton(
                    icon: Icons.alt_route_rounded,
                    label: 'Jump',
                    color: accentColor,
                    onTap: onNavigationToggled!,
                  ),

                // 2. Display & Appearance
                if (onSettingsToggled != null)
                  _toolButton(
                    icon: Icons.tune_rounded,
                    label: 'Display',
                    color: accentColor,
                    onTap: onSettingsToggled!,
                  ),

                // 3. Smart Dictionary
                if (onDictionaryToggled != null)
                  _toolButton(
                    icon: Icons.menu_book_rounded,
                    label: 'Dictionary',
                    color: accentColor,
                    onTap: onDictionaryToggled!,
                  ),

                // 4. Session Timer Pill
                InkWell(
                  onTap: onTimerToggled,
                  borderRadius: AppRadius.roundedPill,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isTimerRunning ? AppColors.successGreen : _mutedColor)
                          .withValues(alpha: 0.12),
                      borderRadius: AppRadius.roundedPill,
                      border: Border.all(
                        color: (isTimerRunning ? AppColors.successGreen : _mutedColor)
                            .withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isTimerRunning ? Icons.timer_rounded : Icons.timer_outlined,
                          size: 14,
                          color: isTimerRunning ? AppColors.successGreen : _mutedColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          elapsedTime,
                          style: TextStyle(
                            color: isTimerRunning ? AppColors.successGreen : _mutedColor,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'sans-serif',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.roundedMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.9),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                fontFamily: 'sans-serif',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _surfaceColor {
    switch (themeMode) {
      case ReadingThemeMode.light:
        return AppColors.lightSurface;
      case ReadingThemeMode.sepia:
        return AppColors.sepiaSurface;
      case ReadingThemeMode.dark:
        return AppColors.darkSurface;
    }
  }

  Color get _textColor {
    switch (themeMode) {
      case ReadingThemeMode.light:
        return AppColors.lightText;
      case ReadingThemeMode.sepia:
        return AppColors.sepiaText;
      case ReadingThemeMode.dark:
        return AppColors.textWhite;
    }
  }

  Color get _borderColor {
    switch (themeMode) {
      case ReadingThemeMode.light:
        return AppColors.lightBorder;
      case ReadingThemeMode.sepia:
        return AppColors.sepiaCard;
      case ReadingThemeMode.dark:
        return AppColors.darkBorder;
    }
  }

  Color get _mutedColor {
    switch (themeMode) {
      case ReadingThemeMode.light:
        return AppColors.lightTextMuted;
      case ReadingThemeMode.sepia:
        return AppColors.sepiaTextMuted;
      case ReadingThemeMode.dark:
        return AppColors.textMuted;
    }
  }
}
