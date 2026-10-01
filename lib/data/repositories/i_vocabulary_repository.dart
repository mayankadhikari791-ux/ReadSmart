import '../../models/vocabulary_word_model.dart';
import '../../models/book_vocabulary_collection_model.dart';
import '../../models/book_note_model.dart';

abstract class IVocabularyRepository {
  /// Strictly returns only vocabulary words saved under the given [bookId]
  Future<List<VocabularyWord>> getVocabularyForBook(String bookId);

  /// Returns all saved vocabulary words across all books
  Future<List<VocabularyWord>> getAllVocabulary();

  /// Returns all isolated book vocabulary collections
  Future<List<BookVocabularyCollection>> getBookVocabularyCollections();

  /// Permanently saves a vocabulary word under its associated [bookId]
  Future<void> saveVocabularyWord(VocabularyWord word);

  /// Updates an existing vocabulary word's definition, translation, or user notes
  Future<void> updateVocabularyWord(VocabularyWord word);

  /// Deletes a vocabulary word by unique ID
  Future<void> deleteVocabularyWord(String wordId);

  /// Returns freeform notes for a specific book
  Future<List<BookNote>> getNotesForBook(String bookId);

  /// Saves a freeform note for a specific book
  Future<void> saveBookNote(BookNote note);

  /// Deletes a freeform note
  Future<void> deleteBookNote(String noteId);
}
