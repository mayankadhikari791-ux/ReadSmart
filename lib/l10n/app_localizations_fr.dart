// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'ReadSmart';

  @override
  String get loadingLibrary => 'Chargement de votre bibliothèque...';

  @override
  String get navHome => 'Accueil';

  @override
  String get navLibrary => 'Bibliothèque';

  @override
  String get navStats => 'Statistiques';

  @override
  String get navNotes => 'Notes';

  @override
  String get navProfile => 'Profil';

  @override
  String get btnSave => 'Enregistrer';

  @override
  String get btnCancel => 'Annuler';

  @override
  String get btnClose => 'Fermer';

  @override
  String get btnEdit => 'Modifier';

  @override
  String get btnDelete => 'Supprimer';

  @override
  String get btnCopy => 'Copier';

  @override
  String get btnSearch => 'Rechercher';

  @override
  String get btnDone => 'Terminé';

  @override
  String get btnAdd => 'Ajouter';

  @override
  String get dashboardTitle => 'ReadSmart';

  @override
  String get dashboardContinueReading => 'Continuer la lecture';

  @override
  String get dashboardQuickStats => 'Statistiques rapides';

  @override
  String get dashboardReadingActivity => 'Activité de lecture';

  @override
  String get dashboardAICoach => 'Coach de lecture AI';

  @override
  String get dashboardRecentBooks => 'Ajoutés récemment';

  @override
  String get libraryTitle => 'Bibliothèque e-books';

  @override
  String get libraryAddBook => 'Ajouter un livre';

  @override
  String get libraryOpenPdf => 'Ouvrir PDF';

  @override
  String get libraryAllBooks => 'Tous';

  @override
  String get libraryReading => 'En lecture';

  @override
  String get libraryCompleted => 'Terminé';

  @override
  String get libraryUnread => 'Non lu';

  @override
  String get libraryNoBooksFound => 'Aucun livre trouvé';

  @override
  String get libraryAddFirstBook =>
      'Ajoutez votre premier livre pour commencer';

  @override
  String get fullLibraryTitle => 'Ma bibliothèque';

  @override
  String get statsTitle => 'Statistiques de lecture';

  @override
  String get statsStreak => 'Série de jours';

  @override
  String get statsPagesRead => 'Pages lues';

  @override
  String get statsAvgSession => 'Session moyenne';

  @override
  String get statsBooksCompleted => 'Livres terminés';

  @override
  String get statsReadingScore => 'Score de lecture';

  @override
  String get statsWeeklyActivity => 'Activité hebdomadaire';

  @override
  String get notesTitle => 'Notes de vocabulaire';

  @override
  String get notesSearchHint => 'Rechercher des mots, des significations...';

  @override
  String get notesNoNotes =>
      'Aucune note de vocabulaire enregistrée pour le moment.';

  @override
  String get notesNoNotesHint =>
      'Appuyez sur des mots en lisant un e-book pour enregistrer des notes!';

  @override
  String get notesFlashcards => 'Flashcards';

  @override
  String get notesOpenPage => 'Ouvrir la page';

  @override
  String get notesEditNote => 'Modifier la note';

  @override
  String get notesDeleteConfirm => 'Note supprimée';

  @override
  String get notesUndoDelete => 'Annuler';

  @override
  String get notesAllBooks => 'Tous les livres';

  @override
  String notesWords(int count) {
    return '$count mots';
  }

  @override
  String get profileTitle => 'Profil et paramètres';

  @override
  String get profileSettings => 'Paramètres';

  @override
  String get profileLanguage => 'Langue';

  @override
  String get profileReadingGoals => 'Objectifs de lecture';

  @override
  String get profileTheme => 'Thème de lecture';

  @override
  String get profileEditProfile => 'Modifier le profil';

  @override
  String get trackerTitle => 'Suivi de lecture';

  @override
  String get trackerStart => 'Démarrer la session';

  @override
  String get trackerPause => 'Pause';

  @override
  String get trackerResume => 'Reprendre';

  @override
  String get trackerFinish => 'Terminer la session';

  @override
  String get trackerSessions => 'Historique des sessions';

  @override
  String get trackerNoSessions => 'Aucune session pour l\'instant';

  @override
  String get trackerAddBook => 'Ajouter un livre physique';

  @override
  String readerPage(int current, int total) {
    return 'Page $current sur $total';
  }

  @override
  String get readerNextPage => 'Page suivante';

  @override
  String get readerPrevPage => 'Page précédente';

  @override
  String get readerBookmark => 'Signet';

  @override
  String get readerZoom => 'Zoom';

  @override
  String get readerDarkMode => 'Mode sombre';

  @override
  String get readerSepiaMode => 'Mode sépia';

  @override
  String get readerLightMode => 'Mode clair';

  @override
  String get readerLoadingPdf => 'Chargement du PDF…';

  @override
  String get readerBackToLibrary => 'Retour à la bibliothèque';

  @override
  String get dictTitle => 'Dictionnaire';

  @override
  String get dictLoading => 'Recherche en cours...';

  @override
  String get dictNoResult => 'Aucune définition trouvée';

  @override
  String get dictNetworkError => 'Pas de connexion internet';

  @override
  String get dictEnglishMeaning => 'Signification en anglais';

  @override
  String get dictHindiMeaning => 'Signification en hindi';

  @override
  String get dictPronounce => 'Prononcer';

  @override
  String get dictSaveToNotes => 'Enregistrer dans les notes';

  @override
  String get dictSearchAgain => 'Rechercher à nouveau';

  @override
  String get dictCopy => 'Copier';

  @override
  String get dictSavedSuccess => 'Enregistré dans vos notes!';

  @override
  String get dictCopiedSuccess => 'Copié dans le presse-papiers';

  @override
  String get settingsTitle => 'Paramètres de langue';

  @override
  String get settingsInterfaceLang => 'Langue de l\'interface';

  @override
  String get settingsInterfaceLangSubtitle =>
      'Définit la langue d\'affichage de tous les menus, étiquettes et boutons.';

  @override
  String get settingsDictLang => 'Langue du dictionnaire';

  @override
  String get settingsDictLangSubtitle =>
      'Les recherches de mots seront traduites dans ces langues.';

  @override
  String get settingsRegionalLang => 'Langues régionales indiennes';

  @override
  String get settingsRegionalLangSubtitle =>
      'Sélectionnez une langue régionale pour le vocabulaire supplémentaire.';

  @override
  String get settingsDualDict => 'Recherches en double langue';

  @override
  String get settingsDualDictSubtitle =>
      'Afficher une traduction supplémentaire en hindi ou en langue régionale';

  @override
  String get settingsSaveBtn => 'Enregistrer les paramètres de langue';

  @override
  String get settingsSavedSuccess => 'Paramètres de langue enregistrés!';

  @override
  String get settingsExtensibilityNote =>
      'ReadSmart utilise une architecture de localisation extensible.';

  @override
  String get settingsPrimaryDict => 'Dictionnaire principal';

  @override
  String get settingsSecondaryTranslation => 'Traduction secondaire';

  @override
  String get coachTitle => 'Coach AI';

  @override
  String get coachNextTip => 'Conseil suivant';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeSepia => 'Sépia';
}
