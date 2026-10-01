import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('zh')
  ];

  /// App name
  ///
  /// In en, this message translates to:
  /// **'ReadSmart'**
  String get appTitle;

  /// Splash loading message
  ///
  /// In en, this message translates to:
  /// **'Loading your library...'**
  String get loadingLibrary;

  /// Bottom nav: Home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom nav: Library tab
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// Bottom nav: Stats tab
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// Bottom nav: Notes tab
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get navNotes;

  /// Bottom nav: Profile tab
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Generic save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// Generic cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// Generic close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get btnClose;

  /// Generic edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get btnEdit;

  /// Generic delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btnDelete;

  /// Generic copy button
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get btnCopy;

  /// Generic search button
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get btnSearch;

  /// Generic done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get btnDone;

  /// Generic add button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get btnAdd;

  /// Home dashboard screen title / brand
  ///
  /// In en, this message translates to:
  /// **'ReadSmart'**
  String get dashboardTitle;

  /// Section header for current book
  ///
  /// In en, this message translates to:
  /// **'Continue Reading'**
  String get dashboardContinueReading;

  /// Section header for quick stats row
  ///
  /// In en, this message translates to:
  /// **'Quick Stats'**
  String get dashboardQuickStats;

  /// Section header for activity chart
  ///
  /// In en, this message translates to:
  /// **'Reading Activity'**
  String get dashboardReadingActivity;

  /// Section header for coaching tips
  ///
  /// In en, this message translates to:
  /// **'AI Reading Coach'**
  String get dashboardAICoach;

  /// Section header for recent books
  ///
  /// In en, this message translates to:
  /// **'Recently Added'**
  String get dashboardRecentBooks;

  /// E-book library screen title
  ///
  /// In en, this message translates to:
  /// **'E-Book Library'**
  String get libraryTitle;

  /// Add book button label
  ///
  /// In en, this message translates to:
  /// **'Add Book'**
  String get libraryAddBook;

  /// Open PDF from device button label
  ///
  /// In en, this message translates to:
  /// **'Open PDF'**
  String get libraryOpenPdf;

  /// Library filter: all books
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get libraryAllBooks;

  /// Library filter: currently reading
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get libraryReading;

  /// Library filter: completed books
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get libraryCompleted;

  /// Library filter: unread books
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get libraryUnread;

  /// Empty state for library
  ///
  /// In en, this message translates to:
  /// **'No books found'**
  String get libraryNoBooksFound;

  /// Empty state subtitle for library
  ///
  /// In en, this message translates to:
  /// **'Add your first book to get started'**
  String get libraryAddFirstBook;

  /// Full library screen title
  ///
  /// In en, this message translates to:
  /// **'My Library'**
  String get fullLibraryTitle;

  /// Stats screen title
  ///
  /// In en, this message translates to:
  /// **'Reading Stats'**
  String get statsTitle;

  /// Streak metric label
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get statsStreak;

  /// Pages read metric label
  ///
  /// In en, this message translates to:
  /// **'Pages Read'**
  String get statsPagesRead;

  /// Average session metric label
  ///
  /// In en, this message translates to:
  /// **'Avg Session'**
  String get statsAvgSession;

  /// Books completed metric label
  ///
  /// In en, this message translates to:
  /// **'Books Done'**
  String get statsBooksCompleted;

  /// Overall reading score label
  ///
  /// In en, this message translates to:
  /// **'Reading Score'**
  String get statsReadingScore;

  /// Weekly activity chart section
  ///
  /// In en, this message translates to:
  /// **'Weekly Activity'**
  String get statsWeeklyActivity;

  /// Notes screen title
  ///
  /// In en, this message translates to:
  /// **'Vocabulary Notes'**
  String get notesTitle;

  /// Search bar hint in notes screen
  ///
  /// In en, this message translates to:
  /// **'Search words, meanings...'**
  String get notesSearchHint;

  /// Empty state for notes screen
  ///
  /// In en, this message translates to:
  /// **'No vocabulary notes saved yet.'**
  String get notesNoNotes;

  /// Empty state hint for notes screen
  ///
  /// In en, this message translates to:
  /// **'Tap words while reading any e-book to save notes!'**
  String get notesNoNotesHint;

  /// Review flashcards button
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get notesFlashcards;

  /// Open page button in notes
  ///
  /// In en, this message translates to:
  /// **'Open Page'**
  String get notesOpenPage;

  /// Edit note dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get notesEditNote;

  /// Snackbar message after deletion
  ///
  /// In en, this message translates to:
  /// **'Note deleted'**
  String get notesDeleteConfirm;

  /// Undo deletion in snackbar
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get notesUndoDelete;

  /// Notes tab: all books filter
  ///
  /// In en, this message translates to:
  /// **'All Books'**
  String get notesAllBooks;

  /// Word count badge in notes
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String notesWords(int count);

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileTitle;

  /// Settings section label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// Language settings menu item
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// Reading goals section label
  ///
  /// In en, this message translates to:
  /// **'Reading Goals'**
  String get profileReadingGoals;

  /// Theme selector label
  ///
  /// In en, this message translates to:
  /// **'Reading Theme'**
  String get profileTheme;

  /// Edit profile button tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditProfile;

  /// Physical tracker screen title
  ///
  /// In en, this message translates to:
  /// **'Reading Tracker'**
  String get trackerTitle;

  /// Start reading session button
  ///
  /// In en, this message translates to:
  /// **'Start Session'**
  String get trackerStart;

  /// Pause session button
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get trackerPause;

  /// Resume session button
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get trackerResume;

  /// Finish session button
  ///
  /// In en, this message translates to:
  /// **'Finish Session'**
  String get trackerFinish;

  /// Session history section header
  ///
  /// In en, this message translates to:
  /// **'Session History'**
  String get trackerSessions;

  /// Empty state for session history
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get trackerNoSessions;

  /// Add physical book button
  ///
  /// In en, this message translates to:
  /// **'Add Physical Book'**
  String get trackerAddBook;

  /// Page indicator in reader
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String readerPage(int current, int total);

  /// Next page tooltip
  ///
  /// In en, this message translates to:
  /// **'Next Page'**
  String get readerNextPage;

  /// Previous page tooltip
  ///
  /// In en, this message translates to:
  /// **'Previous Page'**
  String get readerPrevPage;

  /// Bookmark action tooltip
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get readerBookmark;

  /// Zoom action tooltip
  ///
  /// In en, this message translates to:
  /// **'Zoom'**
  String get readerZoom;

  /// Dark reading mode label
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get readerDarkMode;

  /// Sepia reading mode label
  ///
  /// In en, this message translates to:
  /// **'Sepia Mode'**
  String get readerSepiaMode;

  /// Light reading mode label
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get readerLightMode;

  /// Loading state in PDF reader
  ///
  /// In en, this message translates to:
  /// **'Loading PDF…'**
  String get readerLoadingPdf;

  /// Back to library button in reader
  ///
  /// In en, this message translates to:
  /// **'Back to Library'**
  String get readerBackToLibrary;

  /// Dictionary sheet title
  ///
  /// In en, this message translates to:
  /// **'Dictionary'**
  String get dictTitle;

  /// Dictionary loading state
  ///
  /// In en, this message translates to:
  /// **'Looking up...'**
  String get dictLoading;

  /// Dictionary no result state
  ///
  /// In en, this message translates to:
  /// **'No definition found'**
  String get dictNoResult;

  /// Dictionary network error
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get dictNetworkError;

  /// English meaning section label
  ///
  /// In en, this message translates to:
  /// **'English Meaning'**
  String get dictEnglishMeaning;

  /// Hindi meaning section label
  ///
  /// In en, this message translates to:
  /// **'Hindi Meaning'**
  String get dictHindiMeaning;

  /// Pronounce button in dictionary
  ///
  /// In en, this message translates to:
  /// **'Pronounce'**
  String get dictPronounce;

  /// Save to notes button in dictionary
  ///
  /// In en, this message translates to:
  /// **'Save to Notes'**
  String get dictSaveToNotes;

  /// Search again button in dictionary
  ///
  /// In en, this message translates to:
  /// **'Search Again'**
  String get dictSearchAgain;

  /// Copy meaning button in dictionary
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get dictCopy;

  /// Snackbar after saving word to notes
  ///
  /// In en, this message translates to:
  /// **'Saved to your notes!'**
  String get dictSavedSuccess;

  /// Snackbar after copying definition
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get dictCopiedSuccess;

  /// Language settings screen title
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get settingsTitle;

  /// Interface language section title
  ///
  /// In en, this message translates to:
  /// **'Interface Language'**
  String get settingsInterfaceLang;

  /// Interface language section subtitle
  ///
  /// In en, this message translates to:
  /// **'Sets the display language for all menus, labels, and buttons.'**
  String get settingsInterfaceLangSubtitle;

  /// Dictionary language section title
  ///
  /// In en, this message translates to:
  /// **'Dictionary Language'**
  String get settingsDictLang;

  /// Dictionary language section subtitle
  ///
  /// In en, this message translates to:
  /// **'Word lookups will be translated into these languages.'**
  String get settingsDictLangSubtitle;

  /// Regional language section title
  ///
  /// In en, this message translates to:
  /// **'Indian Regional Languages'**
  String get settingsRegionalLang;

  /// Regional language subtitle
  ///
  /// In en, this message translates to:
  /// **'Select a regional language for supplementary vocabulary.'**
  String get settingsRegionalLangSubtitle;

  /// Dual dictionary toggle label
  ///
  /// In en, this message translates to:
  /// **'Dual-Language Lookups'**
  String get settingsDualDict;

  /// Dual dictionary toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Show additional translation in Hindi or regional language'**
  String get settingsDualDictSubtitle;

  /// Save language settings button
  ///
  /// In en, this message translates to:
  /// **'Save Language Settings'**
  String get settingsSaveBtn;

  /// Snackbar after saving language settings
  ///
  /// In en, this message translates to:
  /// **'Language settings saved!'**
  String get settingsSavedSuccess;

  /// Extensibility info note
  ///
  /// In en, this message translates to:
  /// **'ReadSmart uses an extensible localization architecture. Additional dialects can be added easily.'**
  String get settingsExtensibilityNote;

  /// Primary dictionary label
  ///
  /// In en, this message translates to:
  /// **'Primary Dictionary'**
  String get settingsPrimaryDict;

  /// Secondary translation label
  ///
  /// In en, this message translates to:
  /// **'Secondary Translation'**
  String get settingsSecondaryTranslation;

  /// Coach screen title
  ///
  /// In en, this message translates to:
  /// **'AI Coach'**
  String get coachTitle;

  /// Next tip button in coach
  ///
  /// In en, this message translates to:
  /// **'Next Tip'**
  String get coachNextTip;

  /// Dark theme label
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Light theme label
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Sepia theme label
  ///
  /// In en, this message translates to:
  /// **'Sepia'**
  String get themeSepia;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'es',
        'fr',
        'hi',
        'ja',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
