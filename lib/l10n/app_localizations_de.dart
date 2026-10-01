// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'ReadSmart';

  @override
  String get loadingLibrary => 'Bibliothek wird geladen...';

  @override
  String get navHome => 'Startseite';

  @override
  String get navLibrary => 'Bibliothek';

  @override
  String get navStats => 'Statistiken';

  @override
  String get navNotes => 'Notizen';

  @override
  String get navProfile => 'Profil';

  @override
  String get btnSave => 'Speichern';

  @override
  String get btnCancel => 'Abbrechen';

  @override
  String get btnClose => 'Schließen';

  @override
  String get btnEdit => 'Bearbeiten';

  @override
  String get btnDelete => 'Löschen';

  @override
  String get btnCopy => 'Kopieren';

  @override
  String get btnSearch => 'Suchen';

  @override
  String get btnDone => 'Fertig';

  @override
  String get btnAdd => 'Hinzufügen';

  @override
  String get dashboardTitle => 'ReadSmart';

  @override
  String get dashboardContinueReading => 'Weiterlesen';

  @override
  String get dashboardQuickStats => 'Schnellstatistiken';

  @override
  String get dashboardReadingActivity => 'Leseaktivität';

  @override
  String get dashboardAICoach => 'KI-Lese-Coach';

  @override
  String get dashboardRecentBooks => 'Kürzlich hinzugefügt';

  @override
  String get libraryTitle => 'E-Book-Bibliothek';

  @override
  String get libraryAddBook => 'Buch hinzufügen';

  @override
  String get libraryOpenPdf => 'PDF öffnen';

  @override
  String get libraryAllBooks => 'Alle';

  @override
  String get libraryReading => 'Lesend';

  @override
  String get libraryCompleted => 'Abgeschlossen';

  @override
  String get libraryUnread => 'Ungelesen';

  @override
  String get libraryNoBooksFound => 'Keine Bücher gefunden';

  @override
  String get libraryAddFirstBook =>
      'Fügen Sie Ihr erstes Buch hinzu, um zu beginnen';

  @override
  String get fullLibraryTitle => 'Meine Bibliothek';

  @override
  String get statsTitle => 'Lesestatistiken';

  @override
  String get statsStreak => 'Tages-Streak';

  @override
  String get statsPagesRead => 'Gelesene Seiten';

  @override
  String get statsAvgSession => 'Durchschn. Sitzung';

  @override
  String get statsBooksCompleted => 'Bücher fertig';

  @override
  String get statsReadingScore => 'Lese-Score';

  @override
  String get statsWeeklyActivity => 'Wöchentliche Aktivität';

  @override
  String get notesTitle => 'Vokabelnotizen';

  @override
  String get notesSearchHint => 'Wörter, Bedeutungen suchen...';

  @override
  String get notesNoNotes => 'Noch keine Vokabelnotizen gespeichert.';

  @override
  String get notesNoNotesHint =>
      'Tippen Sie beim Lesen eines E-Books auf Wörter, um Notizen zu speichern!';

  @override
  String get notesFlashcards => 'Karteikarten';

  @override
  String get notesOpenPage => 'Seite öffnen';

  @override
  String get notesEditNote => 'Notiz bearbeiten';

  @override
  String get notesDeleteConfirm => 'Notiz gelöscht';

  @override
  String get notesUndoDelete => 'Rückgängig';

  @override
  String get notesAllBooks => 'Alle Bücher';

  @override
  String notesWords(int count) {
    return '$count Wörter';
  }

  @override
  String get profileTitle => 'Profil & Einstellungen';

  @override
  String get profileSettings => 'Einstellungen';

  @override
  String get profileLanguage => 'Sprache';

  @override
  String get profileReadingGoals => 'Leseziele';

  @override
  String get profileTheme => 'Lesethema';

  @override
  String get profileEditProfile => 'Profil bearbeiten';

  @override
  String get trackerTitle => 'Lese-Tracker';

  @override
  String get trackerStart => 'Sitzung starten';

  @override
  String get trackerPause => 'Pause';

  @override
  String get trackerResume => 'Fortsetzen';

  @override
  String get trackerFinish => 'Sitzung beenden';

  @override
  String get trackerSessions => 'Sitzungsverlauf';

  @override
  String get trackerNoSessions => 'Noch keine Sitzungen';

  @override
  String get trackerAddBook => 'Physisches Buch hinzufügen';

  @override
  String readerPage(int current, int total) {
    return 'Seite $current von $total';
  }

  @override
  String get readerNextPage => 'Nächste Seite';

  @override
  String get readerPrevPage => 'Vorherige Seite';

  @override
  String get readerBookmark => 'Lesezeichen';

  @override
  String get readerZoom => 'Zoom';

  @override
  String get readerDarkMode => 'Dunkler Modus';

  @override
  String get readerSepiaMode => 'Sepia-Modus';

  @override
  String get readerLightMode => 'Heller Modus';

  @override
  String get readerLoadingPdf => 'PDF wird geladen…';

  @override
  String get readerBackToLibrary => 'Zurück zur Bibliothek';

  @override
  String get dictTitle => 'Wörterbuch';

  @override
  String get dictLoading => 'Suche läuft...';

  @override
  String get dictNoResult => 'Keine Definition gefunden';

  @override
  String get dictNetworkError => 'Keine Internetverbindung';

  @override
  String get dictEnglishMeaning => 'Englische Bedeutung';

  @override
  String get dictHindiMeaning => 'Hindi-Bedeutung';

  @override
  String get dictPronounce => 'Aussprechen';

  @override
  String get dictSaveToNotes => 'In Notizen speichern';

  @override
  String get dictSearchAgain => 'Erneut suchen';

  @override
  String get dictCopy => 'Kopieren';

  @override
  String get dictSavedSuccess => 'In Ihren Notizen gespeichert!';

  @override
  String get dictCopiedSuccess => 'In die Zwischenablage kopiert';

  @override
  String get settingsTitle => 'Spracheinstellungen';

  @override
  String get settingsInterfaceLang => 'Oberflächensprache';

  @override
  String get settingsInterfaceLangSubtitle =>
      'Legt die Anzeigesprache für alle Menüs, Beschriftungen und Schaltflächen fest.';

  @override
  String get settingsDictLang => 'Wörterbuchsprache';

  @override
  String get settingsDictLangSubtitle =>
      'Wortsuchen werden in diese Sprachen übersetzt.';

  @override
  String get settingsRegionalLang => 'Indische Regionalsprachen';

  @override
  String get settingsRegionalLangSubtitle =>
      'Wählen Sie eine Regionalsprache für ergänzendes Vokabular.';

  @override
  String get settingsDualDict => 'Zweisprachige Suche';

  @override
  String get settingsDualDictSubtitle =>
      'Zusätzliche Übersetzung auf Hindi oder Regionalsprache anzeigen';

  @override
  String get settingsSaveBtn => 'Spracheinstellungen speichern';

  @override
  String get settingsSavedSuccess => 'Spracheinstellungen gespeichert!';

  @override
  String get settingsExtensibilityNote =>
      'ReadSmart verwendet eine erweiterbare Lokalisierungsarchitektur.';

  @override
  String get settingsPrimaryDict => 'Primäres Wörterbuch';

  @override
  String get settingsSecondaryTranslation => 'Sekundäre Übersetzung';

  @override
  String get coachTitle => 'KI-Coach';

  @override
  String get coachNextTip => 'Nächster Tipp';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeSepia => 'Sepia';
}
