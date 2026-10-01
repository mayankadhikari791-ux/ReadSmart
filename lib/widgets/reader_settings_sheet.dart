import 'package:flutter/material.dart';
import '../models/reader_settings_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class ReaderSettingsSheet extends StatefulWidget {
  final ReaderSettings settings;
  final ValueChanged<ReaderSettings> onSettingsChanged;
  final VoidCallback? onReset;

  const ReaderSettingsSheet({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    this.onReset,
  });

  static Future<void> show({
    required BuildContext context,
    required ReaderSettings settings,
    required ValueChanged<ReaderSettings> onSettingsChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ReaderSettingsSheet(
        settings: settings,
        onSettingsChanged: onSettingsChanged,
      ),
    );
  }

  @override
  State<ReaderSettingsSheet> createState() => _ReaderSettingsSheetState();
}

class _ReaderSettingsSheetState extends State<ReaderSettingsSheet> {
  late ReaderSettings _current;

  @override
  void initState() {
    super.initState();
    _current = widget.settings;
  }

  void _update(ReaderSettings newSettings) {
    setState(() => _current = newSettings);
    widget.onSettingsChanged(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _current.themeMode == ReadingThemeMode.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final mutedColor = isDark ? Colors.white60 : Colors.black54;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune_rounded,
                          color: AppColors.primaryGold, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Reader Display & Comfort',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: mutedColor, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── 1. Reading Themes (Visual Swatches) ─────────────────────────
              _buildSectionHeader('Reading Atmosphere', textColor),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildThemeSwatch(
                    mode: ReadingThemeMode.sepia,
                    label: 'Warm Paper',
                    bgColor: AppColors.sepiaBackground,
                    textColor: AppColors.sepiaText,
                    borderColor: AppColors.primaryGold,
                  ),
                  const SizedBox(width: 8),
                  _buildThemeSwatch(
                    mode: ReadingThemeMode.light,
                    label: 'Crisp Off-White',
                    bgColor: AppColors.lightBackground,
                    textColor: AppColors.lightText,
                    borderColor: Colors.black26,
                  ),
                  const SizedBox(width: 8),
                  _buildThemeSwatch(
                    mode: ReadingThemeMode.dark,
                    label: 'Charcoal Night',
                    bgColor: const Color(0xFF141414),
                    textColor: AppColors.textWhite,
                    borderColor: AppColors.primaryGold,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ── 2. Brightness & Night Dimming ──────────────────────────────
              _buildSectionHeader('Screen Ambient Brightness', textColor),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.wb_sunny_outlined, size: 16, color: mutedColor),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        activeTrackColor: AppColors.primaryGold,
                        inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                        thumbColor: AppColors.primaryGold,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: _current.brightness,
                        min: 0.0,
                        max: 0.6,
                        onChanged: (v) =>
                            _update(_current.copyWith(brightness: v)),
                      ),
                    ),
                  ),
                  Icon(Icons.nights_stay_outlined, size: 16, color: mutedColor),
                ],
              ),

              const SizedBox(height: 14),

              // ── 3. Typography & Font Size ──────────────────────────────────
              _buildSectionHeader(
                'Typography & Scaling (${_current.fontSize.toInt()}pt)',
                textColor,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.text_decrease_rounded, color: textColor),
                    onPressed: _current.fontSize > 12.0
                        ? () => _update(_current.copyWith(
                            fontSize: (_current.fontSize - 1.0).clamp(12.0, 28.0)))
                        : null,
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        activeTrackColor: AppColors.primaryGold,
                        inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                        thumbColor: AppColors.primaryGold,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: _current.fontSize,
                        min: 12.0,
                        max: 28.0,
                        divisions: 16,
                        label: '${_current.fontSize.toInt()} pt',
                        onChanged: (v) => _update(_current.copyWith(fontSize: v)),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.text_increase_rounded, color: textColor),
                    onPressed: _current.fontSize < 28.0
                        ? () => _update(_current.copyWith(
                            fontSize: (_current.fontSize + 1.0).clamp(12.0, 28.0)))
                        : null,
                  ),
                ],
              ),

              // Font Preset Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ReaderFontPreset.values.map((fp) {
                    final isSel = _current.font == fp;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: ChoiceChip(
                        label: Text(fp.label),
                        selected: isSel,
                        selectedColor: AppColors.primaryGold,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.black : textColor,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          fontSize: 11.5,
                        ),
                        backgroundColor:
                            isDark ? Colors.white10 : Colors.black12,
                        onSelected: (_) => _update(_current.copyWith(font: fp)),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 18),

              // ── 4. Line Spacing Presets ────────────────────────────────────
              _buildSectionHeader('Line Spacing', textColor),
              const SizedBox(height: 6),
              Row(
                children: LineSpacingPreset.values.map((ls) {
                  final isSel = _current.lineSpacing == ls;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: InkWell(
                        onTap: () => _update(_current.copyWith(lineSpacing: ls)),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppColors.primaryGold.withValues(alpha: 0.2)
                                : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSel
                                  ? AppColors.primaryGold
                                  : Colors.transparent,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              ls.multiplier.toStringAsFixed(1) + 'x',
                              style: TextStyle(
                                color: isSel ? AppColors.primaryGold : textColor,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 18),

              // ── 5. Page Margin & Book Spine Layout ─────────────────────────
              _buildSectionHeader('Page Layout & Margins', textColor),
              const SizedBox(height: 6),
              Row(
                children: PageMarginLayout.values.map((layout) {
                  final isSel = _current.layout == layout;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: InkWell(
                        onTap: () => _update(_current.copyWith(layout: layout)),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppColors.primaryGold.withValues(alpha: 0.2)
                                : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSel
                                  ? AppColors.primaryGold
                                  : Colors.transparent,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              layout.label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSel ? AppColors.primaryGold : textColor,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 18),

              // ── 6. Page Transitions ────────────────────────────────────────
              _buildSectionHeader('Page Turn Style', textColor),
              const SizedBox(height: 6),
              Row(
                children: PageTransitionType.values.map((pt) {
                  final isSel = _current.transition == pt;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: InkWell(
                        onTap: () => _update(_current.copyWith(transition: pt)),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppColors.primaryGold.withValues(alpha: 0.2)
                                : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSel
                                  ? AppColors.primaryGold
                                  : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(pt.icon,
                                  size: 16,
                                  color: isSel
                                      ? AppColors.primaryGold
                                      : mutedColor),
                              const SizedBox(height: 4),
                              Text(
                                pt.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSel ? AppColors.primaryGold : textColor,
                                  fontWeight:
                                      isSel ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 18),

              // ── 7. Comfort & Accessibility Toggles ──────────────────────────
              _buildSectionHeader('Minimal Distraction & Accessibility', textColor),
              const SizedBox(height: 4),
              SwitchListTile.adaptive(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '3-Zone Tap Navigation',
                  style: TextStyle(color: textColor, fontSize: 13),
                ),
                subtitle: Text(
                  'Left 25% prev • Center 50% menu • Right 25% next',
                  style: TextStyle(color: mutedColor, fontSize: 11),
                ),
                value: _current.tapZonesEnabled,
                activeThumbColor: AppColors.primaryGold,
                onChanged: (v) =>
                    _update(_current.copyWith(tapZonesEnabled: v)),
              ),
              SwitchListTile.adaptive(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Auto-Hide Reading Controls',
                  style: TextStyle(color: textColor, fontSize: 13),
                ),
                subtitle: Text(
                  'Controls smoothly fade out after 4s of inactivity',
                  style: TextStyle(color: mutedColor, fontSize: 11),
                ),
                value: _current.autoHideControls,
                activeThumbColor: AppColors.primaryGold,
                onChanged: (v) =>
                    _update(_current.copyWith(autoHideControls: v)),
              ),
              SwitchListTile.adaptive(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'High Contrast & Edge Sharpening',
                  style: TextStyle(color: textColor, fontSize: 13),
                ),
                subtitle: Text(
                  'Enhanced text sharpness for maximum readability',
                  style: TextStyle(color: mutedColor, fontSize: 11),
                ),
                value: _current.highContrast,
                activeThumbColor: AppColors.primaryGold,
                onChanged: (v) =>
                    _update(_current.copyWith(highContrast: v)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'serif',
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: textColor,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildThemeSwatch({
    required ReadingThemeMode mode,
    required String label,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
  }) {
    final isSelected = _current.themeMode == mode;

    return Expanded(
      child: InkWell(
        onTap: () => _update(_current.copyWith(themeMode: mode)),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primaryGold : borderColor,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryGold.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Aa',
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
