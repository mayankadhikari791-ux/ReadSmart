import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../data/database_manager.dart';
import '../models/book_model.dart';
import '../models/book_note_model.dart';
import '../models/bookmark_model.dart';
import '../models/language_preference_model.dart';
import '../models/reading_session_model.dart';
import '../models/reading_statistics_model.dart';
import '../models/reading_tip_model.dart';
import '../models/user_model.dart';
import '../models/vocabulary_word_model.dart';
import '../models/book_vocabulary_collection_model.dart';
import '../models/reading_analytics_models.dart';
import '../models/coach_models.dart';
import '../models/reading_goal_model.dart';
import '../models/reading_progress_model.dart';
import '../models/reader_settings_model.dart';
import '../core/network/resource.dart';
import '../models/dictionary_entry_model.dart';
import '../services/auth/auth_session_manager.dart';
import '../services/auth/i_auth_service.dart';
import '../services/dictionary/i_dictionary_service.dart';
import '../services/sync/cloud_sync_backend.dart';
import '../services/sync/sync_engine.dart';
import '../services/sync/sync_record.dart';
import '../services/sync/sync_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

// ─── InheritedWidget to pass signOut down the tree ─────────────────────────
class AppSignOut extends InheritedWidget {
  final Future<void> Function() signOut;
  const AppSignOut({super.key, required this.signOut, required super.child});

  static AppSignOut? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppSignOut>();

  @override
  bool updateShouldNotify(AppSignOut old) => false;
}

class AppState extends ChangeNotifier {
  DatabaseManager _db = DatabaseManager.fresh();
  SyncEngine? _syncEngine;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  // ─── Theme & Reader Display ──────────────────────────────────────────────
  ReadingThemeMode _themeMode = ReadingThemeMode.dark;
  double _readerFontSize = 16.0;
  bool _startInFullScreen = true;
  bool _autoBookmark = true;
  ReaderSettings _readerSettings = const ReaderSettings();

  ReadingThemeMode get themeMode => _themeMode;
  double get readerFontSize => _readerFontSize;
  bool get startInFullScreen => _startInFullScreen;
  bool get autoBookmark => _autoBookmark;
  ReaderSettings get readerSettings => _readerSettings;

  void updateReaderSettings(ReaderSettings newSettings) {
    _readerSettings = newSettings;
    _themeMode = newSettings.themeMode;
    _readerFontSize = newSettings.fontSize;
    _db.persistTheme(newSettings.themeMode.name);
    _db.persistFontSize(newSettings.fontSize);
    notifyListeners();
  }

  void setThemeMode(ReadingThemeMode mode) {
    _themeMode = mode;
    _readerSettings = _readerSettings.copyWith(themeMode: mode);
    _db.persistTheme(mode.name);
    notifyListeners();
  }

  void setReaderFontSize(double size) {
    _readerFontSize = size.clamp(12.0, 28.0);
    _readerSettings = _readerSettings.copyWith(fontSize: _readerFontSize);
    _db.persistFontSize(_readerFontSize);
    notifyListeners();
  }

  void toggleFullScreen(bool val) {
    _startInFullScreen = val;
    notifyListeners();
  }

  void toggleAutoBookmark(bool val) {
    _autoBookmark = val;
    notifyListeners();
  }

  // ─── User Profile ─────────────────────────────────────────────────────────
  User _user = User(
    id: 'user_1',
    name: 'Reader',
    email: '',
    readingLevel: 'Avid Reader',
    avatarInitials: 'R',
    memberSince: 'Member',
  );

  User get user => _user;

  Future<void> loadUser() async {
    _user = await _db.settingsRepo.getUser();
    notifyListeners();
  }

  Future<void> updateUser(User updated) async {
    _user = updated;
    await _db.settingsRepo.saveUser(updated);
    notifyListeners();
  }

  // ─── Network & Synchronization State ─────────────────────────────────────
  bool _isOffline = false;
  String? _networkErrorMessage;
  Resource<User> _authStatus = Resource.initial();

  bool get isOffline => _isOffline;
  bool get isSyncing => syncStatus == SyncStatus.syncing;
  String? get networkErrorMessage => _networkErrorMessage;
  Resource<User> get authStatus => _authStatus;
  IAuthService get authService => _db.authService;

  SyncEngine? get syncEngine => _syncEngine;
  SyncStatus get syncStatus =>
      _syncEngine?.status ?? (_isOffline ? SyncStatus.offline : SyncStatus.synced);
  int get pendingSyncCount => _syncEngine?.pendingCount ?? 0;
  DateTime? get lastSyncTime => _syncEngine?.lastSyncTime;
  String? get syncErrorMessage => _syncEngine?.lastError;

  void setOfflineMode(bool offline) {
    _isOffline = offline;
    _syncEngine?.setOnline(!offline);
    notifyListeners();
  }

  Future<void> syncNow() async {
    await _syncEngine?.syncNow();
    notifyListeners();
  }

  Future<void> retrySync() async {
    await _syncEngine?.retry();
    notifyListeners();
  }

  void clearNetworkError() {
    _networkErrorMessage = null;
    notifyListeners();
  }

  Future<Resource<User>> signIn({
    required String email,
    required String password,
  }) async {
    _authStatus = Resource.loading(message: 'Authenticating...');
    notifyListeners();

    final result = await _db.authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (result.isSuccess && result.data != null) {
      _user = result.data!;
      _authStatus = Resource.success(_user);
    } else {
      _networkErrorMessage = result.message;
      _authStatus = result;
    }
    notifyListeners();
    return result;
  }

  Future<Resource<void>> signOut() async {
    final res = await _db.authService.signOut();
    _authStatus = Resource.initial();
    notifyListeners();
    return res;
  }

  // ─── Dictionary & Translation Service (Phase 15) ──────────────────────────
  IDictionaryService get dictionaryService => _db.dictionaryService;

  /// Looks up a word with automatic language code resolution
  Future<DictionaryResult> lookupDictionaryWord(
    String word, {
    String? targetLanguage,
  }) {
    final target = targetLanguage ??
        (_languagePreference.regionalLanguage.isNotEmpty
            ? _codeFromLanguageName(_languagePreference.regionalLanguage)
            : localeCode);
    return _db.dictionaryService.lookupWord(word, targetLanguage: target);
  }

  // ─── Reading Goals ────────────────────────────────────────────────────────
  int _dailyGoalMinutes = 30;
  int _annualBooksGoal = 24;

  int get dailyGoalMinutes => _dailyGoalMinutes;
  int get annualBooksGoal => _annualBooksGoal;

  /// Progress toward today's daily reading goal (0.0 – 1.0)
  double get dailyGoalProgress {
    final todayMinutes = todayReadingSeconds ~/ 60;
    if (_dailyGoalMinutes <= 0) return 0.0;
    return (todayMinutes / _dailyGoalMinutes).clamp(0.0, 1.0);
  }

  /// Today's reading minutes
  int get todayReadingMinutes => todayReadingSeconds ~/ 60;

  Future<void> updateDailyGoal(int minutes) async {
    _dailyGoalMinutes = minutes.clamp(5, 240);
    final goal = ReadingGoal(
      id: 'goals_default',
      dailyMinutesTarget: _dailyGoalMinutes,
      annualBooksTarget: _annualBooksGoal,
    );
    await _db.settingsRepo.saveGoals(goal);
    _syncEngine?.queueMutation(
      id: goal.id,
      entityType: SyncEntityType.goal,
      data: goal.toJson(),
    );
    notifyListeners();
  }

  Future<void> updateAnnualGoal(int books) async {
    _annualBooksGoal = books.clamp(1, 200);
    final goal = ReadingGoal(
      id: 'goals_default',
      dailyMinutesTarget: _dailyGoalMinutes,
      annualBooksTarget: _annualBooksGoal,
    );
    await _db.settingsRepo.saveGoals(goal);
    _syncEngine?.queueMutation(
      id: goal.id,
      entityType: SyncEntityType.goal,
      data: goal.toJson(),
    );
    notifyListeners();
  }

  Future<void> _loadGoals() async {
    final goal = await _db.settingsRepo.getGoals();
    _dailyGoalMinutes = goal.dailyMinutesTarget.clamp(5, 240);
    _annualBooksGoal = goal.annualBooksTarget.clamp(1, 200);
  }

  // ─── Notifications (in-memory toggles — no OS permission layer) ──────────
  bool _dailyReminderEnabled = false;
  bool _streakAlertsEnabled = false;

  bool get dailyReminderEnabled => _dailyReminderEnabled;
  bool get streakAlertsEnabled => _streakAlertsEnabled;

  void toggleDailyReminder(bool val) {
    _dailyReminderEnabled = val;
    notifyListeners();
  }

  void toggleStreakAlerts(bool val) {
    _streakAlertsEnabled = val;
    notifyListeners();
  }

  // ─── Data Management ─────────────────────────────────────────────────────

  /// Clears all reading sessions from storage and memory.
  /// Books and vocabulary notes are NEVER touched.
  Future<void> clearReadingHistory() async {
    await _db.clearAllSessions();
    _sessions = [];
    // Reset aggregate statistics (session-derived fields only)
    _statistics = ReadingStatistics(
      id: _statistics.id,
      streakDays: 0,
      totalPagesRead: 0,
      totalReadingMinutes: 0,
      booksCompleted: _statistics.booksCompleted,
      averageWpm: 250,
      weeklyWpmHistory: const [0, 0, 0, 0, 0, 0, 0],
      userReadingScore: _statistics.userReadingScore > 0 ? _statistics.userReadingScore : 78,
    );
    await _db.persistStatistics(_statistics);
    notifyListeners();
  }

