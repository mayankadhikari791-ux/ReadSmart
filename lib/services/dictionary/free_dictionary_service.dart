import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:read_smart/models/dictionary_entry_model.dart';
import 'dictionary_cache_manager.dart';
import 'i_dictionary_service.dart';

/// Implementation of [IDictionaryService] using the Free Dictionary API
/// (api.dictionaryapi.dev) and the MyMemory Translation API.
///
/// Features:
/// - Multi-tiered caching (checks in-memory & persistent cache first)
/// - Asynchronous, non-blocking HTTP requests
/// - English definitions, Hindi meaning, and user's selected language meaning
/// - Graceful rate-limit (HTTP 429) backoff handling
/// - Robust offline fallback dictionary for common literary terms
/// - Audio URL resolution and phonetic feedback
class FreeDictionaryService implements IDictionaryService {
  final http.Client _client;
  final DictionaryCacheManager _cacheManager;

  FreeDictionaryService({
    http.Client? client,
    DictionaryCacheManager? cacheManager,
  })  : _client = client ?? http.Client(),
        _cacheManager = cacheManager ?? DictionaryCacheManager();

  DictionaryCacheManager get cacheManager => _cacheManager;

  // Offline vocabulary fallback cache for when device has no internet
  static final Map<String, DictionaryEntry> _offlineDictionary = {
    'omen': const DictionaryEntry(
      word: 'Omen',
      phonetic: '/ˈoʊmən/',
      meanings: [
        WordMeaning(
          partOfSpeech: 'noun',
          definitions: [
            DefinitionItem(
              definition:
                  'An event regarded as a portent of good or evil; a prophetic sign.',
              example:
                  'The sudden appearance of the hawk was regarded as a favorable omen.',
              synonyms: ['portent', 'presage', 'sign', 'harbinger'],
            ),
          ],
          synonyms: ['sign', 'harbinger'],
        ),
      ],
      hindiWord: 'शकुन / पूर्वसंकेत',
      hindiMeaning: 'भविष्य की शुभ या अशुभ घटना का संकेत',
      synonyms: ['portent', 'sign', 'presage'],
    ),
    'alchemist': const DictionaryEntry(
      word: 'Alchemist',
      phonetic: '/ˈælkəmɪst/',
      meanings: [
        WordMeaning(
          partOfSpeech: 'noun',
          definitions: [
            DefinitionItem(
              definition:
                  'A person who practices alchemy, seeking to transform base metals into gold or find a universal elixir.',
              example:
                  'The alchemist spent decades searching for the Philosopher’s Stone.',
              synonyms: ['transmuter', 'sorcerer', 'philosopher'],
            ),
          ],
        ),
      ],
      hindiWord: 'कीमियागर',
      hindiMeaning: 'पारस पत्थर खोजने वाला या धातुओं को बदलने वाला साधक',
      synonyms: ['transmuter', 'philosopher'],
    ),
    'serendipity': const DictionaryEntry(
      word: 'Serendipity',
      phonetic: '/ˌsɛrənˈdɪpɪti/',
      meanings: [
        WordMeaning(
          partOfSpeech: 'noun',
          definitions: [
            DefinitionItem(
              definition:
                  'The occurrence of events by chance in a happy or beneficial way.',
              example:
                  'Finding her favorite book in the old shop was pure serendipity.',
              synonyms: ['chance', 'fortune', 'fluke', 'luck'],
            ),
          ],
        ),
      ],
      hindiWord: 'सौभाग्य / अप्रत्याशित लाभ',
      hindiMeaning: 'अचानक सुखद संयोग से प्राप्त होने वाली सफलता या खोज',
      synonyms: ['fortune', 'luck', 'chance'],
    ),
    'resilience': const DictionaryEntry(
      word: 'Resilience',
      phonetic: '/rɪˈzɪliəns/',
      meanings: [
        WordMeaning(
          partOfSpeech: 'noun',
          definitions: [
            DefinitionItem(
              definition:
                  'The capacity to recover quickly from difficulties; toughness.',
              example:
                  'Her resilience in the face of adversity inspired everyone around her.',
              synonyms: ['toughness', 'flexibility', 'endurance'],
            ),
          ],
        ),
      ],
      hindiWord: 'लचीलापन / सहनशक्ति',
      hindiMeaning: 'मुश्किल परिस्थितियों से शीघ्र उबरने की क्षमता',
      synonyms: ['endurance', 'strength', 'grit'],
    ),
    'solitude': const DictionaryEntry(
      word: 'Solitude',
      phonetic: '/ˈsɑːlətuːd/',
      meanings: [
        WordMeaning(
          partOfSpeech: 'noun',
          definitions: [
            DefinitionItem(
              definition:
                  'The state or situation of being alone, especially when peaceful or pleasant.',
              example:
                  'He enjoyed the solitude of his quiet morning walk in the forest.',
              synonyms: ['seclusion', 'isolation', 'peace'],
            ),
          ],
        ),
      ],
      hindiWord: 'एकांत',
      hindiMeaning: 'शांतिपूर्ण अकेलापन या ध्यानमग्न अवस्था',
      synonyms: ['seclusion', 'privacy', 'peace'],
    ),
    'ephemeral': const DictionaryEntry(
      word: 'Ephemeral',
      phonetic: '/ɪˈfɛmərəl/',
      meanings: [
        WordMeaning(
          partOfSpeech: 'adjective',
          definitions: [
            DefinitionItem(
              definition: 'Lasting for a very short time; transitory; fleeting.',
              example: 'The ephemeral beauty of youth and summer blossoms.',
              synonyms: ['transitory', 'fleeting', 'short-lived', 'momentary'],
            ),
          ],
          synonyms: ['fleeting', 'transitory'],
        ),
      ],
      hindiWord: 'क्षणिक / अल्पकालिक',
      hindiMeaning: 'बहुत कम समय के लिए रहने वाला, क्षणभंगुर',
      synonyms: ['transitory', 'fleeting', 'momentary'],
    ),
  };

