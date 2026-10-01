// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'ReadSmart';

  @override
  String get loadingLibrary => 'Cargando tu biblioteca...';

  @override
  String get navHome => 'Inicio';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navStats => 'Estadísticas';

  @override
  String get navNotes => 'Notas';

  @override
  String get navProfile => 'Perfil';

  @override
  String get btnSave => 'Guardar';

  @override
  String get btnCancel => 'Cancelar';

  @override
  String get btnClose => 'Cerrar';

  @override
  String get btnEdit => 'Editar';

  @override
  String get btnDelete => 'Eliminar';

  @override
  String get btnCopy => 'Copiar';

  @override
  String get btnSearch => 'Buscar';

  @override
  String get btnDone => 'Listo';

  @override
  String get btnAdd => 'Agregar';

  @override
  String get dashboardTitle => 'ReadSmart';

  @override
  String get dashboardContinueReading => 'Continuar leyendo';

  @override
  String get dashboardQuickStats => 'Estadísticas rápidas';

  @override
  String get dashboardReadingActivity => 'Actividad de lectura';

  @override
  String get dashboardAICoach => 'Entrenador de lectura AI';

  @override
  String get dashboardRecentBooks => 'Agregados recientemente';

  @override
  String get libraryTitle => 'Biblioteca de e-books';

  @override
  String get libraryAddBook => 'Agregar libro';

  @override
  String get libraryOpenPdf => 'Abrir PDF';

  @override
  String get libraryAllBooks => 'Todos';

  @override
  String get libraryReading => 'Leyendo';

  @override
  String get libraryCompleted => 'Completado';

  @override
  String get libraryUnread => 'Sin leer';

  @override
  String get libraryNoBooksFound => 'No se encontraron libros';

  @override
  String get libraryAddFirstBook => 'Agrega tu primer libro para comenzar';

  @override
  String get fullLibraryTitle => 'Mi biblioteca';

  @override
  String get statsTitle => 'Estadísticas de lectura';

  @override
  String get statsStreak => 'Racha de días';

  @override
  String get statsPagesRead => 'Páginas leídas';

  @override
  String get statsAvgSession => 'Sesión promedio';

  @override
  String get statsBooksCompleted => 'Libros terminados';

  @override
  String get statsReadingScore => 'Puntuación de lectura';

  @override
  String get statsWeeklyActivity => 'Actividad semanal';

  @override
  String get notesTitle => 'Notas de vocabulario';

  @override
  String get notesSearchHint => 'Buscar palabras, significados...';

  @override
  String get notesNoNotes => 'Aún no hay notas de vocabulario guardadas.';

  @override
  String get notesNoNotesHint =>
      '¡Toca palabras mientras lees un e-book para guardar notas!';

  @override
  String get notesFlashcards => 'Tarjetas';

  @override
  String get notesOpenPage => 'Abrir página';

  @override
  String get notesEditNote => 'Editar nota';

  @override
  String get notesDeleteConfirm => 'Nota eliminada';

  @override
  String get notesUndoDelete => 'Deshacer';

  @override
  String get notesAllBooks => 'Todos los libros';

  @override
  String notesWords(int count) {
    return '$count palabras';
  }

  @override
  String get profileTitle => 'Perfil y ajustes';

  @override
  String get profileSettings => 'Ajustes';

  @override
  String get profileLanguage => 'Idioma';

  @override
  String get profileReadingGoals => 'Metas de lectura';

  @override
  String get profileTheme => 'Tema de lectura';

  @override
  String get profileEditProfile => 'Editar perfil';

  @override
  String get trackerTitle => 'Rastreador de lectura';

  @override
  String get trackerStart => 'Iniciar sesión';

  @override
  String get trackerPause => 'Pausar';

  @override
  String get trackerResume => 'Reanudar';

  @override
  String get trackerFinish => 'Finalizar sesión';

  @override
  String get trackerSessions => 'Historial de sesiones';

  @override
  String get trackerNoSessions => 'Aún no hay sesiones';

  @override
  String get trackerAddBook => 'Agregar libro físico';

  @override
  String readerPage(int current, int total) {
    return 'Página $current de $total';
  }

  @override
  String get readerNextPage => 'Página siguiente';

  @override
  String get readerPrevPage => 'Página anterior';

  @override
  String get readerBookmark => 'Marcador';

  @override
  String get readerZoom => 'Zoom';

  @override
  String get readerDarkMode => 'Modo oscuro';

  @override
  String get readerSepiaMode => 'Modo sepia';

  @override
  String get readerLightMode => 'Modo claro';

  @override
  String get readerLoadingPdf => 'Cargando PDF…';

  @override
  String get readerBackToLibrary => 'Volver a la biblioteca';

  @override
  String get dictTitle => 'Diccionario';

  @override
  String get dictLoading => 'Buscando...';

  @override
  String get dictNoResult => 'No se encontró definición';

  @override
  String get dictNetworkError => 'Sin conexión a internet';

  @override
  String get dictEnglishMeaning => 'Significado en inglés';

  @override
  String get dictHindiMeaning => 'Significado en hindi';

  @override
  String get dictPronounce => 'Pronunciar';

  @override
  String get dictSaveToNotes => 'Guardar en notas';

  @override
  String get dictSearchAgain => 'Buscar de nuevo';

  @override
  String get dictCopy => 'Copiar';

  @override
  String get dictSavedSuccess => '¡Guardado en tus notas!';

  @override
  String get dictCopiedSuccess => 'Copiado al portapapeles';

  @override
  String get settingsTitle => 'Configuración de idioma';

  @override
  String get settingsInterfaceLang => 'Idioma de interfaz';

  @override
  String get settingsInterfaceLangSubtitle =>
      'Establece el idioma de todos los menús, etiquetas y botones.';

  @override
  String get settingsDictLang => 'Idioma del diccionario';

  @override
  String get settingsDictLangSubtitle =>
      'Las búsquedas de palabras se traducirán a estos idiomas.';

  @override
  String get settingsRegionalLang => 'Idiomas regionales de India';

  @override
  String get settingsRegionalLangSubtitle =>
      'Selecciona un idioma regional para vocabulario adicional.';

  @override
  String get settingsDualDict => 'Búsqueda en doble idioma';

  @override
  String get settingsDualDictSubtitle =>
      'Mostrar traducción adicional en hindi o idioma regional';

  @override
  String get settingsSaveBtn => 'Guardar configuración de idioma';

  @override
  String get settingsSavedSuccess => '¡Configuración de idioma guardada!';

  @override
  String get settingsExtensibilityNote =>
      'ReadSmart utiliza una arquitectura de localización extensible.';

  @override
  String get settingsPrimaryDict => 'Diccionario primario';

  @override
  String get settingsSecondaryTranslation => 'Traducción secundaria';

  @override
  String get coachTitle => 'Entrenador AI';

  @override
  String get coachNextTip => 'Siguiente consejo';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeSepia => 'Sepia';
}
