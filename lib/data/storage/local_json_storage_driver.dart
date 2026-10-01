import 'dart:convert';
import 'dart:io';
import 'i_storage_driver.dart';

class LocalJsonStorageDriver implements IStorageDriver {
  final String baseDirectoryPath;
  late final Directory _baseDir;
  final Map<String, dynamic> _memoryCache = {};

  LocalJsonStorageDriver({String? path})
      : baseDirectoryPath = path ?? '.readsmart_data';

  @override
  Future<void> initialize() async {
    _baseDir = Directory(baseDirectoryPath);
    if (!await _baseDir.exists()) {
      await _baseDir.create(recursive: true);
    }
  }

  File _getFile(String name) {
    final sanitized = name.replaceAll(RegExp(r'[^\w\-]'), '_');
    return File('${_baseDir.path}/$sanitized.json');
  }

  @override
  Future<List<Map<String, dynamic>>> readList(String collectionName) async {
    if (_memoryCache.containsKey(collectionName)) {
      return List<Map<String, dynamic>>.from(_memoryCache[collectionName]);
    }

    try {
      final file = _getFile(collectionName);
      if (!await file.exists()) {
        _memoryCache[collectionName] = <Map<String, dynamic>>[];
        return [];
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        _memoryCache[collectionName] = <Map<String, dynamic>>[];
        return [];
      }

      final decoded = jsonDecode(content);
      if (decoded is List) {
        final list = decoded
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        _memoryCache[collectionName] = list;
        return list;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> writeList(
      String collectionName, List<Map<String, dynamic>> data) async {
    _memoryCache[collectionName] = data;
    try {
      final file = _getFile(collectionName);
      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
      await file.writeAsString(jsonStr, flush: true);
    } catch (e) {
      // Graceful fallback for environments with restricted filesystem
    }
  }

  @override
  Future<Map<String, dynamic>?> readMap(String documentName) async {
    if (_memoryCache.containsKey(documentName)) {
      return Map<String, dynamic>.from(_memoryCache[documentName]);
    }

    try {
      final file = _getFile(documentName);
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      if (content.trim().isEmpty) return null;

      final decoded = jsonDecode(content);
      if (decoded is Map) {
        final map = Map<String, dynamic>.from(decoded);
        _memoryCache[documentName] = map;
        return map;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> writeMap(
      String documentName, Map<String, dynamic> data) async {
    _memoryCache[documentName] = data;
    try {
      final file = _getFile(documentName);
      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
      await file.writeAsString(jsonStr, flush: true);
    } catch (e) {
      // Graceful fallback
    }
  }

  @override
  Future<void> delete(String key) async {
    _memoryCache.remove(key);
    try {
      final file = _getFile(key);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore
    }
  }
}
