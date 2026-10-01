// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'ReadSmart';

  @override
  String get loadingLibrary => 'आपकी लाइब्रेरी लोड हो रही है...';

  @override
  String get navHome => 'होम';

  @override
  String get navLibrary => 'लाइब्रेरी';

  @override
  String get navStats => 'आँकड़े';

  @override
  String get navNotes => 'नोट्स';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get btnSave => 'सहेजें';

  @override
  String get btnCancel => 'रद्द करें';

  @override
  String get btnClose => 'बंद करें';

  @override
  String get btnEdit => 'संपादित करें';

  @override
  String get btnDelete => 'हटाएं';

  @override
  String get btnCopy => 'कॉपी करें';

  @override
  String get btnSearch => 'खोजें';

  @override
  String get btnDone => 'हो गया';

  @override
  String get btnAdd => 'जोड़ें';

  @override
  String get dashboardTitle => 'ReadSmart';

  @override
  String get dashboardContinueReading => 'पढ़ना जारी रखें';

  @override
  String get dashboardQuickStats => 'त्वरित आँकड़े';

  @override
  String get dashboardReadingActivity => 'पढ़ने की गतिविधि';

  @override
  String get dashboardAICoach => 'AI रीडिंग कोच';

  @override
  String get dashboardRecentBooks => 'हाल ही में जोड़े गए';

  @override
  String get libraryTitle => 'ई-बुक लाइब्रेरी';

  @override
  String get libraryAddBook => 'पुस्तक जोड़ें';

  @override
  String get libraryOpenPdf => 'PDF खोलें';

  @override
  String get libraryAllBooks => 'सभी';

  @override
  String get libraryReading => 'पढ़ रहे हैं';

  @override
  String get libraryCompleted => 'पूर्ण';

  @override
  String get libraryUnread => 'अपठित';

  @override
  String get libraryNoBooksFound => 'कोई पुस्तक नहीं मिली';

  @override
  String get libraryAddFirstBook => 'शुरुआत करने के लिए पहली पुस्तक जोड़ें';

  @override
  String get fullLibraryTitle => 'मेरी लाइब्रेरी';

  @override
  String get statsTitle => 'पढ़ने के आँकड़े';

  @override
  String get statsStreak => 'दिन की लकीर';

  @override
  String get statsPagesRead => 'पृष्ठ पढ़े';

  @override
  String get statsAvgSession => 'औसत सत्र';

  @override
  String get statsBooksCompleted => 'पुस्तकें पूरी';

  @override
  String get statsReadingScore => 'रीडिंग स्कोर';

  @override
  String get statsWeeklyActivity => 'साप्ताहिक गतिविधि';

  @override
  String get notesTitle => 'शब्दावली नोट्स';

  @override
  String get notesSearchHint => 'शब्द, अर्थ खोजें...';

  @override
  String get notesNoNotes => 'अभी तक कोई शब्दावली नोट सहेजा नहीं गया।';

  @override
  String get notesNoNotesHint =>
      'नोट्स सहेजने के लिए ई-बुक पढ़ते समय शब्दों पर टैप करें!';

  @override
  String get notesFlashcards => 'फ्लैशकार्ड';

  @override
  String get notesOpenPage => 'पृष्ठ खोलें';

  @override
  String get notesEditNote => 'नोट संपादित करें';

  @override
  String get notesDeleteConfirm => 'नोट हटाया गया';

  @override
  String get notesUndoDelete => 'पूर्ववत करें';

  @override
  String get notesAllBooks => 'सभी पुस्तकें';

  @override
  String notesWords(int count) {
    return '$count शब्द';
  }

  @override
  String get profileTitle => 'प्रोफ़ाइल और सेटिंग्स';

  @override
  String get profileSettings => 'सेटिंग्स';

  @override
  String get profileLanguage => 'भाषा';

  @override
  String get profileReadingGoals => 'पढ़ने के लक्ष्य';

  @override
  String get profileTheme => 'रीडिंग थीम';

  @override
  String get profileEditProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get trackerTitle => 'रीडिंग ट्रैकर';

  @override
  String get trackerStart => 'सत्र शुरू करें';

  @override
  String get trackerPause => 'रोकें';

  @override
  String get trackerResume => 'फिर शुरू करें';

  @override
  String get trackerFinish => 'सत्र समाप्त करें';

  @override
  String get trackerSessions => 'सत्र इतिहास';

  @override
  String get trackerNoSessions => 'अभी तक कोई सत्र नहीं';

  @override
  String get trackerAddBook => 'भौतिक पुस्तक जोड़ें';

  @override
  String readerPage(int current, int total) {
    return 'पृष्ठ $current / $total';
  }

  @override
  String get readerNextPage => 'अगला पृष्ठ';

  @override
  String get readerPrevPage => 'पिछला पृष्ठ';

  @override
  String get readerBookmark => 'बुकमार्क';

  @override
  String get readerZoom => 'ज़ूम';

  @override
  String get readerDarkMode => 'डार्क मोड';

  @override
  String get readerSepiaMode => 'सेपिया मोड';

  @override
  String get readerLightMode => 'लाइट मोड';

  @override
  String get readerLoadingPdf => 'PDF लोड हो रही है…';

  @override
  String get readerBackToLibrary => 'लाइब्रेरी पर वापस जाएं';

  @override
  String get dictTitle => 'शब्दकोश';

  @override
  String get dictLoading => 'खोज रहे हैं...';

  @override
  String get dictNoResult => 'कोई परिभाषा नहीं मिली';

  @override
  String get dictNetworkError => 'इंटरनेट कनेक्शन नहीं है';

  @override
  String get dictEnglishMeaning => 'अंग्रेज़ी अर्थ';

  @override
  String get dictHindiMeaning => 'हिंदी अर्थ';

  @override
  String get dictPronounce => 'उच्चारण';

  @override
  String get dictSaveToNotes => 'नोट्स में सहेजें';

  @override
  String get dictSearchAgain => 'फिर खोजें';

  @override
  String get dictCopy => 'कॉपी करें';

  @override
  String get dictSavedSuccess => 'आपके नोट्स में सहेजा गया!';

  @override
  String get dictCopiedSuccess => 'क्लिपबोर्ड पर कॉपी हुआ';

  @override
  String get settingsTitle => 'भाषा सेटिंग्स';

  @override
  String get settingsInterfaceLang => 'इंटरफ़ेस भाषा';

  @override
  String get settingsInterfaceLangSubtitle =>
      'सभी मेनू, लेबल और बटन की प्रदर्शन भाषा सेट करता है।';

  @override
  String get settingsDictLang => 'शब्दकोश भाषा';

  @override
  String get settingsDictLangSubtitle =>
      'शब्द खोज इन भाषाओं में अनुवादित होगी।';

  @override
  String get settingsRegionalLang => 'भारतीय क्षेत्रीय भाषाएं';

  @override
  String get settingsRegionalLangSubtitle =>
      'पूरक शब्दावली के लिए क्षेत्रीय भाषा चुनें।';

  @override
  String get settingsDualDict => 'दोहरी-भाषा खोज';

  @override
  String get settingsDualDictSubtitle =>
      'हिंदी या क्षेत्रीय भाषा में अतिरिक्त अनुवाद दिखाएं';

  @override
  String get settingsSaveBtn => 'भाषा सेटिंग्स सहेजें';

  @override
  String get settingsSavedSuccess => 'भाषा सेटिंग्स सहेजी गईं!';

  @override
  String get settingsExtensibilityNote =>
      'ReadSmart एक विस्तार योग्य स्थानीयकरण आर्किटेक्चर का उपयोग करता है।';

  @override
  String get settingsPrimaryDict => 'प्राथमिक शब्दकोश';

  @override
  String get settingsSecondaryTranslation => 'द्वितीयक अनुवाद';

  @override
  String get coachTitle => 'AI कोच';

  @override
  String get coachNextTip => 'अगली टिप';

  @override
  String get themeDark => 'डार्क';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeSepia => 'सेपिया';
}
