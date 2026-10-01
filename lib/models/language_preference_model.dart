class LanguagePreference {
  final String id;
  final String interfaceLanguage;
  final String localeCode;
  final String primaryDictionaryLanguage;
  final String secondaryDictionaryLanguage;
  final String regionalLanguage;
  final bool dualLanguageEnabled;
  final String? nativeName;
  final String scriptDirection;

  LanguagePreference({
    String? id,
    String? interfaceLanguage,
    String? displayName,
    String? localeCode,
    String? languageCode,
    String? nativeName,
    String? scriptDirection,
    this.primaryDictionaryLanguage = 'English (US)',
    this.secondaryDictionaryLanguage = 'Hindi (हिंदी)',
    this.regionalLanguage = 'Punjabi (ਪੰਜਾਬੀ)',
    this.dualLanguageEnabled = true,
  })  : id = id ?? 'lang_pref',
        interfaceLanguage = displayName ?? interfaceLanguage ?? 'English (US)',
        localeCode = languageCode ?? localeCode ?? 'en',
        nativeName = nativeName,
        scriptDirection = scriptDirection ?? 'ltr';

  String get displayName => interfaceLanguage;
  String get languageCode => localeCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'interfaceLanguage': interfaceLanguage,
      'localeCode': localeCode,
      'primaryDictionaryLanguage': primaryDictionaryLanguage,
      'secondaryDictionaryLanguage': secondaryDictionaryLanguage,
      'regionalLanguage': regionalLanguage,
      'dualLanguageEnabled': dualLanguageEnabled,
      if (nativeName != null) 'nativeName': nativeName,
      'scriptDirection': scriptDirection,
    };
  }

  factory LanguagePreference.fromJson(Map<String, dynamic> json) {
    return LanguagePreference(
      id: json['id'] as String? ?? 'lang_pref',
      interfaceLanguage:
          json['interfaceLanguage'] as String? ?? 'English (US)',
      displayName: json['displayName'] as String?,
      localeCode: json['localeCode'] as String? ?? 'en',
      languageCode: json['languageCode'] as String?,
      nativeName: json['nativeName'] as String?,
      scriptDirection: json['scriptDirection'] as String? ?? 'ltr',
      primaryDictionaryLanguage:
          json['primaryDictionaryLanguage'] as String? ?? 'English (US)',
      secondaryDictionaryLanguage:
          json['secondaryDictionaryLanguage'] as String? ?? 'Hindi (हिंदी)',
      regionalLanguage:
          json['regionalLanguage'] as String? ?? 'Punjabi (ਪੰਜਾਬੀ)',
      dualLanguageEnabled: json['dualLanguageEnabled'] as bool? ?? true,
    );
  }
}