  /// Serializes all vocabulary notes to a pretty-printed JSON string.
  /// Books and sessions are NOT included — vocabulary only.
  String exportNotesAsJson() {
    final data = _vocabularyNotes.map((w) => w.toJson()).toList();
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  // ─── Books ───────────────────────────────────────────────────────────────
  List<Book> _books = [];
  List<Book> get books => _books;

  List<Book> get physicalBooks =>
      _books.where((b) => b.format == BookFormat.physical).toList();

  Book get currentlyReadingBook => _books.isNotEmpty
      ? (_books.firstWhere(
          (b) => b.id == 'book_1',
          orElse: () => _books.first,
        ))
      : Book(
          id: 'placeholder',
          title: 'Loading...',
          author: '',
          totalPages: 100,
          currentPage: 0,
          coverGradient: const [Color(0xFFE8A020), Color(0xFF78350F)],
        );

  Book get physicalSessionBook {
    return _books.firstWhere(
      (b) => b.id == _sessionBookId,
      orElse: () => physicalBooks.isNotEmpty
          ? physicalBooks.first
          : currentlyReadingBook,
    );
  }

  // ─── Phase 12 Complete Library Getters & Operations ───────────────────────
  List<Book> get currentlyReadingBooks =>
      _books.where((b) => b.isReading).toList();

  List<Book> get wantToReadBooks =>
      _books.where((b) => b.isWantToRead).toList();

  List<Book> get completedBooks =>
      _books.where((b) => b.isCompleted).toList();

  List<Book> get uploadedEbooks =>
      _books.where((b) => b.isEbook).toList();

  List<Book> get physicalLibraryBooks =>
      _books.where((b) => b.isPhysical).toList();

  List<Book> get recentlyOpenedBooks {
    final list = List<Book>.from(_books);
    list.sort((a, b) {
      final aTime = a.lastOpenedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.lastOpenedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return list;
  }

  Future<void> touchBookOpened(String bookId) async {
    final idx = _books.indexWhere((b) => b.id == bookId);
    if (idx != -1) {
      final updated = _books[idx].copyWith(
        lastOpenedAt: DateTime.now(),
        lastReadTime: 'Just now',
      );
      _books[idx] = updated;
      await _db.persistBook(updated);
      notifyListeners();
    }
  }

  Future<void> markBookStatus(String bookId, BookStatus status) async {
    final idx = _books.indexWhere((b) => b.id == bookId);
    if (idx != -1) {
      final existing = _books[idx];
      final newCurrent = status == BookStatus.completed && existing.totalPages > 0
          ? existing.totalPages
          : (status == BookStatus.unread ? 0 : existing.currentPage);
      final updated = existing.copyWith(
        status: status,
        currentPage: newCurrent,
        lastOpenedAt: DateTime.now(),
        lastReadTime: 'Just now',
      );
      _books[idx] = updated;
      await _db.persistBook(updated);
      notifyListeners();
    }
  }

  Future<void> toggleBookWantToRead(String bookId) async {
    final idx = _books.indexWhere((b) => b.id == bookId);
    if (idx != -1) {
      final existing = _books[idx];
      final newStatus = existing.status == BookStatus.saved
          ? (existing.currentPage > 0 ? BookStatus.reading : BookStatus.unread)
          : BookStatus.saved;
      final updated = existing.copyWith(status: newStatus);
      _books[idx] = updated;
      await _db.persistBook(updated);
      notifyListeners();
    }
  }

  Future<void> updateBookProgress(String bookId, int currentPage) async {
    final idx = _books.indexWhere((b) => b.id == bookId);
    if (idx != -1) {
      final b = _books[idx];
      final clamped = currentPage.clamp(0, b.totalPages);
      final newStatus = (clamped >= b.totalPages && b.totalPages > 0)
          ? BookStatus.completed
          : (clamped > 0 ? BookStatus.reading : b.status);
      final updated = b.copyWith(
        currentPage: clamped,
        status: newStatus,
        lastOpenedAt: DateTime.now(),
        lastReadTime: 'Just now',
      );
      _books[idx] = updated;
      await _db.persistBook(updated);
      final progress = ReadingProgress(
        id: 'prog_$bookId',
        bookId: bookId,
        currentPage: clamped,
        totalPages: b.totalPages,
        progressPercentage: (clamped / (b.totalPages > 0 ? b.totalPages : 1)) * 100,
        lastReadTimestamp: DateTime.now(),
      );
      await _db.persistProgress(
        bookId: bookId,
        currentPage: clamped,
        totalPages: b.totalPages,
      );
      _syncEngine?.queueMutation(
        id: updated.id,
        entityType: SyncEntityType.book,
        data: updated.toJson(),
      );
      _syncEngine?.queueMutation(
        id: 'prog_$bookId',
        entityType: SyncEntityType.progress,
        bookId: bookId,
        data: progress.toJson(),
      );
      notifyListeners();
    }
  }

  Future<Book> addPhysicalBook({
    required String title,
    required String author,
    required int totalPages,
    int currentPage = 0,
  }) async {
    final clampedCurrent = currentPage.clamp(0, totalPages > 0 ? totalPages : 1);
    final newBook = Book(
      id: 'phys_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      author: author.trim(),
      totalPages: totalPages > 0 ? totalPages : 1,
      currentPage: clampedCurrent,
      format: BookFormat.physical,
      status: clampedCurrent >= totalPages && totalPages > 0
          ? BookStatus.completed
          : (clampedCurrent > 0 ? BookStatus.reading : BookStatus.unread),
      lastReadTime: 'Just now',
      coverGradient: const [
        Color(0xFFD97706),
        Color(0xFF451A03),
      ],
      rating: 4.8,
    );

    await _db.persistBook(newBook);
    if (clampedCurrent > 0) {
      final progress = ReadingProgress(
        id: 'prog_${newBook.id}',
        bookId: newBook.id,
        currentPage: clampedCurrent,
        totalPages: newBook.totalPages,
        progressPercentage: (clampedCurrent / newBook.totalPages) * 100,
        lastReadTimestamp: DateTime.now(),
      );
      await _db.persistProgress(
        bookId: newBook.id,
        currentPage: clampedCurrent,
        totalPages: newBook.totalPages,
      );
      _syncEngine?.queueMutation(
        id: 'prog_${newBook.id}',
        entityType: SyncEntityType.progress,
        bookId: newBook.id,
        data: progress.toJson(),
      );
    }
    _books.insert(0, newBook);
    setSessionBook(newBook.id, newBook.title);
    _syncEngine?.queueMutation(
      id: newBook.id,
      entityType: SyncEntityType.book,
      data: newBook.toJson(),
    );
    notifyListeners();
    return newBook;
  }

  Future<void> updateBookDetails({
    required String bookId,
    String? title,
    String? author,
    int? totalPages,
    int? currentPage,
  }) async {
    final idx = _books.indexWhere((b) => b.id == bookId);
    if (idx != -1) {
      final existing = _books[idx];
      final newTotal = totalPages ?? existing.totalPages;
      final newCurrent =
          (currentPage ?? existing.currentPage).clamp(0, newTotal);
      final updated = Book(
        id: existing.id,
        title: title?.trim().isNotEmpty == true ? title!.trim() : existing.title,
        author:
            author?.trim().isNotEmpty == true ? author!.trim() : existing.author,
        totalPages: newTotal,
        currentPage: newCurrent,
        format: existing.format,
        status: newCurrent >= newTotal && newTotal > 0
            ? BookStatus.completed
            : (newCurrent > 0 ? BookStatus.reading : existing.status),
        lastReadTime: 'Just now',
        coverGradient: existing.coverGradient,
        rating: existing.rating,
        excerpt: existing.excerpt,
      );
      _books[idx] = updated;
      await _db.persistBook(updated);
      await _db.persistProgress(
        bookId: updated.id,
        currentPage: newCurrent,
        totalPages: newTotal,
      );
      if (_sessionBookId == bookId) {
        _sessionBookTitle = updated.title;
        _sessionStartPage = newCurrent;
      }
      _syncEngine?.queueMutation(
        id: updated.id,
        entityType: SyncEntityType.book,
        data: updated.toJson(),
      );
      notifyListeners();
    }
  }

  Future<void> deleteBook(String bookId) async {
    await _db.deleteBook(bookId);
    _books.removeWhere((b) => b.id == bookId);
    if (_sessionBookId == bookId) {
      if (physicalBooks.isNotEmpty) {
        setSessionBook(physicalBooks.first.id, physicalBooks.first.title);
      } else if (_books.isNotEmpty) {
        setSessionBook(_books.first.id, _books.first.title);
      }
    }
    _syncEngine?.queueMutation(
      id: bookId,
      entityType: SyncEntityType.book,
      data: {},
      isDeleted: true,
    );
    notifyListeners();
  }

  /// Adds a PDF file as a new e-book entry in the library.
  /// The filename (without extension) becomes the book title.
  /// Does NOT modify the original PDF file.
  Future<Book> addPdfBook(String filePath) async {
    // Derive a friendly title from the filename
    final fileName = filePath.split(RegExp(r'[/\\]')).last;
    final title = fileName.endsWith('.pdf')
        ? fileName.substring(0, fileName.length - 4).replaceAll('_', ' ')
        : fileName;

    final newBook = Book(
      id: 'pdf_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim().isNotEmpty ? title.trim() : 'Untitled PDF',
      author: 'Unknown Author',
      totalPages: 1, // will be updated once PDF is loaded in reader
      currentPage: 0,
      format: BookFormat.ebook,
      status: BookStatus.unread,
      lastReadTime: 'Just added',
      coverGradient: const [Color(0xFF1A237E), Color(0xFF4A148C)],
      rating: 0.0,
      filePath: filePath,
    );

    await _db.persistBook(newBook);
    _books.insert(0, newBook);
    notifyListeners();
    return newBook;
  }

  /// Updates the total pages of a PDF book once the PDF is loaded and we know
  /// the actual page count. Called from PdfReaderScreen after document loads.
  Future<void> updatePdfTotalPages(String bookId, int totalPages) async {
    final idx = _books.indexWhere((b) => b.id == bookId);
    if (idx == -1) return;
    final existing = _books[idx];
    if (existing.totalPages == totalPages) return; // already correct

    final updated = Book(
      id: existing.id,
      title: existing.title,
      author: existing.author,
      totalPages: totalPages,
      currentPage: existing.currentPage.clamp(0, totalPages),
      format: existing.format,
      status: existing.status,
      lastReadTime: existing.lastReadTime,
      coverGradient: existing.coverGradient,
      rating: existing.rating,
      excerpt: existing.excerpt,
      filePath: existing.filePath,
    );
    _books[idx] = updated;
    await _db.persistBook(updated);
    notifyListeners();
  }

  // ─── Vocabulary Notes (book-scoped) ─────────────────────────────────────
  final List<VocabularyWord> _vocabularyNotes = [];
  Map<String, BookVocabularyCollection> _bookCollections = {};

  List<VocabularyWord> get allVocabularyNotes =>
      List.unmodifiable(_vocabularyNotes);

  List<BookVocabularyCollection> get bookVocabularyCollections =>
      _bookCollections.values.toList();

  BookVocabularyCollection? collectionForBook(String bookId) =>
      _bookCollections[bookId];

  List<VocabularyWord> notesForBook(String bookTitle) {
    // Support lookup by either bookId or bookTitle for UI convenience
    return _vocabularyNotes
        .where((n) =>
            n.bookTitle.trim().toLowerCase() ==
            bookTitle.trim().toLowerCase())
        .toList();
  }

  List<VocabularyWord> notesForBookById(String bookId) {
    final coll = _bookCollections[bookId];
    if (coll != null) return coll.words;
    return _vocabularyNotes.where((n) => n.bookId == bookId).toList();
  }

  List<String> get uniqueBooksWithNotes {
    final titles = _bookCollections.values.map((c) => c.bookTitle).toSet().toList();
    if (titles.isEmpty) {
      final legacyTitles = _vocabularyNotes.map((n) => n.bookTitle).toSet().toList();
      legacyTitles.sort();
      return legacyTitles;
    }
    titles.sort();
    return titles;
  }

  Future<void> addVocabularyNote(VocabularyWord word) async {
    final existsInMemory = _vocabularyNotes.any(
      (n) =>
          n.bookId == word.bookId &&
          n.word.trim().toLowerCase() == word.word.trim().toLowerCase(),
    );
    if (existsInMemory) return;

    await _db.persistVocabularyWord(word);
    _vocabularyNotes.insert(0, word);

    final existingColl = _bookCollections[word.bookId];
    if (existingColl != null) {
      existingColl.addWord(word);
    } else {
      _bookCollections[word.bookId] = BookVocabularyCollection(
        bookId: word.bookId,
        bookTitle: word.bookTitle,
        words: [word],
      );
    }
    _syncEngine?.queueMutation(
      id: word.id,
      entityType: SyncEntityType.vocabulary,
      bookId: word.bookId,
      data: word.toJson(),
    );
    notifyListeners();
  }

  Future<void> updateVocabularyNote(VocabularyWord word) async {
    await _db.updateVocabularyWord(word);
    final idx = _vocabularyNotes.indexWhere((n) => n.id == word.id);
    if (idx != -1) {
      _vocabularyNotes[idx] = word;
    }
    final coll = _bookCollections[word.bookId];
    if (coll != null) {
      coll.updateWord(word);
    }
    _syncEngine?.queueMutation(
      id: word.id,
      entityType: SyncEntityType.vocabulary,
      bookId: word.bookId,
      data: word.toJson(),
    );
    notifyListeners();
  }

  Future<void> deleteVocabularyNote(String noteId) async {
    final noteIdx = _vocabularyNotes.indexWhere((n) => n.id == noteId);
    if (noteIdx == -1) return;
    final note = _vocabularyNotes[noteIdx];

    await _db.deleteVocabularyWord(noteId);
    _vocabularyNotes.removeAt(noteIdx);
    if (_bookCollections.containsKey(note.bookId)) {
      _bookCollections[note.bookId]!.removeWord(noteId);
      if (_bookCollections[note.bookId]!.words.isEmpty) {
        _bookCollections.remove(note.bookId);
      }
    }
    _syncEngine?.queueMutation(
      id: noteId,
      entityType: SyncEntityType.vocabulary,
      bookId: note.bookId,
      data: {},
      isDeleted: true,
    );
    notifyListeners();
  }

  // ─── Bookmarks ───────────────────────────────────────────────────────────
  Future<void> saveBookmark(
      {required String bookId, required int page, required String title}) async {
    final bookmark = Bookmark(
      id: 'bookmark_${DateTime.now().millisecondsSinceEpoch}',
      bookId: bookId,
      pageNumber: page,
      title: title,
      createdAt: DateTime.now(),
    );
    await _db.persistBookmark(bookmark);
    _syncEngine?.queueMutation(
      id: bookmark.id,
      entityType: SyncEntityType.bookmark,
      bookId: bookId,
      data: bookmark.toJson(),
    );
    notifyListeners();
  }

  Future<List<Bookmark>> getBookmarksForBook(String bookId) async {
    return _db.bookRepo.getBookmarksForBook(bookId);
  }

  Future<void> deleteBookmark(String bookmarkId) async {
    await _db.deleteBookmark(bookmarkId);
    _syncEngine?.queueMutation(
      id: bookmarkId,
      entityType: SyncEntityType.bookmark,
      data: {},
      isDeleted: true,
    );
    notifyListeners();
  }

  // ─── Reading Sessions & Physical Tracker State ─────────────────────────
  List<ReadingSession> _sessions = [];
  List<ReadingSession> get sessions => List.unmodifiable(_sessions);

  List<ReadingSession> sessionsForBook(String bookId) {
    return _sessions.where((s) => s.bookId == bookId).toList();
  }

  bool _isSessionActive = false;
  bool _isSessionPaused = false;
  int _sessionDurationSeconds = 0;
  int _sessionStartPage = 0;
  int _sessionPagesRead = 0;
  int _readingSpeedWpm = 250;
  String _sessionBookId = 'book_3';
  String _sessionBookTitle = 'Sapiens: A Brief History';
  Timer? _sessionTimer;

  bool get isSessionActive => _isSessionActive;
  bool get isSessionPaused => _isSessionPaused;
  int get sessionDurationSeconds => _sessionDurationSeconds;
  int get sessionStartPage => _sessionStartPage;
  int get sessionPagesRead => _sessionPagesRead;
  int get readingSpeedWpm => _readingSpeedWpm;
  String get sessionBookId => _sessionBookId;
  String get sessionBookTitle => _sessionBookTitle;

  String get formattedSessionDuration {
    final hours = _sessionDurationSeconds ~/ 3600;
    final minutes = (_sessionDurationSeconds % 3600) ~/ 60;
    final seconds = _sessionDurationSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Transparent metric: Pages per hour for current active session
  double get currentSessionPagesPerHour {
    if (_sessionDurationSeconds <= 0 || _sessionPagesRead <= 0) return 0.0;
    return _sessionPagesRead / (_sessionDurationSeconds / 3600.0);
  }

  /// Transparent metric: Seconds per page for current active session
  double get currentSessionSecondsPerPage {
    if (_sessionPagesRead <= 0) return 0.0;
    return _sessionDurationSeconds / _sessionPagesRead.toDouble();
  }

  /// Transparent metric: Formatted time per page (e.g. "1m 45s" or "45s")
  String get currentSessionFormattedTimePerPage {
    if (_sessionPagesRead <= 0 || _sessionDurationSeconds <= 0) return 'N/A';
    final sec = currentSessionSecondsPerPage.round();
    final m = sec ~/ 60;
    final s = sec % 60;
    if (m > 0) {
      return '${m}m ${s.toString().padLeft(2, '0')}s';
    }
    return '${s}s';
  }

  /// Explainable estimate of WPM based on standard ~250 words per page
  int get currentSessionEstimatedWpm {
    if (_sessionDurationSeconds <= 0 || _sessionPagesRead <= 0) return 0;
    final minutes = _sessionDurationSeconds / 60.0;
    return ((_sessionPagesRead * 250) / minutes).round();
  }

  void setSessionBook(String bookId, String bookTitle) {
    _sessionBookId = bookId;
    _sessionBookTitle = bookTitle;
    final book = _books.firstWhere(
      (b) => b.id == bookId,
      orElse: () => currentlyReadingBook,
    );
    _sessionStartPage = book.currentPage;
    _sessionDurationSeconds = 0;
    _sessionPagesRead = 0;
    _isSessionActive = false;
    _isSessionPaused = false;
    _sessionTimer?.cancel();
    notifyListeners();
  }

  void startPhysicalSession({String? bookId}) {
    if (bookId != null && bookId != _sessionBookId) {
      final book = _books.firstWhere(
        (b) => b.id == bookId,
        orElse: () => currentlyReadingBook,
      );
      _sessionBookId = book.id;
      _sessionBookTitle = book.title;
      _sessionStartPage = book.currentPage;
      _sessionDurationSeconds = 0;
      _sessionPagesRead = 0;
    }

    _isSessionActive = true;
    _isSessionPaused = false;
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _sessionDurationSeconds++;
      if (_sessionDurationSeconds % 60 == 0) {
        _readingSpeedWpm =
            (240 + (_sessionPagesRead * 3)).clamp(200, 320);
      }
      if (_sessionDurationSeconds > 0 && _sessionPagesRead > 0) {
        _readingSpeedWpm = currentSessionEstimatedWpm;
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void pausePhysicalSession() {
    _isSessionActive = false;
    _isSessionPaused = true;
    _sessionTimer?.cancel();
    notifyListeners();
  }

  void resumePhysicalSession() {
    startPhysicalSession();
  }

  void resetPhysicalSession() {
    _isSessionActive = false;
    _isSessionPaused = false;
    _sessionTimer?.cancel();
    _sessionDurationSeconds = 0;
    _sessionPagesRead = 0;
    notifyListeners();
  }

  void updateSessionPages(int pages) {
    _sessionPagesRead = pages;
    if (_sessionDurationSeconds > 0 && pages > 0) {
      _readingSpeedWpm = currentSessionEstimatedWpm;
    }
    notifyListeners();
  }

  /// Completes the session, saves to persistent storage, updates book progress,
  /// and automatically recalculates user reading statistics.
  Future<ReadingSession> completeAndSaveSession({
    required String bookId,
    required int pagesRead,
    int? startPage,
    int? endPage,
    String? notes,
  }) async {
    _isSessionActive = false;
    _isSessionPaused = false;
    _sessionTimer?.cancel();

    final book = _books.firstWhere(
      (b) => b.id == bookId,
      orElse: () => physicalSessionBook,
    );

    final actualStart = startPage ?? book.currentPage;
    final actualEnd = endPage ?? (actualStart + pagesRead).clamp(0, book.totalPages);
    final actualPages = pagesRead > 0
        ? pagesRead
        : (actualEnd - actualStart).clamp(0, book.totalPages);
    final duration = _sessionDurationSeconds > 0 ? _sessionDurationSeconds : 60;

    // Explainable speed: standard ~250 words per page estimation
    final estWpm = duration > 0
        ? ((actualPages * 250) / (duration / 60.0)).round().clamp(50, 900)
        : 250;

    final session = ReadingSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      bookId: book.id,
      bookTitle: book.title,
      durationSeconds: duration,
      pagesRead: actualPages,
      readingSpeedWpm: estWpm,
      timestamp: DateTime.now(),
      startPage: actualStart,
      endPage: actualEnd,
      notes: notes,
    );

    // 1. Save session to repository / persistent storage
    await _db.persistSession(session);
    _sessions.insert(0, session);

    // 2. Update book current page & progress
    await updateBookProgress(book.id, actualEnd);

    // 3. Automatically recalculate statistics & persist
    await _recalculateAndPersistStatistics();

    // 4. Reset tracker state
    _sessionDurationSeconds = 0;
    _sessionPagesRead = 0;
    _sessionStartPage = actualEnd;

    notifyListeners();
    return session;
  }

  /// Backward-compatible stop method
  Future<void> stopPhysicalSession() async {
    if (_sessionDurationSeconds > 0) {
      await completeAndSaveSession(
        bookId: _sessionBookId,
        pagesRead: _sessionPagesRead,
        startPage: _sessionStartPage,
      );
    } else {
      resetPhysicalSession();
    }
  }

  // ─── Analytics & Calculations ─────────────────────────────────────────────

  /// Calculates the reading streak in consecutive days
  int calculateStreakDays() {
    if (_sessions.isEmpty) return _statistics.streakDays;
    final sessionDates = _sessions.map((s) {
      final t = s.timestamp;
      return DateTime(t.year, t.month, t.day);
    }).toSet().toList();
    sessionDates.sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (!sessionDates.contains(today) && !sessionDates.contains(yesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime check = sessionDates.contains(today) ? today : yesterday;
    while (sessionDates.contains(check)) {
      streak++;
      check = check.subtract(const Duration(days: 1));
    }
    return streak > 0 ? streak : 1;
  }

  /// Reading consistency: percentage of days active in the last 14 days
  double calculateReadingConsistency() {
    if (_sessions.isEmpty) return 0.75;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last14 = List.generate(14, (i) => today.subtract(Duration(days: i)));
    final sessionDays = _sessions.map((s) {
      final t = s.timestamp;
      return DateTime(t.year, t.month, t.day);
    }).toSet();

    final activeCount = last14.where((d) => sessionDays.contains(d)).length;
    return (activeCount / 14.0).clamp(0.0, 1.0);
  }
  /// Total duration in seconds spent reading a specific book
  int getTotalReadingTimeSecondsForBook(String bookId) {
    return _sessions
        .where((s) => s.bookId == bookId)
        .fold<int>(0, (sum, s) => sum + s.durationSeconds);
  }

  /// Formatted total reading time for a book
  String getTotalReadingTimeFormattedForBook(String bookId) {
    final sec = getTotalReadingTimeSecondsForBook(bookId);
    if (sec <= 0) return '0 min';
    final h = sec ~/ 3600;
    final m = (sec % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  /// Overall total reading time across all sessions in seconds
  int getTotalReadingTimeSecondsAll() {
    return _sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
  }

  /// Average pages per hour for a specific book
  double getAveragePagesPerHourForBook(String bookId) {
    final bookSessions = _sessions.where((s) => s.bookId == bookId).toList();
    if (bookSessions.isEmpty) return 24.0;
    final totalSec = bookSessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
    final totalPages = bookSessions.fold<int>(0, (sum, s) => sum + s.pagesRead);
    if (totalSec <= 0 || totalPages <= 0) return 24.0;
    return (totalPages / (totalSec / 3600.0));
  }

  /// Average time spent per page for a specific book
  String getAverageTimePerPageForBook(String bookId) {
    final bookSessions = _sessions.where((s) => s.bookId == bookId).toList();
    if (bookSessions.isEmpty) return '2m 15s';
    final totalSec = bookSessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
    final totalPages = bookSessions.fold<int>(0, (sum, s) => sum + s.pagesRead);
    if (totalSec <= 0 || totalPages <= 0) return '2m 15s';
    final secPerPage = (totalSec / totalPages.toDouble()).round();
    final m = secPerPage ~/ 60;
    final s = secPerPage % 60;
    if (m > 0) return '${m}m ${s.toString().padLeft(2, '0')}s';
    return '${s}s';
  }

  /// Estimated remaining reading time for a book
  String getEstRemainingTimeForBook(Book book) {
    final remaining = (book.totalPages - book.currentPage).clamp(0, book.totalPages);
    if (remaining == 0) return 'Completed';

    final bookSessions = _sessions.where((s) => s.bookId == book.id).toList();
    double secPerPage = 135.0; // fallback ~2.25 min/page
    if (bookSessions.isNotEmpty) {
      final totalSec = bookSessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
      final totalPages = bookSessions.fold<int>(0, (sum, s) => sum + s.pagesRead);
      if (totalSec > 0 && totalPages > 0) {
        secPerPage = totalSec / totalPages.toDouble();
      }
    }

    final totalEstSec = (remaining * secPerPage).round();
    final h = totalEstSec ~/ 3600;
    final m = (totalEstSec % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  /// Estimated completion date for a book
  String getEstCompletionDateForBook(Book book) {
    final remaining = (book.totalPages - book.currentPage).clamp(0, book.totalPages);
    if (remaining == 0) return 'Completed';

    // Daily pace based on user history or default 20 pages/day
    double dailyPages = 20.0;
    if (_sessions.isNotEmpty) {
      final totalPages = _sessions.fold<int>(0, (sum, s) => sum + s.pagesRead);
      final days = calculateStreakDays().clamp(1, 30);
      dailyPages = (totalPages / days.toDouble()).clamp(10.0, 100.0);
    }

    final daysNeeded = (remaining / dailyPages).ceil().clamp(1, 365);
    final target = DateTime.now().add(Duration(days: daysNeeded));
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[target.month - 1]} ${target.day} ($daysNeeded days)';
  }

  /// Automatically updates and persists user reading statistics
  Future<void> _recalculateAndPersistStatistics() async {
    final totalPages = _sessions.fold<int>(0, (sum, s) => sum + s.pagesRead);
    final totalSeconds = _sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
    final totalMinutes = totalSeconds ~/ 60;

    final validWpm = _sessions.map((s) => s.readingSpeedWpm).where((w) => w > 0).toList();
    final avgWpm = validWpm.isNotEmpty
        ? (validWpm.reduce((a, b) => a + b) / validWpm.length).round()
        : 250;

    final booksDone = _books.where((b) => b.currentPage >= b.totalPages && b.totalPages > 0).length;
    final streak = calculateStreakDays();
    final consistency = calculateReadingConsistency();
    final score = ((streak * 4) + (consistency * 30) + (booksDone * 10)).round().clamp(20, 100);

    _statistics = ReadingStatistics(
      id: _statistics.id,
      streakDays: streak,
      totalPagesRead: totalPages > 0 ? totalPages : _statistics.totalPagesRead,
      totalReadingMinutes: totalMinutes > 0 ? totalMinutes : _statistics.totalReadingMinutes,
      booksCompleted: booksDone > 0 ? booksDone : _statistics.booksCompleted,
      averageWpm: avgWpm,
      weeklyWpmHistory: _statistics.weeklyWpmHistory,
      userReadingScore: score,
    );

    await _db.persistStatistics(_statistics);
  }

  // ─── Language Settings ───────────────────────────────────────────────────
  LanguagePreference _languagePreference = LanguagePreference(id: 'lang_1');

  LanguagePreference get languagePreference => _languagePreference;
  String get interfaceLanguage => _languagePreference.interfaceLanguage;
  String get localeCode => _languagePreference.localeCode;

  Locale get appLocale {
    final code = _languagePreference.localeCode.isNotEmpty
        ? _languagePreference.localeCode
        : _codeFromLanguageName(_languagePreference.interfaceLanguage);
    return Locale(code);
  }

  static String _codeFromLanguageName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('hindi') || lower.contains('हिंदी') || lower == 'hi') return 'hi';
    if (lower.contains('spanish') || lower.contains('español') || lower == 'es') return 'es';
    if (lower.contains('french') || lower.contains('français') || lower == 'fr') return 'fr';
    if (lower.contains('german') || lower.contains('deutsch') || lower == 'de') return 'de';
    if (lower.contains('japanese') || lower.contains('日本語') || lower == 'ja') return 'ja';
    if (lower.contains('chinese') || lower.contains('中文') || lower == 'zh') return 'zh';
    if (lower.contains('arabic') || lower.contains('العربية') || lower == 'ar') return 'ar';
    return 'en';
  }

  String get primaryDictionaryLanguage =>
      _languagePreference.primaryDictionaryLanguage;
  String get secondaryDictionaryLanguage =>
      _languagePreference.secondaryDictionaryLanguage;
  String get selectedRegionalLanguage =>
      _languagePreference.regionalLanguage;
  bool get dualLanguageDictionaryEnabled =>
      _languagePreference.dualLanguageEnabled;

  void setInterfaceLanguage(String lang, {String? code}) {
    final determinedCode = code ?? _codeFromLanguageName(lang);
    _languagePreference = LanguagePreference(
      id: _languagePreference.id,
      interfaceLanguage: lang,
      localeCode: determinedCode,
      primaryDictionaryLanguage: _languagePreference.primaryDictionaryLanguage,
      secondaryDictionaryLanguage:
          _languagePreference.secondaryDictionaryLanguage,
      regionalLanguage: _languagePreference.regionalLanguage,
      dualLanguageEnabled: _languagePreference.dualLanguageEnabled,
    );
    _db.persistLanguagePreference(_languagePreference);
    notifyListeners();
  }

  void setDictionaryLanguages({
    required String primary,
    required String secondary,
    required bool dualEnabled,
    String? regional,
  }) {
    _languagePreference = LanguagePreference(
      id: _languagePreference.id,
      interfaceLanguage: _languagePreference.interfaceLanguage,
      primaryDictionaryLanguage: primary,
      secondaryDictionaryLanguage: secondary,
      regionalLanguage: regional ?? _languagePreference.regionalLanguage,
      dualLanguageEnabled: dualEnabled,
    );
    _db.persistLanguagePreference(_languagePreference);
    notifyListeners();
  }

  // ─── Reading Statistics & Analytics (Phase 9) ───────────────────────────
  late ReadingStatistics _statistics;

  int get dayStreak => calculateStreakDays();
  int get userReadingScore => _statistics.userReadingScore;
  List<double> get weeklyWpmTrend => _statistics.weeklyWpmHistory;

  /// Total books started by the user
  int get booksStartedCount =>
      _books.where((b) => b.currentPage > 0).length;

  /// Total books fully completed by the user
  int get booksCompletedCount =>
      _books.where((b) => b.currentPage >= b.totalPages && b.totalPages > 0).length;

  int get booksCompletedThisMonth => _statistics.booksCompleted;

  /// Overall total pages read across all sessions (fallback to statistics if empty)
  int get totalPagesReadOverall {
    if (_sessions.isEmpty) return _statistics.totalPagesRead;
    return _sessions.fold<int>(0, (sum, s) => sum + s.pagesRead);
  }

  /// Pages read today
  int get todayPagesRead {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _sessions
        .where((s) {
          final d = DateTime(s.timestamp.year, s.timestamp.month, s.timestamp.day);
          return d.isAtSameMomentAs(today);
        })
        .fold<int>(0, (sum, s) => sum + s.pagesRead);
  }

  /// Pages read in the last 7 days
  int get totalPagesReadThisWeek {
    if (_sessions.isEmpty) return _statistics.totalPagesRead;
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final weekPages = _sessions
        .where((s) => s.timestamp.isAfter(cutoff))
        .fold<int>(0, (sum, s) => sum + s.pagesRead);
    return weekPages > 0 ? weekPages : _statistics.totalPagesRead;
  }

  /// Pages read in the last 30 days
  int get totalPagesReadThisMonth {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final monthPages = _sessions
        .where((s) => s.timestamp.isAfter(cutoff))
        .fold<int>(0, (sum, s) => sum + s.pagesRead);
    return monthPages > 0 ? monthPages : totalPagesReadThisWeek;
  }

  /// Reading time today in seconds
  int get todayReadingSeconds {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _sessions
        .where((s) {
          final d = DateTime(s.timestamp.year, s.timestamp.month, s.timestamp.day);
          return d.isAtSameMomentAs(today);
        })
        .fold<int>(0, (sum, s) => sum + s.durationSeconds);
  }

  /// Reading time this week (last 7 days) in seconds
  int get weeklyReadingSeconds {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final sec = _sessions
        .where((s) => s.timestamp.isAfter(cutoff))
        .fold<int>(0, (sum, s) => sum + s.durationSeconds);
    return sec > 0 ? sec : (_statistics.totalReadingMinutes * 60);
  }

  /// Reading time this month (last 30 days) in seconds
  int get monthlyReadingSeconds {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final sec = _sessions
        .where((s) => s.timestamp.isAfter(cutoff))
        .fold<int>(0, (sum, s) => sum + s.durationSeconds);
    return sec > 0 ? sec : (weeklyReadingSeconds * 2);
  }

  /// Reading time breakdown model
  ReadingTimeBreakdown get readingTimeBreakdown => ReadingTimeBreakdown(
        todaySeconds: todayReadingSeconds,
        weeklySeconds: weeklyReadingSeconds,
        monthlySeconds: monthlyReadingSeconds,
        allTimeSeconds: getTotalReadingTimeSecondsAll() > 0
            ? getTotalReadingTimeSecondsAll()
            : (_statistics.totalReadingMinutes * 60),
      );

  String get totalReadingTimeThisWeek =>
      readingTimeBreakdown.formatSeconds(weeklyReadingSeconds);

  /// Average duration per session across all history
  String get avgSessionDuration {
    if (_sessions.isEmpty) return '28 min';
    final totalSec = _sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
    final avgSec = totalSec ~/ _sessions.length;
    final m = avgSec ~/ 60;
    return m > 0 ? '$m min' : '<1 min';
  }

  /// Average pages per session
  double get averagePagesPerSession {
    if (_sessions.isEmpty) return 14.5;
    final totalPages = _sessions.fold<int>(0, (sum, s) => sum + s.pagesRead);
    return totalPages / _sessions.length.toDouble();
  }

  /// Overall average pages per hour (PPH)
  double get averagePagesPerHourOverall {
    if (_sessions.isEmpty) return 26.5;
    final totalPages = _sessions.fold<int>(0, (sum, s) => sum + s.pagesRead);
    final totalSec = _sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
    if (totalSec <= 0) return 25.0;
    return totalPages / (totalSec / 3600.0);
  }

  /// Returns aggregated daily reading records for the past N days
  List<DailyReadingRecord> getDailyReadingHistory({int days = 7}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final records = <DailyReadingRecord>[];

    for (int i = days - 1; i >= 0; i--) {
      final targetDate = today.subtract(Duration(days: i));
      final daySessions = _sessions.where((s) {
        final d = DateTime(s.timestamp.year, s.timestamp.month, s.timestamp.day);
        return d.isAtSameMomentAs(targetDate);
      }).toList();

      final totalSec = daySessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
      final totalPages = daySessions.fold<int>(0, (sum, s) => sum + s.pagesRead);
      final validWpm = daySessions.map((s) => s.readingSpeedWpm).where((w) => w > 0).toList();
      final avgWpm = validWpm.isNotEmpty
          ? (validWpm.reduce((a, b) => a + b) ~/ validWpm.length)
          : (totalPages > 0 ? 250 : 0);

      records.add(DailyReadingRecord(
        date: targetDate,
        minutesRead: (totalSec / 60).round(),
        pagesRead: totalPages,
        sessionsCount: daySessions.length,
        avgWpm: avgWpm,
      ));
    }

    return records;
  }

  /// Generates dynamic, intelligent improvement suggestions based on real user behavior
  List<ReadingImprovementInsight> generateIntelligentImprovementInsights() {
    final insights = <ReadingImprovementInsight>[];

    // 1. Mandatory Comprehension-First Guardrail
    final recentFastSessions = _sessions
        .take(5)
        .where((s) => s.readingSpeedWpm > 320)
        .length;

    if (recentFastSessions >= 2) {
      insights.add(
        const ReadingImprovementInsight(
          id: 'insight_guardrail_fast',
          type: InsightType.speedComprehensionGuardrail,
          title: 'Speed & Comprehension Balance',
          message: 'Your reading speed reached over 320 WPM recently, but fast reading without pause can lower retention.',
          tip: 'Take a 45-second mental checkpoint every 10 pages to summarize key insights before continuing.',
          icon: Icons.psychology_alt_rounded,
          accentColor: AppColors.brightFlame,
          badgeText: 'Important Guardrail',
          isComprehensionGuardrail: true,
        ),
      );
    } else {
      insights.add(
        const ReadingImprovementInsight(
          id: 'insight_guardrail_core',
          type: InsightType.speedComprehensionGuardrail,
          title: 'Comprehension Always Comes First',
          message: 'ReadSmart prioritizes deep understanding over raw speed. Compounding retention matters most.',
          tip: 'When you encounter dense arguments or rich literature, slow down and let ideas settle.',
          icon: Icons.psychology_rounded,
          accentColor: AppColors.brightFlame,
          badgeText: 'Core Principle',
          isComprehensionGuardrail: true,
        ),
      );
    }

    // 2. Evening vs Morning reading patterns
    if (_sessions.isNotEmpty) {
      int eveningCount = 0;
      int morningCount = 0;
      int afternoonCount = 0;

      for (final s in _sessions) {
        final hour = s.timestamp.hour;
        if (hour >= 18 && hour <= 23) {
          eveningCount++;
        } else if (hour >= 6 && hour < 12) {
          morningCount++;
        } else if (hour >= 12 && hour < 18) {
          afternoonCount++;
        }
      }

      if (eveningCount >= morningCount && eveningCount >= afternoonCount && eveningCount >= 2) {
        insights.add(
          const ReadingImprovementInsight(
            id: 'insight_evening_habit',
            type: InsightType.timingHabit,
            title: 'Evening Prime Reading Time',
            message: 'You read most consistently in the evening (7 PM – 11 PM).',
            tip: 'Use Warm Sepia or Dark Mode during evening sessions to ease eye strain before sleep.',
            icon: Icons.nightlight_round,
            accentColor: AppColors.primaryGold,
            badgeText: 'Habit Pattern',
          ),
        );
      } else if (morningCount >= eveningCount && morningCount >= 2) {
        insights.add(
          const ReadingImprovementInsight(
            id: 'insight_morning_habit',
            type: InsightType.timingHabit,
            title: 'Morning Focus Advantage',
            message: 'You achieve your longest uninterrupted reading sessions in the morning.',
            tip: 'Keep morning books focused on challenging non-fiction when cognitive alertness is highest.',
            icon: Icons.wb_sunny_rounded,
            accentColor: AppColors.primaryGold,
            badgeText: 'Peak Focus',
          ),
        );
      }
    }

    // 3. Session Duration Growth Check
    if (_sessions.length >= 4) {
      final recentAvg = _sessions.take(3).fold<int>(0, (sum, s) => sum + s.durationSeconds) / 3.0;
      final olderAvg = _sessions.skip(3).take(3).fold<int>(0, (sum, s) => sum + s.durationSeconds) / 3.0;

      if (recentAvg > olderAvg * 1.15) {
        final recentMin = (recentAvg / 60).round();
        final olderMin = (olderAvg / 60).round();
        insights.add(
          ReadingImprovementInsight(
            id: 'insight_session_growth',
            type: InsightType.sessionGrowth,
            title: 'Session Duration Growth',
            message: 'Your average session length increased this week (from ${olderMin}m to ${recentMin}m).',
            tip: 'Your stamina is building nicely. Consider 25-minute Pomodoro sprints to maintain high retention.',
            icon: Icons.trending_up_rounded,
            accentColor: AppColors.successGreen,
            badgeText: 'Progress',
          ),
        );
      }
    }

    // 4. Reading Consistency Insight
    final consistencyPercent = (calculateReadingConsistency() * 100).round();
    if (consistencyPercent >= 60) {
      insights.add(
        ReadingImprovementInsight(
          id: 'insight_consistency_high',
          type: InsightType.consistency,
          title: 'Strong Reading Consistency',
          message: 'You were active on $consistencyPercent% of days over the past two weeks.',
          tip: 'Daily 15-minute sessions compound into completing 15-20 full books per year!',
          icon: Icons.verified_rounded,
          accentColor: AppColors.infoBlue,
          badgeText: '$consistencyPercent% Cadence',
        ),
      );
    } else {
      insights.add(
        const ReadingImprovementInsight(
          id: 'insight_consistency_boost',
          type: InsightType.consistency,
          title: 'Build Daily Momentum',
          message: 'Aim for at least 10 minutes every day rather than long, sporadic weekend marathons.',
          tip: 'Leave your active book on your bedside table or phone dock as a visual cue.',
          icon: Icons.flag_rounded,
          accentColor: AppColors.secondaryAmber,
          badgeText: 'Consistency Goal',
        ),
      );
    }

    return insights;
  }

  // ─── Reading Coach Tips ──────────────────────────────────────────────────
  List<ReadingTip> _tips = [];
  List<ReadingTip> get tips => _tips;

  // ─── Initialization (loads persisted data) ────────────────────────────────
  Future<void> initialize() async {
    try {
      String storagePath = '.readsmart_data';
      try {
        final dir = await DatabaseManager().getStorageDirectory();
        if (dir != null) {
          storagePath = '${dir.path}/.readsmart_data';
        }
      } catch (_) {}

      await _db.initialize(storagePath: storagePath, seedDefaults: true);

      // Load books
      _books = await _db.bookRepo.getAllBooks();

      // Load vocabulary collections (book-partitioned)
      final collections = await _db.loadBookVocabularyCollections();
      _bookCollections = {for (final c in collections) c.bookId: c};

      // Load vocabulary (all, memory-cached; repo queries handle isolation)
      final allWords = await _db.loadAllVocabulary();
      _vocabularyNotes
        ..clear()
        ..addAll(allWords);

      // Load reading sessions
      _sessions = await _db.loadAllSessions();
      if (physicalBooks.isNotEmpty) {
        final defaultBook = physicalBooks.first;
        _sessionBookId = defaultBook.id;
        _sessionBookTitle = defaultBook.title;
        _sessionStartPage = defaultBook.currentPage;
      }

      // Load settings
      _statistics = await _db.loadStatistics();
      _languagePreference = await _db.loadLanguagePreference();

      final themeName = await _db.loadTheme();
      _themeMode = ReadingThemeMode.values.firstWhere(
        (t) => t.name == themeName,
        orElse: () => ReadingThemeMode.dark,
      );

      _readerFontSize = await _db.loadFontSize();

      // Load user profile and reading goals
      _user = await _db.settingsRepo.getUser();
      await _loadGoals();

      // Init coaching tips
      _initCoachingTips();
    } catch (e) {
      debugPrint('[AppState] initialize error: $e');
      _initCoachingTips();
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ─── Per-user initialisation & Cloud Sync (called after login) ────────────

  /// Initialise the app for a specific authenticated user.
  /// Each user gets their own completely isolated local storage path,
  /// and cloud synchronization is connected to their verified server session.
  Future<void> initializeForUser({
    required String userId,
    required User authenticatedUser,
    String? authToken,
    ICloudSyncBackend? customBackend,
  }) async {
    _isLoaded = false;
    _user = authenticatedUser;

    try {
      // 1. Setup isolated user local storage directory
      String storagePath = '.readsmart_data/users/$userId';
      try {
        final dir = await DatabaseManager().getStorageDirectory();
        if (dir != null) {
          storagePath = '${dir.path}/.readsmart_data/users/$userId';
        }
      } catch (_) {}

      _db = DatabaseManager.fresh();
      await _db.initialize(storagePath: storagePath, seedDefaults: false);

      // 2. Load this user's local data
      _books = await _db.bookRepo.getAllBooks();

      final collections = await _db.loadBookVocabularyCollections();
      _bookCollections = {for (final c in collections) c.bookId: c};

      final allWords = await _db.loadAllVocabulary();
      _vocabularyNotes
        ..clear()
        ..addAll(allWords);

      _sessions = await _db.loadAllSessions();
      if (physicalBooks.isNotEmpty) {
        final defaultBook = physicalBooks.first;
        _sessionBookId = defaultBook.id;
        _sessionBookTitle = defaultBook.title;
        _sessionStartPage = defaultBook.currentPage;
      } else {
        _sessionBookId = '';
        _sessionBookTitle = '';
        _sessionStartPage = 0;
      }

      _statistics = await _db.loadStatistics();
      _languagePreference = await _db.loadLanguagePreference();

      final themeName = await _db.loadTheme();
      _themeMode = ReadingThemeMode.values.firstWhere(
        (t) => t.name == themeName,
        orElse: () => ReadingThemeMode.dark,
      );

      _readerFontSize = await _db.loadFontSize();

      await _db.settingsRepo.saveUser(authenticatedUser);
      await _loadGoals();
      _initCoachingTips();

      // 3. Resolve authToken if not passed explicitly
      String token = authToken ?? '';
      if (token.isEmpty) {
        try {
          final session = await AuthSessionManager.getSession();
          token = session?['token'] as String? ?? '';
        } catch (_) {}
      }

      // 4. Connect SyncEngine to cloud backend
      if (token.isNotEmpty) {
        final backend = customBackend ?? CloudSyncBackend();
        _syncEngine = SyncEngine(
          backend: backend,
          userId: userId,
          authToken: token,
          onRemoteBookReceived: (book) async {
            await _db.persistBook(book);
            final idx = _books.indexWhere((b) => b.id == book.id);
            if (idx != -1) {
              _books[idx] = book;
            } else {
              _books.add(book);
            }
            notifyListeners();
          },
          onRemoteBookDeleted: (bookId) async {
            await _db.bookRepo.deleteBook(bookId);
            _books.removeWhere((b) => b.id == bookId);
            notifyListeners();
          },
          onRemoteProgressReceived: (remoteProg) async {
            final localProg = await _db.bookRepo.getReadingProgress(remoteProg.bookId);
            final resolved = localProg != null
                ? SyncConflictResolver.resolveReadingProgress(localProg, remoteProg)
                : remoteProg;
            await _db.persistProgress(
              bookId: resolved.bookId,
              currentPage: resolved.currentPage,
              totalPages: resolved.totalPages,
            );
            final bookIdx = _books.indexWhere((b) => b.id == resolved.bookId);
            if (bookIdx != -1) {
              _books[bookIdx] = _books[bookIdx].copyWith(currentPage: resolved.currentPage);
            }
            notifyListeners();
          },
          onRemoteSessionsReceived: (remoteSessions) async {
            final merged = SyncConflictResolver.mergeSessions(_sessions, remoteSessions);
            for (final s in remoteSessions) {
              await _db.sessionRepo.saveSession(s);
            }
            _sessions = merged;
            notifyListeners();
          },
          onRemoteVocabularyReceived: (word) async {
            await _db.persistVocabularyWord(word);
            final idx = _vocabularyNotes.indexWhere((w) => w.id == word.id);
            if (idx != -1) {
              _vocabularyNotes[idx] = word;
            } else {
              _vocabularyNotes.insert(0, word);
            }
            final coll = _bookCollections[word.bookId];
            if (coll != null) {
              coll.addWord(word);
            } else {
              _bookCollections[word.bookId] = BookVocabularyCollection(
                bookId: word.bookId,
                bookTitle: word.bookTitle,
                words: [word],
              );
            }
            notifyListeners();
          },
          onRemoteVocabularyDeleted: (wordId) async {
            await _db.vocabularyRepo.deleteVocabularyWord(wordId);
            _vocabularyNotes.removeWhere((w) => w.id == wordId);
            for (final c in _bookCollections.values) {
              c.words.removeWhere((w) => w.id == wordId);
            }
            notifyListeners();
          },
          onRemoteNoteReceived: (note) async {
            await _db.vocabularyRepo.saveBookNote(note);
            notifyListeners();
          },
          onRemoteNoteDeleted: (noteId) async {
            await _db.vocabularyRepo.deleteBookNote(noteId);
            notifyListeners();
          },
          onRemoteBookmarkReceived: (bm) async {
            await _db.persistBookmark(bm);
            notifyListeners();
          },
          onRemoteBookmarkDeleted: (bmId) async {
            await _db.deleteBookmark(bmId);
            notifyListeners();
          },
          onRemoteStatsReceived: (stats) async {
            _statistics = stats;
            await _db.persistStatistics(stats);
            notifyListeners();
          },
          onRemoteGoalReceived: (goal) async {
            _dailyGoalMinutes = goal.dailyMinutesTarget.clamp(5, 240);
            _annualBooksGoal = goal.annualBooksTarget.clamp(1, 200);
            await _db.settingsRepo.saveGoals(goal);
            notifyListeners();
          },
          onRemotePreferenceReceived: (pref) async {
            _languagePreference = pref;
            await _db.persistLanguagePreference(pref);
            notifyListeners();
          },
        );

        _syncEngine!.addListener(notifyListeners);
        await _syncEngine!.initialize();
      }
    } catch (e) {
      debugPrint('[AppState] initializeForUser error: $e');
      _initCoachingTips();
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// Clears sensitive session information and pending sync queue from memory.
  void logout() {
    _syncEngine?.clear();
    _syncEngine = null;
    _books = [];
    _sessions = [];
    _vocabularyNotes.clear();
    _bookCollections = {};
    _comprehensionLogs = [];
    _tips = [];
    _statistics = ReadingStatistics(
      id: 'stats_default',
      streakDays: 0,
      totalPagesRead: 0,
      totalReadingMinutes: 0,
      booksCompleted: 0,
      averageWpm: 0,
      weeklyWpmHistory: const [0, 0, 0, 0, 0, 0, 0],
      userReadingScore: 0,
    );
    _user = User(
      id: 'user_1',
      name: 'Reader',
      email: '',
      readingLevel: 'Avid Reader',
      avatarInitials: 'R',
      memberSince: 'Member',
    );
    _sessionBookId = '';
    _sessionBookTitle = '';
    _sessionStartPage = 0;
    _isLoaded = false;
    notifyListeners();
  }

  /// Wraps [child] with [AppSignOut] so any descendant can call
  /// `AppSignOut.of(context)?.signOut()` to log out.
  Widget buildWithSignOut({
    required Future<void> Function() signOut,
    required Widget child,
  }) {
    return AppSignOut(signOut: signOut, child: child);
  }

  void _initCoachingTips() {
    _tips = [
      ReadingTip(
        id: 'tip_1',
        title: 'Reading Speed',
        subtitle: '280 WPM • ↑ Improving',
        description:
            'Your speed is 280 WPM. Try using your index finger as a visual guide to increase pace by 10-15%.',
        icon: Icons.bolt,
        accentColor: AppColors.primaryGold,
        badgeText: 'Speed Tip',
      ),
      ReadingTip(
        id: 'tip_guardrail',
        title: 'Comprehension First',
        subtitle: 'Core Reading Rule',
        description:
            'Focus on understanding first — speed without comprehension is lost reading.',
        icon: Icons.psychology,
        accentColor: AppColors.brightFlame,
        badgeText: 'Important Rule',
        isComprehensionGuardrail: true,
      ),
      ReadingTip(
        id: 'tip_2',
        title: 'Comprehension & Summary',
        subtitle: 'Active Mental Retention',
        description:
            'After finishing each chapter, pause for 60 seconds and summarize 3 key points mentally.',
        icon: Icons.auto_stories,
        accentColor: AppColors.infoBlue,
        badgeText: 'Retention',
        actionText: 'Write 3 Key Points',
      ),
      ReadingTip(
        id: 'tip_3',
        title: 'Vocabulary Growth',
        subtitle: '${_vocabularyNotes.length} words saved',
        description:
            'Reviewing your saved vocabulary daily for 5 minutes increases retention by over 80%.',
        icon: Icons.edit_note,
        accentColor: AppColors.purpleAccent,
        badgeText: 'Goal: ${_vocabularyNotes.length}/50 words',
        actionText: 'Review Flashcards',
      ),
      ReadingTip(
        id: 'tip_4',
        title: '25-Min Focus Sprints',
        subtitle: 'Pomodoro Reading Method',
        description:
            'Deep focus deteriorates after 30 minutes. Read in 25-minute sprints with 5-minute breaks.',
        icon: Icons.timer,
        accentColor: AppColors.secondaryAmber,
        badgeText: 'Focus',
        actionText: 'Start Sprint',
      ),
    ];
  }

  // ─── Phase 10: Personalized Reading Coach ──────────────────────────────────
  List<VocabularyWord> get allVocabularyWords => List.unmodifiable(_vocabularyNotes);
  int get totalVocabularyCount => _vocabularyNotes.length;
  int get readingStreakDays => dayStreak;
  int get averageWpm => _statistics.averageWpm;

  int get vocabularySavedTodayCount {
    final now = DateTime.now();
    return _vocabularyNotes.where((w) {
      final s = w.savedAt;
      if (s == null) return false;
      return s.year == now.year &&
          s.month == now.month &&
          s.day == now.day;
    }).length;
  }

  int get vocabularySavedThisWeekCount {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return _vocabularyNotes.where((w) {
      final s = w.savedAt;
      if (s == null) return false;
      return s.isAfter(sevenDaysAgo);
    }).length;
  }

  // Daily Simple Goals
  bool _chapterGoalCompleted = false;
  bool get chapterGoalCompleted => _chapterGoalCompleted;

  void toggleChapterGoalCompleted() {
    _chapterGoalCompleted = !_chapterGoalCompleted;
    notifyListeners();
  }

  List<CoachGoal> get coachGoals {
    final dailyMinutes = (todayReadingSeconds / 60.0);
    final dailyPages = todayPagesRead.toDouble();
    final streak = readingStreakDays.toDouble();
    // Count words saved today or fallback to total words clamped to target
    final vocabLearned = vocabularySavedTodayCount > 0
        ? vocabularySavedTodayCount.toDouble()
        : (_vocabularyNotes.length >= 5 ? 5.0 : _vocabularyNotes.length.toDouble());

    return [
      CoachGoal(
        id: 'goal_minutes',
        type: CoachGoalType.dailyMinutes,
        title: 'Read 20 minutes today',
        description: 'Daily focus compounds into massive long-term retention',
        currentValue: dailyMinutes,
        targetValue: 20.0,
        unit: 'min',
        icon: Icons.timer_outlined,
        accentColor: AppColors.primaryGold,
      ),
      CoachGoal(
        id: 'goal_pages',
        type: CoachGoalType.dailyPages,
        title: 'Read 10 pages today',
        description: 'Steady pacing finishes 20+ books every single year',
        currentValue: dailyPages,
        targetValue: 10.0,
        unit: 'pages',
        icon: Icons.menu_book_rounded,
        accentColor: AppColors.infoBlue,
      ),
      CoachGoal(
        id: 'goal_streak',
        type: CoachGoalType.streak,
        title: 'Maintain a 7-day reading streak',
        description: 'Consistency builds an automatic reading habit',
        currentValue: streak,
        targetValue: 7.0,
        unit: 'days',
        icon: Icons.local_fire_department_rounded,
        accentColor: AppColors.brightFlame,
      ),
      CoachGoal(
        id: 'goal_vocab',
        type: CoachGoalType.vocabulary,
        title: 'Learn 5 new words',
        description: 'Save and review vocabulary from your active reading',
        currentValue: vocabLearned,
        targetValue: 5.0,
        unit: 'words',
        icon: Icons.translate_rounded,
        accentColor: AppColors.purpleAccent,
      ),
      CoachGoal(
        id: 'goal_chapter',
        type: CoachGoalType.finishChapter,
        title: 'Finish a chapter',
        description: 'Complete one narrative or thematic section',
        currentValue: _chapterGoalCompleted ? 1.0 : 0.0,
        targetValue: 1.0,
        unit: 'chapter',
        icon: Icons.bookmark_added_rounded,
        accentColor: AppColors.successGreen,
        manualCompleted: _chapterGoalCompleted,
      ),
    ];
  }

  // Comprehension Assessment Logs
  List<ComprehensionLog> _comprehensionLogs = [];

  List<ComprehensionLog> get comprehensionLogs => List.unmodifiable(_comprehensionLogs);
  ComprehensionLog? get latestComprehensionLog =>
      _comprehensionLogs.isNotEmpty ? _comprehensionLogs.first : null;

  void logComprehensionAssessment({
    required String bookTitle,
    required int ratingStars,
    required String notes,
  }) {
    final score = (ratingStars * 20).clamp(20, 100);
    final log = ComprehensionLog(
      id: 'comp_${DateTime.now().millisecondsSinceEpoch}',
      bookTitle: bookTitle,
      score: score,
      ratingStars: ratingStars,
      notes: notes,
      timestamp: DateTime.now(),
    );
    _comprehensionLogs.insert(0, log);

    // Factor into reading score
    final updatedScore =
        ((userReadingScore * 0.7) + (score * 0.3)).round().clamp(10, 100);
    _statistics = ReadingStatistics(
      id: _statistics.id,
      streakDays: _statistics.streakDays,
      totalPagesRead: _statistics.totalPagesRead,
      totalReadingMinutes: _statistics.totalReadingMinutes,
      booksCompleted: _statistics.booksCompleted,
      averageWpm: _statistics.averageWpm,
      weeklyWpmHistory: _statistics.weeklyWpmHistory,
      userReadingScore: updatedScore,
    );
    notifyListeners();
  }

  // Personalized Recommendation Generator across all 7 categories
  List<CoachRecommendation> generatePersonalizedCoachRecommendations() {
    final recommendations = <CoachRecommendation>[];

    final pph = averagePagesPerHourOverall > 0
        ? averagePagesPerHourOverall.toStringAsFixed(1)
        : '30.0';
    final currentWpm = averageWpm;
    final activeDaysThisWeek =
        getDailyReadingHistory(days: 7).where((r) => r.hasActivity).length;
    final vocabTotal = totalVocabularyCount;
    final vocabWeek = vocabularySavedThisWeekCount;
    final compScore = latestComprehensionLog?.score ?? userReadingScore;

    // 1. IMPROVING READING SPEED (Guaranteed with Comprehension Guardrail)
    recommendations.add(
      CoachRecommendation(
        id: 'rec_speed_pacing',
        category: CoachRecommendationCategory.speed,
        title: 'Calibrated Pacing with Visual Guidance',
        dataEvidence:
            'Data Evidence: Your pace is $currentWpm WPM (~$pph PPH). You maintain smooth reading flow across sessions.',
        recommendation:
            'Use an index finger or stylus as a visual pacer under each line. Pacing guides reduce subconscious regressions (re-reading words) by up to 20% without losing depth.',
        actionLabel: 'Practice Paced Sprint',
        actionType: CoachActionType.startSprint,
        isComprehensionGuardrail: true,
        icon: Icons.speed_rounded,
        accentColor: AppColors.primaryGold,
      ),
    );

    // 2. IMPROVING COMPREHENSION
    recommendations.add(
      CoachRecommendation(
        id: 'rec_comprehension_retention',
        category: CoachRecommendationCategory.comprehension,
        title: 'The 60-Second Feynman Chapter Recap',
        dataEvidence:
            'Data Evidence: Your reader retention score is $compScore%. Pacing without pause risks passive skimming.',
        recommendation:
            'At the end of every chapter, pause for 60 seconds. Mentally summarize the core argument in one clear sentence as if explaining it to a novice. Active recall transforms short-term exposure into lasting memory.',
        actionLabel: 'Log Comprehension Check',
        actionType: CoachActionType.testComprehension,
        icon: Icons.psychology_rounded,
        accentColor: AppColors.infoBlue,
      ),
    );

    // 3. BUILDING READING CONSISTENCY
    recommendations.add(
      CoachRecommendation(
        id: 'rec_consistency_habit',
        category: CoachRecommendationCategory.consistency,
        title: 'Anchor Reading to an Existing Daily Trigger',
        dataEvidence:
            'Data Evidence: You have a $readingStreakDays-day reading streak with $activeDaysThisWeek active days this week.',
        recommendation:
            'Use habit stacking: link reading to a permanent daily anchor (e.g., "Right after my first morning coffee, I will read for 15 minutes"). Micro-consistency beats weekend marathons.',
        actionLabel: 'Read 20 min Today',
        actionType: CoachActionType.startSprint,
        icon: Icons.calendar_today_rounded,
        accentColor: AppColors.brightFlame,
      ),
    );

    // 4. REDUCING DISTRACTIONS
    recommendations.add(
      CoachRecommendation(
        id: 'rec_distractions_focus',
        category: CoachRecommendationCategory.distractions,
        title: 'Friction-Free Reading Environment',
        dataEvidence:
            'Data Evidence: Average session duration is $avgSessionDuration. Cognitive attention begins to fatigue after 20-25 minutes.',
        recommendation:
            'Enable Distraction-Free mode in the PDF reader and place your phone in another room or on airplane mode. Removing micro-interruptions keeps you in uninterrupted flow state.',
        actionLabel: 'Start Focus Sprint',
        actionType: CoachActionType.startSprint,
        icon: Icons.do_not_disturb_on_rounded,
        accentColor: AppColors.secondaryAmber,
      ),
    );

    // 5. EXPANDING VOCABULARY
    recommendations.add(
      CoachRecommendation(
        id: 'rec_vocabulary_growth',
        category: CoachRecommendationCategory.vocabulary,
        title: 'Spaced Retrieval for Saved Vocabulary',
        dataEvidence:
            'Data Evidence: You have $vocabTotal words saved in your book notes ($vocabWeek saved in the past 7 days).',
        recommendation:
            'Spend 5 minutes reviewing your saved book flashcards. Actively retrieving definitions in context converts unfamiliar terminology into working vocabulary 3x faster than passive reading.',
        actionLabel: 'Review Flashcards',
        actionType: CoachActionType.reviewFlashcards,
        icon: Icons.translate_rounded,
        accentColor: AppColors.purpleAccent,
      ),
    );

    // 6. CREATING BETTER READING SESSIONS
    recommendations.add(
      CoachRecommendation(
        id: 'rec_session_quality',
        category: CoachRecommendationCategory.sessionQuality,
        title: 'The 3-Stage Session Architecture',
        dataEvidence:
            'Data Evidence: Your average reading volume is ${averagePagesPerSession.toStringAsFixed(1)} pages per sitting across $booksStartedCount started books.',
        recommendation:
            'Structure each session into 3 parts: 2 minutes previewing section subheadings, 20 minutes deep uninterrupted reading, and 2 minutes jotting margin notes or key insights.',
        actionLabel: 'Start 20m Sprint',
        actionType: CoachActionType.startSprint,
        icon: Icons.timer_outlined,
        accentColor: AppColors.primaryGold,
      ),
    );

    // 7. MAINTAINING HEALTHY READING HABITS
    recommendations.add(
      CoachRecommendation(
        id: 'rec_healthy_habits',
        category: CoachRecommendationCategory.healthyHabits,
        title: 'The 20-20-20 Visual Rest Rule',
        dataEvidence:
            'Data Evidence: Today reading duration: ${readingTimeBreakdown.todayFormatted} across ${todayPagesRead} pages read.',
        recommendation:
            'Every 20 minutes of reading, look at an object 20 feet away for 20 seconds to reset ciliary eye muscles. When reading at night, use Sepia or Dark theme to protect your melatonin and circadian rhythm.',
        actionLabel: 'Open Theme Settings',
        actionType: CoachActionType.openDistractionSettings,
        icon: Icons.spa_rounded,
        accentColor: AppColors.successGreen,
      ),
    );

    return recommendations;
  }
}

