import 'package:read_smart/models/vocabulary_word_model.dart';
import 'package:read_smart/models/book_vocabulary_collection_model.dart';
import 'package:read_smart/models/book_note_model.dart';
import '../i_vocabulary_repository.dart';
import '../../storage/i_storage_driver.dart';

class LocalVocabularyRepository implements IVocabularyRepository {
  final IStorageDriver _storage;

  static const String _vocabKey = 'vocabulary_words';
  static const String _notesKey = 'book_notes';

  LocalVocabularyRepository(this._storage);

  // ─── Vocabulary Words ────────────────────────────────────────────────────

  @override
  Future<List<VocabularyWord>> getAllVocabulary() async {
    final raw = await _storage.readList(_vocabKey);
    return raw.map(VocabularyWord.fromJson).toList();
  }

  /// CRITICAL: returns ONLY words where word.bookId == bookId
  /// A word saved in Book A will NEVER appear when querying Book B.
  @override
  Future<List<VocabularyWord>> getVocabularyForBook(String bookId) async {
    final all = await getAllVocabulary();
    return all.where((w) => w.bookId == bookId).toList();
  }

  /// Returns partitioned collections isolated by bookId
  @override
  Future<List<BookVocabularyCollection>> getBookVocabularyCollections() async {
    final all = await getAllVocabulary();
    final Map<String, BookVocabularyCollection> map = {};
    for (final w in all) {
      if (!map.containsKey(w.bookId)) {
        map[w.bookId] = BookVocabularyCollection(
          bookId: w.bookId,
          bookTitle: w.bookTitle,
          words: [],
          lastUpdated: w.savedAt ?? DateTime.now(),
        );
      }
      map[w.bookId]!.words.add(w);
    }
    return map.values.toList();
  }

  @override
  Future<void> saveVocabularyWord(VocabularyWord word) async {
    assert(word.bookId.isNotEmpty, 'bookId must be set before saving a vocabulary word');
    assert(word.id.isNotEmpty, 'id must be set before saving a vocabulary word');

    final all = await getAllVocabulary();

    // Allow duplicate word text across different books (by design)
    // but prevent exact duplicate within the SAME book
    final duplicateInSameBook = all.any(
      (w) => w.bookId == word.bookId &&
             w.word.trim().toLowerCase() == word.word.trim().toLowerCase(),
    );
    if (duplicateInSameBook) return;

    all.insert(0, word);
    await _storage.writeList(_vocabKey, all.map((w) => w.toJson()).toList());
  }

  @override
  Future<void> updateVocabularyWord(VocabularyWord word) async {
    assert(word.bookId.isNotEmpty, 'bookId must be set before updating a vocabulary word');
    final all = await getAllVocabulary();
    final index = all.indexWhere((w) => w.id == word.id);
    if (index != -1) {
      all[index] = word;
      await _storage.writeList(_vocabKey, all.map((w) => w.toJson()).toList());
    }
  }

  @override
  Future<void> deleteVocabularyWord(String wordId) async {
    final all = await getAllVocabulary();
    all.removeWhere((w) => w.id == wordId);
    await _storage.writeList(_vocabKey, all.map((w) => w.toJson()).toList());
  }

  // ─── Book Notes ──────────────────────────────────────────────────────────

  @override
  Future<List<BookNote>> getNotesForBook(String bookId) async {
    final all = await _getAllNotes();
    return all.where((n) => n.bookId == bookId).toList();
  }

  @override
  Future<void> saveBookNote(BookNote note) async {
    final all = await _getAllNotes();
    final index = all.indexWhere((n) => n.id == note.id);
    if (index == -1) {
      all.insert(0, note);
    } else {
      all[index] = note;
    }
    await _storage.writeList(_notesKey, all.map((n) => n.toJson()).toList());
  }

  @override
  Future<void> deleteBookNote(String noteId) async {
    final all = await _getAllNotes();
    all.removeWhere((n) => n.id == noteId);
    await _storage.writeList(_notesKey, all.map((n) => n.toJson()).toList());
  }

  Future<List<BookNote>> _getAllNotes() async {
    final raw = await _storage.readList(_notesKey);
    return raw.map(BookNote.fromJson).toList();
  }
}
