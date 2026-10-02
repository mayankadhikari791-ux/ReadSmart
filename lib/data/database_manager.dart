import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/book_model.dart';
import '../models/reading_progress_model.dart';
import '../models/reading_session_model.dart';
import '../models/vocabulary_word_model.dart';
import '../models/book_vocabulary_collection_model.dart';
import '../models/bookmark_model.dart';
import '../models/reading_statistics_model.dart';
import '../models/language_preference_model.dart';
import 'repositories/i_book_repository.dart';
import 'repositories/i_vocabulary_repository.dart';
import 'repositories/i_session_repository.dart';
import 'repositories/i_settings_repository.dart';
import 'repositories/local/local_book_repository.dart';
import 'repositories/local/local_vocabulary_repository.dart';
import 'repositories/local/local_session_repository.dart';
import 'repositories/local/local_settings_repository.dart';
import 'storage/local_json_storage_driver.dart';
import '../core/config/app_config.dart';
import '../services/auth/i_auth_service.dart';
import '../services/auth/mock_auth_service.dart';
import '../services/dictionary/i_dictionary_service.dart';
import '../services/dictionary/free_dictionary_service.dart';
import '../services/dictionary/proxy_dictionary_service.dart';
import '../services/dictionary/dictionary_cache_manager.dart';
import 'repositories/sync/offline_first_book_repository.dart';

