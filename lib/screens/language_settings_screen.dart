import 'package:flutter/material.dart';
import 'package:read_smart/l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';

class LanguageSettingsScreen extends StatefulWidget {
  final AppState appState;

  const LanguageSettingsScreen({super.key, required this.appState});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  late String _currentInterfaceLang;
  late String _currentLocaleCode;
  late String _currentPrimaryDict;
  late String _currentSecondaryDict;
  late String _selectedRegional;
  late bool _dualDictEnabled;

  final List<Map<String, String>> _interfaceLanguages = [
    {'code': 'en', 'name': 'English (US)', 'flag': '🇺🇸'},
    {'code': 'hi', 'name': 'Hindi / हिंदी', 'flag': '🇮🇳'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'ja', 'name': '日本語 (Japanese)', 'flag': '🇯🇵'},
    {'code': 'zh', 'name': '中文 (Chinese)', 'flag': '🇨🇳'},
    {'code': 'ar', 'name': 'العربية (Arabic)', 'flag': '🇸🇦'},
  ];

  final List<String> _regionalLanguages = [
    'ਪੰਜਾਬੀ Punjabi',
    'ગુજરાતી Gujarati',
    'ಕನ್ನಡ Kannada',
    'தமிழ் Tamil',
    'తెలుగు Telugu',
    'മലയാളം Malayalam',
    'বাংলা Bengali',
    'मराठी Marathi',
  ];

  @override
  void initState() {
    super.initState();
    _currentInterfaceLang = widget.appState.interfaceLanguage;
    _currentLocaleCode = widget.appState.localeCode;
    _currentPrimaryDict = widget.appState.primaryDictionaryLanguage;
    _currentSecondaryDict = widget.appState.secondaryDictionaryLanguage;
    _selectedRegional = widget.appState.selectedRegionalLanguage;
    _dualDictEnabled = widget.appState.dualLanguageDictionaryEnabled;
  }

  void _saveSettings() {
    widget.appState.setInterfaceLanguage(_currentInterfaceLang, code: _currentLocaleCode);
    widget.appState.setDictionaryLanguages(
      primary: _currentPrimaryDict,
      secondary: _currentSecondaryDict,
      dualEnabled: _dualDictEnabled,
      regional: _selectedRegional,
    );

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.darkCardElevated,
        content: Text(l10n.settingsSavedSuccess),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Interface Language Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language, size: 16, color: AppColors.primaryGold),
                      const SizedBox(width: 6),
                      Text(
                        (l10n.settingsInterfaceLang).toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.settingsInterfaceLangSubtitle,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                  ),
                  const SizedBox(height: 12),
                  for (final lang in _interfaceLanguages)
                    _buildLanguageRadioRow(
                      flag: lang['flag']!,
                      name: lang['name']!,
                      code: lang['code']!,
                      isSelected: _currentLocaleCode == lang['code'] ||
                          _currentInterfaceLang.contains(lang['name']!.split(' ').first),
                      onSelect: () {
                        setState(() {
                          _currentInterfaceLang = lang['name']!;
                          _currentLocaleCode = lang['code']!;
                        });
                        // Immediate interface update for a dynamic feel
                        widget.appState.setInterfaceLanguage(lang['name']!, code: lang['code']!);
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Dictionary Language Configuration Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_stories, size: 16, color: AppColors.primaryGold),
                      const SizedBox(width: 6),
                      Text(
                        (l10n.settingsDictLang).toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.settingsDictLangSubtitle,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                  ),
                  const SizedBox(height: 14),

                  // Primary Language
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.settingsPrimaryDict,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        const Text('🇺🇸 English (US)',
                            style: TextStyle(
                                color: AppColors.primaryGold,
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Dual Language Toggle
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.primaryGold,
                    title: Text(
                      l10n.settingsDualDict,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    subtitle: Text(
                      l10n.settingsDualDictSubtitle,
                      style:
                          const TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                    value: _dualDictEnabled,
                    onChanged: (val) => setState(() => _dualDictEnabled = val),
                  ),

                  if (_dualDictEnabled) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.primaryGold.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.settingsSecondaryTranslation,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          const Text('🇮🇳 Hindi (हिंदी)',
                              style: TextStyle(
                                  color: AppColors.primaryGold,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Indian Regional Languages Chip Grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🇮🇳 ', style: TextStyle(fontSize: 14)),
                      Text(
                        (l10n.settingsRegionalLang).toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.settingsRegionalLangSubtitle,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final reg in _regionalLanguages)
                        _buildRegionalChip(reg),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. Extensibility Notice Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.primaryGold.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.primaryGold, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.settingsExtensibilityNote,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 5. Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  (l10n.settingsSaveBtn).toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageRadioRow({
    required String flag,
    required String name,
    required String code,
    required bool isSelected,
    required VoidCallback onSelect,
  }) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textMuted,
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: AppColors.primaryGold, size: 18)
            else
              Icon(Icons.radio_button_unchecked,
                  color: Colors.grey.shade700, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionalChip(String name) {
    final isSelected = _selectedRegional == name;
    return InkWell(
      onTap: () => setState(() => _selectedRegional = name),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.darkBorder,
          ),
        ),
        child: Text(
          name,
          style: TextStyle(
            color: isSelected ? Colors.black : AppColors.textMuted,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
