// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'ReadSmart';

  @override
  String get loadingLibrary => 'جارٍ تحميل مكتبتك...';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navLibrary => 'المكتبة';

  @override
  String get navStats => 'الإحصائيات';

  @override
  String get navNotes => 'الملاحظات';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get btnSave => 'حفظ';

  @override
  String get btnCancel => 'إلغاء';

  @override
  String get btnClose => 'إغلاق';

  @override
  String get btnEdit => 'تعديل';

  @override
  String get btnDelete => 'حذف';

  @override
  String get btnCopy => 'نسخ';

  @override
  String get btnSearch => 'بحث';

  @override
  String get btnDone => 'تم';

  @override
  String get btnAdd => 'إضافة';

  @override
  String get dashboardTitle => 'ReadSmart';

  @override
  String get dashboardContinueReading => 'مواصلة القراءة';

  @override
  String get dashboardQuickStats => 'إحصائيات سريعة';

  @override
  String get dashboardReadingActivity => 'نشاط القراءة';

  @override
  String get dashboardAICoach => 'مدرب القراءة بالذكاء الاصطناعي';

  @override
  String get dashboardRecentBooks => 'أضيفت مؤخراً';

  @override
  String get libraryTitle => 'مكتبة الكتب الإلكترونية';

  @override
  String get libraryAddBook => 'إضافة كتاب';

  @override
  String get libraryOpenPdf => 'فتح ملف PDF';

  @override
  String get libraryAllBooks => 'الكل';

  @override
  String get libraryReading => 'قيد القراءة';

  @override
  String get libraryCompleted => 'مكتملة';

  @override
  String get libraryUnread => 'غير مقروءة';

  @override
  String get libraryNoBooksFound => 'لم يتم العثور على كتب';

  @override
  String get libraryAddFirstBook => 'أضف كتابك الأول للبدء';

  @override
  String get fullLibraryTitle => 'مكتبتي';

  @override
  String get statsTitle => 'إحصائيات القراءة';

  @override
  String get statsStreak => 'أيام متتالية';

  @override
  String get statsPagesRead => 'الصفحات المقروءة';

  @override
  String get statsAvgSession => 'متوسط الجلسة';

  @override
  String get statsBooksCompleted => 'كتب مكتملة';

  @override
  String get statsReadingScore => 'معدل القراءة';

  @override
  String get statsWeeklyActivity => 'النشاط الأسبوعي';

  @override
  String get notesTitle => 'ملاحظات المفردات';

  @override
  String get notesSearchHint => 'بحث عن الكلمات والمعاني...';

  @override
  String get notesNoNotes => 'لا توجد ملاحظات مفردات محفوظة حتى الآن.';

  @override
  String get notesNoNotesHint =>
      'انقر على الكلمات أثناء قراءة كتاب إلكتروني لحفظ الملاحظات!';

  @override
  String get notesFlashcards => 'البطاقات التعليمية';

  @override
  String get notesOpenPage => 'فتح الصفحة';

  @override
  String get notesEditNote => 'تعديل الملاحظة';

  @override
  String get notesDeleteConfirm => 'تم حذف الملاحظة';

  @override
  String get notesUndoDelete => 'تراجع';

  @override
  String get notesAllBooks => 'كل الكتب';

  @override
  String notesWords(int count) {
    return '$count كلمة';
  }

  @override
  String get profileTitle => 'الملف الشخصي والإعدادات';

  @override
  String get profileSettings => 'الإعدادات';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String get profileReadingGoals => 'أهداف القراءة';

  @override
  String get profileTheme => 'سمة القراءة';

  @override
  String get profileEditProfile => 'تعديل الملف الشخصي';

  @override
  String get trackerTitle => 'متتبع القراءة';

  @override
  String get trackerStart => 'بدء الجلسة';

  @override
  String get trackerPause => 'إيقاف مؤقت';

  @override
  String get trackerResume => 'استئناف';

  @override
  String get trackerFinish => 'إنهاء الجلسة';

  @override
  String get trackerSessions => 'سجل الجلسات';

  @override
  String get trackerNoSessions => 'لا توجد جلسات حتى الآن';

  @override
  String get trackerAddBook => 'إضافة كتاب ورقي';

  @override
  String readerPage(int current, int total) {
    return 'صفحة $current من $total';
  }

  @override
  String get readerNextPage => 'الصفحة التالية';

  @override
  String get readerPrevPage => 'الصفحة السابقة';

  @override
  String get readerBookmark => 'إشارة مرجعية';

  @override
  String get readerZoom => 'تكبير';

  @override
  String get readerDarkMode => 'الوضع الداكن';

  @override
  String get readerSepiaMode => 'وضع بني داكن';

  @override
  String get readerLightMode => 'الوضع الفاتح';

  @override
  String get readerLoadingPdf => 'جارٍ تحميل PDF…';

  @override
  String get readerBackToLibrary => 'العودة إلى المكتبة';

  @override
  String get dictTitle => 'القاموس';

  @override
  String get dictLoading => 'جارٍ البحث...';

  @override
  String get dictNoResult => 'لم يتم العثور على تعريف';

  @override
  String get dictNetworkError => 'لا يوجد اتصال بالإنترنت';

  @override
  String get dictEnglishMeaning => 'المعنى بالإنجليزية';

  @override
  String get dictHindiMeaning => 'المعنى بالهندية';

  @override
  String get dictPronounce => 'نطق';

  @override
  String get dictSaveToNotes => 'حفظ في الملاحظات';

  @override
  String get dictSearchAgain => 'بحث مجدداً';

  @override
  String get dictCopy => 'نسخ';

  @override
  String get dictSavedSuccess => 'تم الحفظ في ملاحظاتك!';

  @override
  String get dictCopiedSuccess => 'تم النسخ إلى الحافظة';

  @override
  String get settingsTitle => 'إعدادات اللغة';

  @override
  String get settingsInterfaceLang => 'لغة الواجهة';

  @override
  String get settingsInterfaceLangSubtitle =>
      'تعيين لغة العرض لجميع القوائم والتسميات والأزرار.';

  @override
  String get settingsDictLang => 'لغة القاموس';

  @override
  String get settingsDictLangSubtitle => 'سيتم ترجمة الكلمات إلى هذه اللغات.';

  @override
  String get settingsRegionalLang => 'اللغات الإقليمية الهندية';

  @override
  String get settingsRegionalLangSubtitle =>
      'حدد لغة إقليمية للمفردات التكميلية.';

  @override
  String get settingsDualDict => 'البحث ثنائي اللغة';

  @override
  String get settingsDualDictSubtitle =>
      'عرض ترجمة إضافية باللغة الهندية أو اللغة الإقليمية';

  @override
  String get settingsSaveBtn => 'حفظ إعدادات اللغة';

  @override
  String get settingsSavedSuccess => 'تم حفظ إعدادات اللغة بنجاح!';

  @override
  String get settingsExtensibilityNote =>
      'يعتمد ReadSmart على بنية توطين قابلة للتوسع.';

  @override
  String get settingsPrimaryDict => 'القاموس الأساسي';

  @override
  String get settingsSecondaryTranslation => 'الترجمة الثانوية';

  @override
  String get coachTitle => 'مدرب الذكاء الاصطناعي';

  @override
  String get coachNextTip => 'النصيحة التالية';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeSepia => 'بني داكن';
}
