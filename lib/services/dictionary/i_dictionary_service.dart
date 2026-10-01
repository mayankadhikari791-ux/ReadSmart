import 'package:read_smart/models/dictionary_entry_model.dart';

/// Clean service abstraction for Dictionary and Translation providers.
///
/// Implementations can call Free Dictionary API, Oxford, Webster, or AI models
/// without requiring any modifications to UI widgets.
abstract class IDictionaryService {
  /// Looks up a word, its definitions, parts of speech, phonetics, and
  /// translations in the requested [targetLanguage] (defaults to 'hi' for Hindi).
  Future<DictionaryResult> lookupWord(
    String word, {
    String targetLanguage = 'hi',
  });

  /// Translates short text or definitions from [fromLang] to [toLang].
  Future<String?> translateText(
    String text, {
    required String fromLang,
    required String toLang,
  });

  /// Pronounces the given [word] using the provided [audioUrl] or speech synthesis.
  Future<void> pronounce(String word, {String? audioUrl});
}

