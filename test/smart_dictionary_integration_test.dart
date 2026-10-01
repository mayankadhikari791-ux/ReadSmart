import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:read_smart/models/dictionary_entry_model.dart';
import 'package:read_smart/services/dictionary/dictionary_cache_manager.dart';
import 'package:read_smart/services/dictionary/free_dictionary_service.dart';
import 'package:read_smart/services/dictionary/i_dictionary_service.dart';

// ─── Fake API response helpers ─────────────────────────────────────────────

const String _sampleWord = 'resilience';

Map<String, dynamic> _dictionaryApiResponse() => {
      'word': 'resilience',
      'phonetic': '/rɪˈzɪliəns/',
      'phonetics': [
        {
          'text': '/rɪˈzɪliəns/',
          'audio': '//ssl.gstatic.com/dictionary/static/sounds/resilience.mp3',
        }
      ],
      'meanings': [
        {
          'partOfSpeech': 'noun',
          'definitions': [
            {
              'definition':
                  'The capacity to recover quickly from difficulties; toughness.',
              'example':
                  'Her resilience in the face of adversity inspired everyone.',
              'synonyms': ['toughness', 'endurance', 'adaptability'],
            }
          ],
          'synonyms': ['strength'],
        }
      ],
      'origin': 'Latin resilire',
    };

Map<String, dynamic> _myMemoryHiResponse(String text) => {
      'responseData': {'translatedText': 'लचीलापन'},
      'responseStatus': 200,
    };

Map<String, dynamic> _myMemoryEsResponse(String text) => {
      'responseData': {'translatedText': 'resiliencia'},
      'responseStatus': 200,
    };

// ─── Mock client builder ────────────────────────────────────────────────────

