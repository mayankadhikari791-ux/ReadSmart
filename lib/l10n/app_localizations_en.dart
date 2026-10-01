// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ReadSmart';

  @override
  String get loadingLibrary => 'Loading your library...';

  @override
  String get navHome => 'Home';

  @override
  String get navLibrary => 'Library';

  @override
  String get navStats => 'Stats';

  @override
  String get navNotes => 'Notes';

  @override
  String get navProfile => 'Profile';

  @override
  String get btnSave => 'Save';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnClose => 'Close';

  @override
  String get btnEdit => 'Edit';

  @override
  String get btnDelete => 'Delete';

  @override
  String get btnCopy => 'Copy';

  @override
  String get btnSearch => 'Search';

  @override
  String get btnDone => 'Done';

  @override
  String get btnAdd => 'Add';

  @override
  String get dashboardTitle => 'ReadSmart';

  @override
  String get dashboardContinueReading => 'Continue Reading';

  @override
  String get dashboardQuickStats => 'Quick Stats';

  @override
  String get dashboardReadingActivity => 'Reading Activity';

  @override
  String get dashboardAICoach => 'AI Reading Coach';

  @override
  String get dashboardRecentBooks => 'Recently Added';

  @override
  String get libraryTitle => 'E-Book Library';

  @override
  String get libraryAddBook => 'Add Book';

  @override
  String get libraryOpenPdf => 'Open PDF';

  @override
  String get libraryAllBooks => 'All';

  @override
  String get libraryReading => 'Reading';

  @override
  String get libraryCompleted => 'Completed';

  @override
  String get libraryUnread => 'Unread';

  @override
  String get libraryNoBooksFound => 'No books found';

  @override
  String get libraryAddFirstBook => 'Add your first book to get started';

  @override
  String get fullLibraryTitle => 'My Library';

  @override
  String get statsTitle => 'Reading Stats';

  @override
  String get statsStreak => 'Day Streak';

  @override
  String get statsPagesRead => 'Pages Read';

  @override
  String get statsAvgSession => 'Avg Session';

  @override
  String get statsBooksCompleted => 'Books Done';

  @override
  String get statsReadingScore => 'Reading Score';

  @override
  String get statsWeeklyActivity => 'Weekly Activity';

  @override
  String get notesTitle => 'Vocabulary Notes';

  @override
  String get notesSearchHint => 'Search words, meanings...';

  @override
  String get notesNoNotes => 'No vocabulary notes saved yet.';

  @override
  String get notesNoNotesHint =>
      'Tap words while reading any e-book to save notes!';

  @override
  String get notesFlashcards => 'Flashcards';

  @override
  String get notesOpenPage => 'Open Page';

  @override
  String get notesEditNote => 'Edit Note';

  @override
  String get notesDeleteConfirm => 'Note deleted';

  @override
  String get notesUndoDelete => 'Undo';

  @override
  String get notesAllBooks => 'All Books';

  @override
  String notesWords(int count) {
    return '$count words';
  }

  @override
  String get profileTitle => 'Profile & Settings';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileReadingGoals => 'Reading Goals';

  @override
  String get profileTheme => 'Reading Theme';

  @override
  String get profileEditProfile => 'Edit Profile';

  @override
  String get trackerTitle => 'Reading Tracker';

  @override
  String get trackerStart => 'Start Session';

  @override
  String get trackerPause => 'Pause';

  @override
  String get trackerResume => 'Resume';

  @override
  String get trackerFinish => 'Finish Session';

  @override
  String get trackerSessions => 'Session History';

  @override
  String get trackerNoSessions => 'No sessions yet';

  @override
  String get trackerAddBook => 'Add Physical Book';

  @override
  String readerPage(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get readerNextPage => 'Next Page';

  @override
  String get readerPrevPage => 'Previous Page';

  @override
  String get readerBookmark => 'Bookmark';

  @override
  String get readerZoom => 'Zoom';

  @override
  String get readerDarkMode => 'Dark Mode';

  @override
  String get readerSepiaMode => 'Sepia Mode';

  @override
  String get readerLightMode => 'Light Mode';

  @override
  String get readerLoadingPdf => 'Loading PDF…';

  @override
  String get readerBackToLibrary => 'Back to Library';

  @override
  String get dictTitle => 'Dictionary';

  @override
  String get dictLoading => 'Looking up...';

  @override
  String get dictNoResult => 'No definition found';

  @override
  String get dictNetworkError => 'No internet connection';

  @override
  String get dictEnglishMeaning => 'English Meaning';

  @override
  String get dictHindiMeaning => 'Hindi Meaning';

  @override
  String get dictPronounce => 'Pronounce';

  @override
  String get dictSaveToNotes => 'Save to Notes';

  @override
  String get dictSearchAgain => 'Search Again';

  @override
  String get dictCopy => 'Copy';

  @override
  String get dictSavedSuccess => 'Saved to your notes!';

  @override
  String get dictCopiedSuccess => 'Copied to clipboard';

  @override
  String get settingsTitle => 'Language Settings';

  @override
  String get settingsInterfaceLang => 'Interface Language';

  @override
  String get settingsInterfaceLangSubtitle =>
      'Sets the display language for all menus, labels, and buttons.';

  @override
  String get settingsDictLang => 'Dictionary Language';

  @override
  String get settingsDictLangSubtitle =>
      'Word lookups will be translated into these languages.';

  @override
  String get settingsRegionalLang => 'Indian Regional Languages';

  @override
  String get settingsRegionalLangSubtitle =>
      'Select a regional language for supplementary vocabulary.';

  @override
  String get settingsDualDict => 'Dual-Language Lookups';

  @override
  String get settingsDualDictSubtitle =>
      'Show additional translation in Hindi or regional language';

  @override
  String get settingsSaveBtn => 'Save Language Settings';

  @override
  String get settingsSavedSuccess => 'Language settings saved!';

  @override
  String get settingsExtensibilityNote =>
      'ReadSmart uses an extensible localization architecture. Additional dialects can be added easily.';

  @override
  String get settingsPrimaryDict => 'Primary Dictionary';

  @override
  String get settingsSecondaryTranslation => 'Secondary Translation';

  @override
  String get coachTitle => 'AI Coach';

  @override
  String get coachNextTip => 'Next Tip';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSepia => 'Sepia';
}
