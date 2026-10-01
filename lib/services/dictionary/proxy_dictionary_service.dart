import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';
import '../../models/dictionary_entry_model.dart';
import 'dictionary_cache_manager.dart';
import 'i_dictionary_service.dart';

/// Implementation of [IDictionaryService] that routes requests through a
/// secure backend proxy server.
///
/// Ensures private API keys and upstream credentials are never exposed in
/// client-side source code.
class ProxyDictionaryService implements IDictionaryService {
  final http.Client _client;
  final String _proxyBaseUrl;
  final String _translationProxyUrl;
  final DictionaryCacheManager _cacheManager;

  ProxyDictionaryService({
    http.Client? client,
    String? proxyBaseUrl,
    String? translationProxyUrl,
    DictionaryCacheManager? cacheManager,
  })  : _client = client ?? http.Client(),
        _proxyBaseUrl = proxyBaseUrl ?? AppConfig.dictionaryProxyUrl,
        _translationProxyUrl =
            translationProxyUrl ?? AppConfig.translationProxyUrl,
        _cacheManager = cacheManager ?? DictionaryCacheManager();

  @override
  Future<DictionaryResult> lookupWord(
    String word, {
    String targetLanguage = 'hi',
  }) async {
    final cleaned = word.trim().toLowerCase().replaceAll(RegExp(r'[^\w\s\-]'), '');
    if (cleaned.isEmpty) {
      return DictionaryResult.notFound(message: 'Please select a valid word.');
    }

    // 1. Check local/tiered cache first
    final cached = await _cacheManager.get(cleaned, targetLanguage);
    if (cached != null) {
      return DictionaryResult.success(cached);
    }

    // 2. Rate limit check for proxy host
    final proxyHost = Uri.parse(_proxyBaseUrl).host;
    if (_cacheManager.isRateLimited(proxyHost)) {
      return DictionaryResult.error(
        'Dictionary requests temporarily limited by server. Using local backup.',
      );
    }

    // 3. Request via secure backend proxy
    try {
      final uri = Uri.parse('$_proxyBaseUrl/$cleaned').replace(
        queryParameters: {'lang': targetLanguage.toLowerCase()},
      );

      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'X-Client-Key': AppConfig.apiKey,
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final entry = DictionaryEntry.fromJson(data);
        await _cacheManager.put(cleaned, targetLanguage, entry);
        return DictionaryResult.success(entry);
      } else if (response.statusCode == 429) {
        _cacheManager.recordRateLimit(proxyHost);
        return DictionaryResult.error(
          'Dictionary service rate limit reached. Please wait a moment before trying again.',
        );
      } else if (response.statusCode == 404) {
        return DictionaryResult.notFound(
          message: 'No definitions found for "$word".',
        );
      } else {
        return DictionaryResult.error(
          'Proxy returned status ${response.statusCode}.',
        );
      }
    } on SocketException {
      return DictionaryResult.networkError(
        'No network connection to dictionary proxy.',
      );
    } on TimeoutException {
      return DictionaryResult.networkError(
        'Dictionary proxy timed out. Please retry.',
      );
    } catch (e) {
      return DictionaryResult.error('Proxy lookup error: ${e.toString()}');
    }
  }

  @override
  Future<String?> translateText(
    String text, {
    required String fromLang,
    required String toLang,
  }) async {
    if (text.trim().isEmpty) return null;
    try {
      final uri = Uri.parse(_translationProxyUrl);
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-Client-Key': AppConfig.apiKey,
        },
        body: jsonEncode({
          'text': text.trim(),
          'from': fromLang,
          'to': toLang,
        }),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['translatedText'] as String?;
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> pronounce(String word, {String? audioUrl}) async {
    await SystemSound.play(SystemSoundType.click);
  }
}