/// Central coordinator for all persistent data access.
/// All UI state reads and writes are routed through DatabaseManager,
/// which delegates to the appropriate repository.
///
/// To swap the storage backend (e.g., Firebase Firestore, Supabase),
/// replace the repository instances below. No UI changes needed.
class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._internal();
  factory DatabaseManager() => _instance;
  factory DatabaseManager.fresh() => DatabaseManager._internal();
  DatabaseManager._internal();

  late final IBookRepository bookRepo;
  late final IVocabularyRepository vocabularyRepo;
  late final ISessionRepository sessionRepo;
  late final ISettingsRepository settingsRepo;
  late final IAuthService authService;
  late final IDictionaryService dictionaryService;

  bool _initialized = false;

  Future<Directory?> getStorageDirectory() async {
    try {
      return await getApplicationDocumentsDirectory().timeout(
        const Duration(seconds: 2),
        onTimeout: () => Directory.systemTemp,
      );
    } catch (_) {
      try {
        return Directory.systemTemp;
      } catch (_) {
        return null;
      }
    }
  }

  // ─── Initialization ──────────────────────────────────────────────────────

  Future<void> initialize({
    String? storagePath,
    IAuthService? customAuth,
    IDictionaryService? customDictionary,
    bool seedDefaults = true,
  }) async {
    if (_initialized) return;

    final driver = LocalJsonStorageDriver(path: storagePath ?? '.readsmart_data');
    await driver.initialize();

    final localBookRepo = LocalBookRepository(driver);
    bookRepo = OfflineFirstBookRepository(localRepo: localBookRepo);
    vocabularyRepo = LocalVocabularyRepository(driver);
    sessionRepo = LocalSessionRepository(driver);
    settingsRepo = LocalSettingsRepository(driver);
    authService = customAuth ?? MockAuthService();

    final cacheMgr = DictionaryCacheManager(storage: driver);
    if (customDictionary != null) {
      dictionaryService = customDictionary;
    } else if (AppConfig.useDictionaryProxy && AppConfig.dictionaryProxyUrl.isNotEmpty) {
      dictionaryService = ProxyDictionaryService(cacheManager: cacheMgr);
    } else {
      dictionaryService = FreeDictionaryService(cacheManager: cacheMgr);
    }

    if (seedDefaults) {
      try {
        await _seedDefaultDataIfEmpty();
      } catch (e) {
        debugPrint('[DatabaseManager] Seed default data warning: $e');
      }
    }
    _initialized = true;
  }

  // ─── Seed default library on first run ──────────────────────────────────

  Future<void> _seedDefaultDataIfEmpty() async {
    final existing = await bookRepo.getAllBooks();
    if (existing.isNotEmpty) return;

    final now = DateTime.now();
    final defaultBooks = [
      Book(
        id: 'book_1',
        title: 'The Alchemist',
        author: 'Paulo Coelho',
        totalPages: 250,
        currentPage: 167,
        format: BookFormat.ebook,
        status: BookStatus.reading,
        lastReadTime: '2h ago',
        lastOpenedAt: now.subtract(const Duration(hours: 2)),
        coverGradient: const [Color(0xFFE8A020), Color(0xFF78350F)],
        rating: 4.9,
      ),
      Book(
        id: 'book_2',
        title: 'Atomic Habits',
        author: 'James Clear',
        totalPages: 320,
        currentPage: 144,
        format: BookFormat.ebook,
        status: BookStatus.reading,
        lastReadTime: 'Yesterday',
        lastOpenedAt: now.subtract(const Duration(days: 1)),
        coverGradient: const [Color(0xFF0284C7), Color(0xFF0F172A)],
        rating: 4.9,
      ),
      Book(
        id: 'book_3',
        title: 'Sapiens: A Brief History',
        author: 'Yuval Noah Harari',
        totalPages: 498,
        currentPage: 115,
        format: BookFormat.physical,
        status: BookStatus.reading,
        lastReadTime: '3 days ago',
        lastOpenedAt: now.subtract(const Duration(days: 3)),
        coverGradient: const [Color(0xFF7C3AED), Color(0xFF1E1B4B)],
        rating: 4.8,
      ),
      Book(
        id: 'book_4',
        title: 'Deep Work',
        author: 'Cal Newport',
        totalPages: 304,
        currentPage: 0,
        format: BookFormat.ebook,
        status: BookStatus.saved,
        lastReadTime: 'Not started',
        coverGradient: const [Color(0xFF0D9488), Color(0xFF134E4A)],
        rating: 4.7,
      ),
      Book(
        id: 'book_5',
        title: 'The Psychology of Money',
        author: 'Morgan Housel',
        totalPages: 252,
        currentPage: 252,
        format: BookFormat.ebook,
        status: BookStatus.completed,
        lastReadTime: 'Completed Sep 5',
        lastOpenedAt: now.subtract(const Duration(days: 5)),
        coverGradient: const [Color(0xFF059669), Color(0xFF064E3B)],
        rating: 5.0,
      ),
      Book(
        id: 'book_6',
        title: "Man's Search for Meaning",
        author: 'Viktor E. Frankl',
        totalPages: 200,
        currentPage: 200,
        format: BookFormat.physical,
        status: BookStatus.completed,
        lastReadTime: 'Completed Aug 28',
        lastOpenedAt: now.subtract(const Duration(days: 10)),
        coverGradient: const [Color(0xFFD97706), Color(0xFF451A03)],
        rating: 4.9,
      ),
      Book(
        id: 'book_7',
        title: 'Thinking, Fast and Slow',
        author: 'Daniel Kahneman',
        totalPages: 499,
        currentPage: 0,
        format: BookFormat.physical,
        status: BookStatus.saved,
        lastReadTime: 'Want to Read',
        coverGradient: const [Color(0xFF6366F1), Color(0xFF312E81)],
        rating: 4.8,
      ),
      Book(
        id: 'book_8',
        title: 'Clean Code: Handbook of Agile Software',
        author: 'Robert C. Martin',
        totalPages: 464,
        currentPage: 52,
        format: BookFormat.ebook,
        status: BookStatus.reading,
        lastReadTime: '4h ago',
        lastOpenedAt: now.subtract(const Duration(hours: 4)),
        coverGradient: const [Color(0xFF2563EB), Color(0xFF1E3A8A)],
        rating: 4.9,
        filePath: 'assets/sample.pdf',
      ),
    ];

    for (final book in defaultBooks) {
      await bookRepo.saveBook(book);
    }

    // Seed initial reading progress
    for (final book in defaultBooks) {
      if (book.currentPage > 0) {
        await bookRepo.updateReadingProgress(ReadingProgress(
          id: 'progress_${book.id}',
          bookId: book.id,
          currentPage: book.currentPage,
          totalPages: book.totalPages,
          progressPercentage: book.progressPercentage,
          lastReadTimestamp: DateTime.now(),
        ));
      }
    }

    // Seed vocabulary — strictly book-scoped
    final seedVocab = [
      // The Alchemist (book_1)
      VocabularyWord(
        id: 'vocab_1',
        bookId: 'book_1',
        bookTitle: 'The Alchemist',
        word: 'Omens',
        pronunciation: '/ˈoʊmənz/',
        englishMeaning: 'Signs regarded as portents of future events.',
        hindiWord: 'शकुन',
        hindiMeaning: 'भविष्य की घटनाओं का पूर्व संकेत या शुभ/अशुभ लक्षण',
        exampleSentence: '"You will have to follow the omens."',
        dateSaved: '14 Sep 2026',
        cefrLevel: 'CEFR B2',
        pageNumber: 167,
      ),
      VocabularyWord(
        id: 'vocab_2',
        bookId: 'book_1',
        bookTitle: 'The Alchemist',
        word: 'Transmutation',
        pronunciation: '/ˌtrænzmjuːˈteɪʃn/',
        englishMeaning: 'The action of changing into another form or state.',
        hindiWord: 'रूपांतरण',
        hindiMeaning: 'एक पदार्थ या अवस्था से दूसरी अवस्था में परिवर्तन',
        exampleSentence: '"Lead suffers its own transmutation until it becomes pure gold."',
        dateSaved: '10 Sep 2026',
        cefrLevel: 'CEFR C1',
        pageNumber: 155,
      ),
      VocabularyWord(
        id: 'vocab_3',
        bookId: 'book_1',
        bookTitle: 'The Alchemist',
        word: 'Alchemist',
        pronunciation: '/ˈælkəmɪst/',
        englishMeaning: 'A practitioner of alchemy; one who transforms substances.',
        hindiWord: 'कीमियागर',
        hindiMeaning: 'रसायनशास्त्री या पारस पत्थर खोजने वाला दार्शनिक',
        exampleSentence: '"He turned toward the alchemist, who nodded in understanding."',
        dateSaved: '12 Sep 2026',
        cefrLevel: 'CEFR C1',
        pageNumber: 142,
      ),
      // Atomic Habits (book_2) — separate vocabulary, never mixed with book_1
      VocabularyWord(
        id: 'vocab_4',
        bookId: 'book_2',
        bookTitle: 'Atomic Habits',
        word: 'Cue',
        pronunciation: '/kjuː/',
        englishMeaning: 'A sensory trigger that initiates a habit loop.',
        hindiWord: 'संकेत',
        hindiMeaning: 'आदत को शुरू करने वाला दृश्य या मानसिक ट्रिगर',
        exampleSentence: '"Every habit begins with a cue that predicts a reward."',
        dateSaved: '8 Sep 2026',
        cefrLevel: 'CEFR B1',
        pageNumber: 48,
      ),
      VocabularyWord(
        id: 'vocab_5',
        bookId: 'book_2',
        bookTitle: 'Atomic Habits',
        word: 'Latent Potential',
        pronunciation: '/ˈleɪtnt pəˈtenʃl/',
        englishMeaning: 'Accumulated effort stored below the threshold of visible results.',
        hindiWord: 'प्रसुप्त क्षमता',
        hindiMeaning: 'भीतर छिपी हुई शक्ति जो समय के साथ प्रकट होती है',
        exampleSentence: '"Work stored in the plateau of latent potential will eventually explode."',
        dateSaved: '5 Sep 2026',
        cefrLevel: 'CEFR B2',
        pageNumber: 72,
      ),
    ];

    for (final word in seedVocab) {
      await vocabularyRepo.saveVocabularyWord(word);
    }

    // Seed a sample reading session
    await sessionRepo.saveSession(ReadingSession(
      id: 'session_1',
      bookId: 'book_1',
      bookTitle: 'The Alchemist',
      durationSeconds: 2100,
      pagesRead: 28,
      readingSpeedWpm: 280,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ));
  }

  // ─── Convenience Helpers (used by AppState) ──────────────────────────────

  Future<void> persistBook(Book book) => bookRepo.saveBook(book);

  Future<void> deleteBook(String bookId) => bookRepo.deleteBook(bookId);

  Future<void> persistProgress({
    required String bookId,
    required int currentPage,
    required int totalPages,
  }) =>
      bookRepo.updateReadingProgress(ReadingProgress(
        id: 'progress_$bookId',
        bookId: bookId,
        currentPage: currentPage,
        totalPages: totalPages,
        progressPercentage:
            totalPages > 0 ? currentPage / totalPages : 0.0,
        lastReadTimestamp: DateTime.now(),
      ));

  Future<void> persistVocabularyWord(VocabularyWord word) =>
      vocabularyRepo.saveVocabularyWord(word);

  Future<void> updateVocabularyWord(VocabularyWord word) =>
      vocabularyRepo.updateVocabularyWord(word);

  Future<void> deleteVocabularyWord(String wordId) =>
      vocabularyRepo.deleteVocabularyWord(wordId);

  Future<List<VocabularyWord>> loadVocabularyForBook(String bookId) =>
      vocabularyRepo.getVocabularyForBook(bookId);

  Future<List<VocabularyWord>> loadAllVocabulary() =>
      vocabularyRepo.getAllVocabulary();

  Future<List<BookVocabularyCollection>> loadBookVocabularyCollections() =>
      vocabularyRepo.getBookVocabularyCollections();

  Future<void> persistSession(ReadingSession session) =>
      sessionRepo.saveSession(session);

  Future<List<ReadingSession>> loadAllSessions() =>
      sessionRepo.getAllSessions();

  Future<void> clearAllSessions() => sessionRepo.clearAllSessions();

  Future<List<ReadingSession>> loadSessionsForBook(String bookId) =>
      sessionRepo.getSessionsForBook(bookId);

  Future<ReadingStatistics> loadStatistics() =>
      settingsRepo.getStatistics();

  Future<void> persistStatistics(ReadingStatistics stats) =>
      settingsRepo.saveStatistics(stats);

  Future<void> persistTheme(String theme) =>
      settingsRepo.saveThemePreference(theme);

  Future<String> loadTheme() => settingsRepo.getThemePreference();

  Future<void> persistFontSize(double size) =>
      settingsRepo.saveFontSizePreference(size);

  Future<double> loadFontSize() => settingsRepo.getFontSizePreference();

  Future<LanguagePreference> loadLanguagePreference() =>
      settingsRepo.getLanguagePreference();

  Future<void> persistLanguagePreference(LanguagePreference pref) =>
      settingsRepo.saveLanguagePreference(pref);

  Future<void> persistBookmark(Bookmark bookmark) =>
      bookRepo.saveBookmark(bookmark);

  Future<void> deleteBookmark(String bookmarkId) =>
      bookRepo.deleteBookmark(bookmarkId);
}
