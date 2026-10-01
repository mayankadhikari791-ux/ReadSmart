import '../../data/storage/i_storage_driver.dart';
import '../../models/dictionary_entry_model.dart';

/// Manages multi-tiered caching (in-memory L1 + persistent storage L2)
/// for dictionary and translation lookups.
///
/// Prevents redundant network requests, speeds up repeated queries,
/// and preserves lookups for offline reading sessions.
class DictionaryCacheManager {
  final IStorageDriver? _storage;
  static const String _storageKey = 'cached_dictionary_entries';

  // L1 In-memory cache: "word-targetlang" -> DictionaryEntry
  final Map<String, DictionaryEntry> _memoryCache = {};

  // Rate-limit timestamp tracker: host -> last 429 timestamp
  final Map<String, DateTime> _rateLimitBackoff = {};

  DictionaryCacheManager({IStorageDriver? storage}) : _storage = storage;

  /// Builds a normalized cache key
  String buildKey(String word, String targetLang) {
    final w = word.trim().toLowerCase().replaceAll(RegExp(r'[^\w\s\-]'), '');
    final l = targetLang.trim().toLowerCase();
    return '$w-$l';
  }

  /// Checks L1 memory cache first, then L2 persistent storage
  Future<DictionaryEntry?> get(String word, String targetLang) async {
    final key = buildKey(word, targetLang);

    // 1. L1 Memory Cache
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key];
    }

    // 2. L2 Persistent Storage Driver (if provided)
    if (_storage != null) {
      try {
        final list = await _storage!.readList(_storageKey);
        for (final item in list) {
          if (item['cacheKey'] == key) {
            final entryData = item['entry'] as Map<String, dynamic>?;
            if (entryData != null) {
              final entry = DictionaryEntry.fromJson(entryData);
              _memoryCache[key] = entry; // promote to L1
              return entry;
            }
          }
        }
      } catch (_) {
        // Safe degrade to memory-only
      }
    }

    return null;
  }

  /// Writes entry to L1 memory cache and asynchronously to L2 persistent storage
  Future<void> put(String word, String targetLang, DictionaryEntry entry) async {
    final key = buildKey(word, targetLang);
    _memoryCache[key] = entry;

    if (_storage != null) {
      try {
        final rawList = await _storage!.readList(_storageKey);
        final list = List<Map<String, dynamic>>.from(
          rawList.whereType<Map<String, dynamic>>(),
        );

        // Remove old entry with same key if present
        list.removeWhere((item) => item['cacheKey'] == key);

        // Keep maximum 500 cached words in persistent store
        if (list.length >= 500) {
          list.removeAt(0);
        }

        list.add({
          'cacheKey': key,
          'word': entry.word,
          'targetLang': targetLang,
          'timestamp': DateTime.now().toIso8601String(),
          'entry': entry.toJson(),
        });

        await _storage!.writeList(_storageKey, list);
      } catch (_) {
        // Storage failure should never crash the dictionary
      }
    }
  }

  /// Checks if an API host is currently in a 429 rate-limit backoff period (60 seconds)
  bool isRateLimited(String host) {
    final backoffUntil = _rateLimitBackoff[host];
    if (backoffUntil == null) return false;
    if (DateTime.now().isAfter(backoffUntil)) {
      _rateLimitBackoff.remove(host);
      return false;
    }
    return true;
  }

  /// Registers a 429 Too Many Requests response for a host
  void recordRateLimit(String host, {Duration duration = const Duration(seconds: 45)}) {
    _rateLimitBackoff[host] = DateTime.now().add(duration);
  }

  /// Clears in-memory cache
  void clearMemory() {
    _memoryCache.clear();
    _rateLimitBackoff.clear();
  }

  /// Number of entries currently cached in memory
  int get memoryCount => _memoryCache.length;
}