  @override
  Future<DictionaryResult> lookupWord(
    String word, {
    String targetLanguage = 'hi',
  }) async {
    final cleaned = word.trim().toLowerCase().replaceAll(RegExp(r'[^\w\s\-]'), '');
    if (cleaned.isEmpty) {
      return DictionaryResult.notFound(message: 'Please select or enter a valid word.');
    }

    // 1. Check local/tiered cache first
    final cached = await _cacheManager.get(cleaned, targetLanguage);
    if (cached != null) {
      return DictionaryResult.success(cached);
    }

    // 2. Rate-limit check
    const host = 'api.dictionaryapi.dev';
    if (_cacheManager.isRateLimited(host)) {
      if (_offlineDictionary.containsKey(cleaned)) {
        return DictionaryResult.success(_offlineDictionary[cleaned]!);
      }
      return DictionaryResult.error(
        'Dictionary requests currently rate-limited. Please wait 30 seconds.',
      );
    }

    // 3. Request live API
    try {
      final uri = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$cleaned');
      final response = await _client.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final entryData = data.first as Map<String, dynamic>;
          final parsedEntry = _parseDictionaryApiJson(entryData, cleaned);

          // Retrieve translation (Hindi and target language)
          final translated = await _enrichWithTranslation(
            parsedEntry,
            targetLanguage: targetLanguage,
          );

          await _cacheManager.put(cleaned, targetLanguage, translated);
          return DictionaryResult.success(translated);
        }
      } else if (response.statusCode == 429) {
        // Rate limited by API
        _cacheManager.recordRateLimit(host);
        if (_offlineDictionary.containsKey(cleaned)) {
          final fallback = _offlineDictionary[cleaned]!;
          await _cacheManager.put(cleaned, targetLanguage, fallback);
          return DictionaryResult.success(fallback);
        }
        return DictionaryResult.error(
          'API rate limit reached. Please wait a moment before looking up new words.',
        );
      } else if (response.statusCode == 404) {
        // Word not found online: check offline fallback first
        if (_offlineDictionary.containsKey(cleaned)) {
          final fallback = _offlineDictionary[cleaned]!;
          await _cacheManager.put(cleaned, targetLanguage, fallback);
          return DictionaryResult.success(fallback);
        }

        return DictionaryResult.notFound(
          message: 'No definitions found for "$word".',
          suggestions: _generateSpellingSuggestions(cleaned),
        );
      } else {
        // Other HTTP status
        if (_offlineDictionary.containsKey(cleaned)) {
          return DictionaryResult.success(_offlineDictionary[cleaned]!);
        }
        return DictionaryResult.error(
          'Dictionary service responded with status ${response.statusCode}.',
        );
      }
    } on SocketException catch (_) {
      // Offline / No Internet
      if (_offlineDictionary.containsKey(cleaned)) {
        return DictionaryResult.success(_offlineDictionary[cleaned]!);
      }
      return DictionaryResult.networkError(
        'No internet connection. Please verify your network to look up new words.',
      );
    } on TimeoutException catch (_) {
      // Timeout
      if (_offlineDictionary.containsKey(cleaned)) {
        return DictionaryResult.success(_offlineDictionary[cleaned]!);
      }
      return DictionaryResult.networkError(
        'Dictionary lookup timed out. Please retry in a moment.',
      );
    } catch (e) {
      // Fallback
      if (_offlineDictionary.containsKey(cleaned)) {
        return DictionaryResult.success(_offlineDictionary[cleaned]!);
      }
      return DictionaryResult.error('Failed to look up word: ${e.toString()}');
    }

    return DictionaryResult.notFound(message: 'Definition not found.');
  }

  /// Parses raw JSON from Free Dictionary API into [DictionaryEntry]
  DictionaryEntry _parseDictionaryApiJson(
    Map<String, dynamic> json,
    String requestedWord,
  ) {
    final rawWord = json['word'] as String? ?? requestedWord;
    final capitalized = rawWord.isNotEmpty
        ? rawWord[0].toUpperCase() + rawWord.substring(1)
        : rawWord;

    // Resolve phonetic
    String? phonetic = json['phonetic'] as String?;
    String? audioUrl;

    final phoneticsList = json['phonetics'] as List<dynamic>?;
    if (phoneticsList != null && phoneticsList.isNotEmpty) {
      for (final p in phoneticsList) {
        if (p is Map<String, dynamic>) {
          if (phonetic == null || phonetic.isEmpty) {
            phonetic = p['text'] as String?;
          }
          final audio = p['audio'] as String?;
          if (audio != null && audio.isNotEmpty && audio.endsWith('.mp3')) {
            audioUrl ??= audio.startsWith('//') ? 'https:$audio' : audio;
          }
        }
      }
    }

    phonetic ??= '/$requestedWord/';

    // Resolve meanings & parts of speech
    final meaningsList = <WordMeaning>[];
    final rawMeanings = json['meanings'] as List<dynamic>?;
    if (rawMeanings != null) {
      for (final m in rawMeanings) {
        if (m is Map<String, dynamic>) {
          meaningsList.add(WordMeaning.fromJson(m));
        }
      }
    }

    // Top-level origin / source
    final origin = json['origin'] as String?;

    return DictionaryEntry(
      word: capitalized,
      phonetic: phonetic,
      audioUrl: audioUrl,
      meanings: meaningsList,
      origin: origin,
    );
  }

  /// Enriches the dictionary entry with translations for Hindi AND the currently selected target language
  Future<DictionaryEntry> _enrichWithTranslation(
    DictionaryEntry entry, {
    required String targetLanguage,
  }) async {
    String? hindiMeaning = entry.hindiMeaning;
    String? hindiWord = entry.hindiWord;
    String? targetMeaning = entry.targetLangMeaning;
    String? targetWord = entry.targetLangWord;

    try {
      // 1. Fetch Hindi translation if missing
      if (hindiMeaning == null || hindiMeaning.isEmpty) {
        final hiRes = await translateText(
          entry.primaryDefinition,
          fromLang: 'en',
          toLang: 'hi',
        );
        final hiWordRes = await translateText(
          entry.word,
          fromLang: 'en',
          toLang: 'hi',
        );
        hindiMeaning = hiRes;
        hindiWord = hiWordRes;
      }

      // 2. Fetch specific target language translation if different from Hindi/English
      final targetLower = targetLanguage.toLowerCase();
      if (targetLower != 'hi' && targetLower != 'en' && targetLower.isNotEmpty) {
        targetMeaning = await translateText(
          entry.primaryDefinition,
          fromLang: 'en',
          toLang: targetLower,
        );
        targetWord = await translateText(
          entry.word,
          fromLang: 'en',
          toLang: targetLower,
        );
      }
    } catch (_) {
      // Non-blocking: failure in translation should never break dictionary display
    }

    return entry.copyWith(
      hindiWord: hindiWord ?? 'भावार्थ',
      hindiMeaning: hindiMeaning ?? 'अनुवाद उपलब्ध नहीं है।',
      targetLangWord: targetWord,
      targetLangMeaning: targetMeaning,
      targetLangCode: targetLanguage.toUpperCase(),
    );
  }

  @override
  Future<String?> translateText(
    String text, {
    required String fromLang,
    required String toLang,
  }) async {
    if (text.trim().isEmpty) return null;
    const host = 'api.mymemory.translated.net';
    if (_cacheManager.isRateLimited(host)) return null;

    try {
      final query = Uri.encodeComponent(text.trim());
      final uri = Uri.parse(
        'https://api.mymemory.translated.net/get?q=$query&langpair=$fromLang|$toLang',
      );

      final response = await _client.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final responseData = data['responseData'] as Map<String, dynamic>?;
        if (responseData != null) {
          final translated = responseData['translatedText'] as String?;
          if (translated != null && translated.isNotEmpty) {
            return translated;
          }
        }
      } else if (response.statusCode == 429) {
        _cacheManager.recordRateLimit(host);
      }
    } catch (_) {
      // Return null on failure gracefully
    }
    return null;
  }

  @override
  Future<void> pronounce(String word, {String? audioUrl}) async {
    // Play system click / sound feedback to acknowledge request
    await SystemSound.play(SystemSoundType.click);
  }

  List<String> _generateSpellingSuggestions(String word) {
    if (word.length <= 3) return const [];
    final suggestions = <String>{};
    if (word.endsWith('s') && word.length > 3) {
      suggestions.add(word.substring(0, word.length - 1));
    }
    if (word.endsWith('ed') && word.length > 4) {
      suggestions.add(word.substring(0, word.length - 2));
    }
    if (word.endsWith('ing') && word.length > 5) {
      suggestions.add(word.substring(0, word.length - 3));
    }
    return suggestions.toList();
  }
}
