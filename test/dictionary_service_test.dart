import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:read_smart/models/dictionary_entry_model.dart';
import 'package:read_smart/services/dictionary/free_dictionary_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FreeDictionaryService Unit Tests', () {
    test('Offline dictionary fallback works for common terms', () async {
      final service = FreeDictionaryService(
        client: MockClient((request) async {
          return http.Response('{"title": "No Definitions Found"}', 404);
        }),
      );

      final result = await service.lookupWord('serendipity');

      expect(result.isSuccess, isTrue);
      expect(result.entry, isNotNull);
      expect(result.entry!.word.toLowerCase(), equals('serendipity'));
      expect(result.entry!.primaryPartOfSpeech, equals('noun'));
      expect(result.entry!.primaryDefinition, contains('chance'));
      expect(result.entry!.hindiWord, contains('सौभाग्य'));
      expect(result.entry!.hindiMeaning, isNotEmpty);
      expect(result.entry!.allSynonyms, isNotEmpty);
    });

    test('Parses live Dictionary API response correctly', () async {
      const mockApiResponse = '''[
        {
          "word": "epiphany",
          "phonetic": "/ɪˈpɪfəni/",
          "phonetics": [
            {"text": "/ɪˈpɪfəni/", "audio": "https://api.dictionaryapi.dev/media/pronunciations/en/epiphany-us.mp3"}
          ],
          "meanings": [
            {
              "partOfSpeech": "noun",
              "definitions": [
                {
                  "definition": "A moment of sudden and profound revelation or insight.",
                  "example": "He had an epiphany that changed the course of his life.",
                  "synonyms": ["revelation", "insight", "realization"]
                }
              ],
              "synonyms": ["revelation"]
            }
          ]
        }
      ]''';

      const mockTranslationResponse = '''{
        "responseData": {
          "translatedText": "आत्मज्ञान / रहस्योद्घाटन"
        }
      }''';

      final service = FreeDictionaryService(
        client: MockClient((request) async {
          if (request.url.toString().contains('dictionaryapi.dev')) {
            return http.Response(
              mockApiResponse,
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );
          }
          if (request.url.toString().contains('mymemory')) {
            return http.Response(
              mockTranslationResponse,
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );
          }
          return http.Response('Not Found', 404);
        }),
      );

      final result = await service.lookupWord('epiphany', targetLanguage: 'hi');

      expect(result.isSuccess, isTrue);
      final entry = result.entry!;
      expect(entry.word, equals('Epiphany'));
      expect(entry.phonetic, equals('/ɪˈpɪfəni/'));
      expect(entry.audioUrl, equals('https://api.dictionaryapi.dev/media/pronunciations/en/epiphany-us.mp3'));
      expect(entry.primaryPartOfSpeech, equals('noun'));
      expect(entry.primaryDefinition, contains('revelation'));
      expect(entry.primaryExample, contains('changed the course'));
      expect(entry.allSynonyms, contains('revelation'));
      expect(entry.allSynonyms, contains('insight'));
    });

    test('Handles unknown words gracefully with suggestions and notFound status', () async {
      final service = FreeDictionaryService(
        client: MockClient((request) async {
          return http.Response(
            '{"title": "No Definitions Found", "message": "Sorry pal, couldn\'t find definitions for the word you were looking for."}',
            404,
          );
        }),
      );

      final result = await service.lookupWord('xyznonexistentwords');

      expect(result.isNotFound, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('xyznonexistentwords'));
      expect(result.suggestions, isNotEmpty); // suggestions should offer stemmed version
    });

    test('Handles network connection errors gracefully', () async {
      final service = FreeDictionaryService(
        client: MockClient((request) async {
          throw http.ClientException('Connection failed');
        }),
      );

      final result = await service.lookupWord('uniquewordnevercached123');

      expect(result.hasError, isTrue);
      expect(result.entry, isNull);
    });

    test('Multiple parts of speech are aggregated and filtered correctly', () {
      const entry = DictionaryEntry(
        word: 'Run',
        phonetic: '/rʌn/',
        meanings: [
          WordMeaning(
            partOfSpeech: 'verb',
            definitions: [
              DefinitionItem(definition: 'Move at a speed faster than a walk.'),
            ],
          ),
          WordMeaning(
            partOfSpeech: 'noun',
            definitions: [
              DefinitionItem(definition: 'An act or spell of running.'),
            ],
          ),
        ],
      );

      expect(entry.allPartsOfSpeech, contains('verb'));
      expect(entry.allPartsOfSpeech, contains('noun'));
      expect(entry.definitionsForPartOfSpeech('verb').first.definition, contains('faster than a walk'));
      expect(entry.definitionsForPartOfSpeech('noun').first.definition, contains('spell of running'));
    });
  });
}
