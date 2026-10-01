import 'vocabulary_word_model.dart';

/// Represents a distinct, book-isolated collection of vocabulary notes.
///
/// Guaranteed to contain only vocabulary items belonging to [bookId].
/// Enforces isolation at the data-model level to prevent cross-contamination
/// between different books.
class BookVocabularyCollection {
  final String bookId;
  final String bookTitle;
  final List<VocabularyWord> words;
  DateTime lastUpdated;

  BookVocabularyCollection({
    required this.bookId,
    required this.bookTitle,
    required List<VocabularyWord> words,
    DateTime? lastUpdated,
  })  : words = List.from(words),
        lastUpdated = lastUpdated ?? DateTime.now();

  int get wordsCount => words.length;

  /// Returns sorted unique list of page numbers where vocabulary was found
  List<int> get pagesReferenced {
    final pages = words.map((w) => w.pageNumber).toSet().toList();
    pages.sort();
    return pages;
  }

  /// Filters words saved on a specific page
  List<VocabularyWord> wordsForPage(int page) {
    return words.where((w) => w.pageNumber == page).toList();
  }

  /// Searches words, meanings, examples, and user notes
  List<VocabularyWord> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List.unmodifiable(words);
    return words.where((w) {
      return w.word.toLowerCase().contains(q) ||
          w.englishMeaning.toLowerCase().contains(q) ||
          w.hindiMeaning.toLowerCase().contains(q) ||
          w.hindiWord.toLowerCase().contains(q) ||
          w.exampleSentence.toLowerCase().contains(q) ||
          (w.userNote != null && w.userNote!.toLowerCase().contains(q)) ||
          (w.selectedLangMeaning != null &&
              w.selectedLangMeaning!.toLowerCase().contains(q));
    }).toList();
  }

  /// Adds a word ensuring it belongs to this book and avoids duplicates
  void addWord(VocabularyWord word) {
    assert(word.bookId == bookId,
        'Cannot add word with bookId "${word.bookId}" to collection for "$bookId"');

    final exists = words.any(
        (w) => w.word.trim().toLowerCase() == word.word.trim().toLowerCase());
    if (!exists) {
      words.insert(0, word);
      lastUpdated = DateTime.now();
    }
  }

  /// Updates an existing word in the collection
  void updateWord(VocabularyWord updatedWord) {
    assert(updatedWord.bookId == bookId,
        'Cannot update word with bookId "${updatedWord.bookId}" in collection for "$bookId"');

    final index = words.indexWhere((w) => w.id == updatedWord.id);
    if (index != -1) {
      words[index] = updatedWord;
      lastUpdated = DateTime.now();
    }
  }

  /// Removes a word by ID
  void removeWord(String wordId) {
    words.removeWhere((w) => w.id == wordId);
    lastUpdated = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'words': words.map((w) => w.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory BookVocabularyCollection.fromJson(Map<String, dynamic> json) {
    final rawWords = (json['words'] as List<dynamic>?) ?? [];
    return BookVocabularyCollection(
      bookId: json['bookId'] as String,
      bookTitle: json['bookTitle'] as String? ?? 'Untitled Book',
      words: rawWords
          .map((w) => VocabularyWord.fromJson(w as Map<String, dynamic>))
          .toList(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String)
          : null,
    );
  }
}