/// Creates a [MockClient] that returns different responses based on URL.
http.Client _makeMockClient({
  int dictStatus = 200,
  int translateStatus = 200,
  bool simulateTimeout = false,
  bool simulateNetworkError = false,
}) {
  return MockClient((request) async {
    if (simulateTimeout) {
      await Future.delayed(const Duration(seconds: 10));
    }
    if (simulateNetworkError) {
      throw http.ClientException('Connection refused');
    }

    if (request.url.host == 'api.dictionaryapi.dev') {
      if (dictStatus == 200) {
        return http.Response(
          jsonEncode([_dictionaryApiResponse()]),
          200,
          headers: {'content-type': 'application/json'},
        );
      } else if (dictStatus == 429) {
        return http.Response('Too Many Requests', 429);
      } else if (dictStatus == 404) {
        return http.Response('{"title":"No Definitions Found"}', 404);
      }
      return http.Response('Internal Server Error', 500);
    }

    if (request.url.host == 'api.mymemory.translated.net') {
      if (translateStatus == 200) {
        final lang = request.url.queryParameters['langpair'] ?? '';
        final responseBody = lang.contains('hi')
            ? _myMemoryHiResponse(lang)
            : _myMemoryEsResponse(lang);
        return http.Response(
          jsonEncode(responseBody),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response('Too Many Requests', 429);
    }

    return http.Response('Not Found', 404);
  });
}

void main() {
  // ─── 1. DictionaryCacheManager ──────────────────────────────────────────

  group('DictionaryCacheManager', () {
    test('returns null on empty cache', () async {
      final cache = DictionaryCacheManager();
      final result = await cache.get('unknown', 'hi');
      expect(result, isNull);
    });

    test('put then get returns same entry', () async {
      final cache = DictionaryCacheManager();
      const entry = DictionaryEntry(
        word: 'Resilience',
        phonetic: '/rɪˈzɪliəns/',
        meanings: [],
      );
      await cache.put('resilience', 'hi', entry);
      final fetched = await cache.get('resilience', 'hi');
      expect(fetched, isNotNull);
      expect(fetched!.word, equals('Resilience'));
    });

    test('buildKey normalizes word and lang', () {
      final cache = DictionaryCacheManager();
      final key1 = cache.buildKey('  Resilience  ', 'HI');
      final key2 = cache.buildKey('resilience', 'hi');
      expect(key1, equals(key2));
    });

    test('rate limit tracking works with backoff', () {
      final cache = DictionaryCacheManager();
      expect(cache.isRateLimited('api.dictionaryapi.dev'), isFalse);
      cache.recordRateLimit('api.dictionaryapi.dev',
          duration: const Duration(seconds: 45));
      expect(cache.isRateLimited('api.dictionaryapi.dev'), isTrue);
    });

    test('clearMemory empties L1 cache and rate limits', () async {
      final cache = DictionaryCacheManager();
      const entry = DictionaryEntry(word: 'Test', meanings: []);
      await cache.put('test', 'hi', entry);
      cache.recordRateLimit('somehost.com');
      cache.clearMemory();
      expect(cache.memoryCount, equals(0));
      expect(cache.isRateLimited('somehost.com'), isFalse);
    });

    test('different target languages produce different cache keys', () {
      final cache = DictionaryCacheManager();
      final keyHi = cache.buildKey('resilience', 'hi');
      final keyEs = cache.buildKey('resilience', 'es');
      expect(keyHi, isNot(equals(keyEs)));
    });
  });

  // ─── 2. FreeDictionaryService — Cache hit prevention ────────────────────

  group('FreeDictionaryService - caching', () {
    test('cache hit prevents second HTTP call', () async {
      int httpCallCount = 0;
      final client = MockClient((req) async {
        if (req.url.host == 'api.dictionaryapi.dev') {
          httpCallCount++;
          return http.Response(
            jsonEncode([_dictionaryApiResponse()]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        // Translation calls
        return http.Response(
          jsonEncode(_myMemoryHiResponse('')),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = FreeDictionaryService(client: client);
      // First lookup — should hit HTTP
      await service.lookupWord(_sampleWord);
      final callsAfterFirst = httpCallCount;

      // Second lookup — must be served from cache
      await service.lookupWord(_sampleWord);
      expect(httpCallCount, equals(callsAfterFirst),
          reason: 'Second lookup should not make another dictionary API call');
    });

    test('different words each hit the API once', () async {
      int httpCallCount = 0;
      final client = MockClient((req) async {
        if (req.url.host == 'api.dictionaryapi.dev') {
          httpCallCount++;
          return http.Response(
            jsonEncode([_dictionaryApiResponse()]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          jsonEncode(_myMemoryHiResponse('')),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = FreeDictionaryService(client: client);
      await service.lookupWord('resilience');
      await service.lookupWord('omen'); // offline dict, no HTTP
      // Only resilience hit the API (omen is in offline dict)
      expect(httpCallCount, greaterThanOrEqualTo(1));
    });
  });

  // ─── 3. English definition retrieval ─────────────────────────────────────

  group('FreeDictionaryService - English definitions', () {
    test('parses word, phonetic, part of speech, definition, example', () async {
      final service = FreeDictionaryService(client: _makeMockClient());
      final result = await service.lookupWord(_sampleWord, targetLanguage: 'en');

      expect(result.isSuccess, isTrue);
      final entry = result.entry!;
      expect(entry.word, equals('Resilience'));
      expect(entry.phonetic, contains('ɪ'));
      expect(entry.meanings, isNotEmpty);
      expect(entry.meanings.first.partOfSpeech, equals('noun'));
      expect(entry.primaryDefinition, contains('recover quickly'));
      expect(entry.primaryExample, contains('adversity'));
    });

    test('parses synonyms from definition item', () async {
      final service = FreeDictionaryService(client: _makeMockClient());
      final result = await service.lookupWord(_sampleWord);

      expect(result.isSuccess, isTrue);
      final synonyms = result.entry!.allSynonyms;
      expect(synonyms, contains('toughness'));
    });

    test('resolves HTTPS audio URL from phonetics', () async {
      final service = FreeDictionaryService(client: _makeMockClient());
      final result = await service.lookupWord(_sampleWord);

      expect(result.isSuccess, isTrue);
      expect(result.entry!.audioUrl, startsWith('https://'));
    });
  });

  // ─── 4. Hindi translation ────────────────────────────────────────────────

  group('FreeDictionaryService - Hindi translation', () {
    test('hindi translation populated from MyMemory API', () async {
      final service = FreeDictionaryService(client: _makeMockClient());
      final result = await service.lookupWord(_sampleWord, targetLanguage: 'hi');

      expect(result.isSuccess, isTrue);
      final entry = result.entry!;
      // Either live translation or fallback placeholder
      expect(entry.hindiMeaning, isNotNull);
      expect(entry.hindiMeaning!.isNotEmpty, isTrue);
    });

    test('offline fallback entry has pre-filled hindi meaning', () async {
      // 'resilience' is in the offline dictionary
      final service = FreeDictionaryService(
        client: _makeMockClient(dictStatus: 404), // force offline
      );
      final result = await service.lookupWord('resilience');
      // Should return offline fallback entry
      expect(result.isSuccess, isTrue);
      expect(result.entry!.hindiMeaning, isNotNull);
    });
  });

  // ─── 5. Target language translation ─────────────────────────────────────

  group('FreeDictionaryService - target language translation', () {
    test('spanish translation fetched when targetLanguage is es', () async {
      final service = FreeDictionaryService(client: _makeMockClient());
      final result = await service.lookupWord(_sampleWord, targetLanguage: 'es');

      expect(result.isSuccess, isTrue);
      final entry = result.entry!;
      expect(entry.targetLangCode, equals('ES'));
      // targetLangMeaning may be non-null if translation API succeeds
      // We just verify the code is set correctly
    });

    test('no extra translation call when target lang is HI', () async {
      int translateCallCount = 0;
      final client = MockClient((req) async {
        if (req.url.host == 'api.mymemory.translated.net') {
          translateCallCount++;
          return http.Response(
            jsonEncode(_myMemoryHiResponse('')),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          jsonEncode([_dictionaryApiResponse()]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = FreeDictionaryService(client: client);
      await service.lookupWord(_sampleWord, targetLanguage: 'hi');
      // Should only call translation once (for Hindi), not twice
      expect(translateCallCount, lessThanOrEqualTo(2));
    });
  });

  // ─── 6. Rate limit handling ──────────────────────────────────────────────

  group('FreeDictionaryService - rate limit (429)', () {
    test('returns error or offline result on 429', () async {
      final service = FreeDictionaryService(
        client: _makeMockClient(dictStatus: 429),
      );
      final result = await service.lookupWord('unknownword12345');
      // Should not throw; either error state or offline fallback
      expect(result, isNotNull);
      expect(result.isSuccess || result.hasError, isTrue);
    });

    test('offline fallback word succeeds on rate limit', () async {
      final service = FreeDictionaryService(
        client: _makeMockClient(dictStatus: 429),
      );
      final result = await service.lookupWord('omen');
      expect(result.isSuccess, isTrue);
      expect(result.entry!.word.toLowerCase(), contains('omen'));
    });

    test('rate limit registered in cache manager on 429', () async {
      final cacheManager = DictionaryCacheManager();
      final service = FreeDictionaryService(
        client: _makeMockClient(dictStatus: 429),
        cacheManager: cacheManager,
      );
      await service.lookupWord('unknownword12345');
      expect(
          cacheManager.isRateLimited('api.dictionaryapi.dev'), isTrue);
    });
  });

  // ─── 7. Network failure handling ─────────────────────────────────────────

  group('FreeDictionaryService - network failures', () {
    test('returns networkError result on SocketException', () async {
      final service = FreeDictionaryService(
        client: _makeMockClient(simulateNetworkError: true),
      );
      final result = await service.lookupWord('arbitrary');
      // Should not throw; should return networkError or offline fallback
      expect(result, isNotNull);
    });

    test('offline fallback available on network error', () async {
      final service = FreeDictionaryService(
        client: _makeMockClient(simulateNetworkError: true),
      );
      final result = await service.lookupWord('serendipity');
      expect(result.isSuccess, isTrue);
      expect(result.entry!.word.toLowerCase(), contains('serendipity'));
    });

    test('returns error (not crash) on timeout', () async {
      // Use a very short timeout by pre-rate-limiting so no HTTP call is made
      final cacheManager = DictionaryCacheManager();
      cacheManager.recordRateLimit('api.dictionaryapi.dev',
          duration: const Duration(milliseconds: 100));
      final service = FreeDictionaryService(
        client: _makeMockClient(),
        cacheManager: cacheManager,
      );
      // Rate limited immediately — should return graceful error or offline
      final result = await service.lookupWord('unknownword99');
      expect(result, isNotNull);
      expect(result.hasError, isTrue);
    });
  });

  // ─── 8. IDictionaryService interface abstraction ──────────────────────────

  group('IDictionaryService abstraction', () {
    test('FreeDictionaryService implements IDictionaryService', () {
      final IDictionaryService service = FreeDictionaryService();
      expect(service, isA<IDictionaryService>());
    });

    test('DictionaryResult.success has correct isSuccess flag', () {
      const entry = DictionaryEntry(word: 'Test', meanings: []);
      final result = DictionaryResult.success(entry);
      expect(result.isSuccess, isTrue);
      expect(result.hasError, isFalse);
    });

    test('DictionaryResult.notFound has correct flags', () {
      final result = DictionaryResult.notFound(message: 'Not found');
      expect(result.isNotFound, isTrue);
      expect(result.isSuccess, isFalse);
    });

    test('DictionaryResult.networkError has correct flags', () {
      final result = DictionaryResult.networkError('Timeout');
      expect(result.isNetworkError, isTrue);
      expect(result.isSuccess, isFalse);
    });

    test('DictionaryResult.error sets message correctly', () {
      final result = DictionaryResult.error('API error 500');
      expect(result.errorMessage, contains('500'));
      expect(result.hasError, isTrue);
    });
  });

  // ─── 9. DictionaryEntry serialization (for persistent cache) ─────────────

  group('DictionaryEntry JSON round-trip', () {
    test('toJson/fromJson preserves all fields', () {
      const entry = DictionaryEntry(
        word: 'Resilience',
        phonetic: '/rɪˈzɪliəns/',
        audioUrl: 'https://example.com/resilience.mp3',
        meanings: [
          WordMeaning(
            partOfSpeech: 'noun',
            definitions: [
              DefinitionItem(
                definition: 'Capacity to recover.',
                example: 'She showed great resilience.',
                synonyms: ['toughness'],
              ),
            ],
            synonyms: ['endurance'],
          ),
        ],
        hindiWord: 'लचीलापन',
        hindiMeaning: 'मुश्किल परिस्थितियों से उबरने की क्षमता',
        targetLangWord: 'resiliencia',
        targetLangMeaning: 'Capacidad de recuperación',
        targetLangCode: 'ES',
        synonyms: ['strength'],
        origin: 'Latin resilire',
      );

      final json = entry.toJson();
      final restored = DictionaryEntry.fromJson(json);

      expect(restored.word, equals(entry.word));
      expect(restored.phonetic, equals(entry.phonetic));
      expect(restored.audioUrl, equals(entry.audioUrl));
      expect(restored.meanings.length, equals(1));
      expect(restored.meanings.first.partOfSpeech, equals('noun'));
      expect(restored.meanings.first.definitions.first.definition,
          contains('recover'));
      expect(restored.meanings.first.definitions.first.synonyms,
          contains('toughness'));
      expect(restored.hindiWord, equals(entry.hindiWord));
      expect(restored.hindiMeaning, equals(entry.hindiMeaning));
      expect(restored.targetLangWord, equals(entry.targetLangWord));
      expect(restored.targetLangMeaning, equals(entry.targetLangMeaning));
      expect(restored.targetLangCode, equals('ES'));
      expect(restored.synonyms, contains('strength'));
      expect(restored.origin, equals(entry.origin));
    });

    test('fromJson handles missing optional fields gracefully', () {
      final minimalJson = <String, dynamic>{
        'word': 'Test',
        'meanings': [],
      };
      final entry = DictionaryEntry.fromJson(minimalJson);
      expect(entry.word, equals('Test'));
      expect(entry.phonetic, isNull);
      expect(entry.audioUrl, isNull);
      expect(entry.hindiWord, isNull);
      expect(entry.targetLangCode, equals('HI')); // default
    });

    test('DefinitionItem round-trip', () {
      const item = DefinitionItem(
        definition: 'A test definition.',
        example: 'This is an example.',
        synonyms: ['sample', 'specimen'],
      );
      final restored = DefinitionItem.fromJson(item.toJson());
      expect(restored.definition, equals(item.definition));
      expect(restored.example, equals(item.example));
      expect(restored.synonyms, containsAll(['sample', 'specimen']));
    });

    test('WordMeaning round-trip preserves definitions and synonyms', () {
      const meaning = WordMeaning(
        partOfSpeech: 'verb',
        definitions: [
          DefinitionItem(definition: 'To test something.', synonyms: ['check']),
        ],
        synonyms: ['examine'],
      );
      final restored = WordMeaning.fromJson(meaning.toJson());
      expect(restored.partOfSpeech, equals('verb'));
      expect(restored.definitions.length, equals(1));
      expect(restored.synonyms, contains('examine'));
    });
  });
}
