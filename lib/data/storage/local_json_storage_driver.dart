import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'i_storage_driver.dart';

class LocalJsonStorageDriver implements IStorageDriver {
  final String baseDirectoryPath;
  Directory? _baseDir;
  final Map<String, dynamic> _memoryCache = {};

  LocalJsonStorageDriver({String? path})
      : baseDirectoryPath = path ?? '.readsmart_data';

  @override
  Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      _baseDir = Directory(baseDirectoryPath);
      if (!await _baseDir!.exists()) {
        await _baseDir!.create(recursive: true);
      }
    } catch (_) {
      try {
        final fallback = Directory('${Directory.systemTemp.path}/.readsmart_data');
        if (!await fallback.exists()) {
          await fallback.create(recursive: true);
        }
        _baseDir = fallback;
      } catch (_) {}
    }
  }

  File? _getFile(String name) {
    if (kIsWeb || _baseDir == null) return null;
    final sanitized = name.replaceAll(RegExp(r'[^\w\-]'), '_');
    return File('${_baseDir!.path}/$sanitized.json');
  }

  @override
  Future<List<Map<String, dynamic>>> readList(String collectionName) async {
    if (_memoryCache.containsKey(collectionName)) {
      return List<Map<String, dynamic>>.from(_memoryCache[collectionName]);
    }

    if (kIsWeb || _baseDir == null) {
      _memoryCache[collectionName] = <Map<String, dynamic>>[];
      return [];
    }

    try {
      final file = _getFile(collectionName);
      if (file == null || !await file.exists()) {
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
    if (kIsWeb || _baseDir == null) return;
    try {
      final file = _getFile(collectionName);
      if (file != null) {
        final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
        await file.writeAsString(jsonStr, flush: true);
      }
    } catch (e) {
      // Graceful fallback for environments with restricted filesystem
    }
  }

  @override
  Future<Map<String, dynamic>?> readMap(String documentName) async {
    if (_memoryCache.containsKey(documentName)) {
      return Map<String, dynamic>.from(_memoryCache[documentName]);
    }

    if (kIsWeb || _baseDir == null) return null;

    try {
      final file = _getFile(documentName);
      if (file == null || !await file.exists()) return null;

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
    if (kIsWeb || _baseDir == null) return;
    try {
      final file = _getFile(documentName);
      if (file != null) {
        final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
        await file.writeAsString(jsonStr, flush: true);
      }
    } catch (e) {
      // Graceful fallback
    }
  }

  @override
  Future<void> delete(String key) async {
    _memoryCache.remove(key);
    if (kIsWeb || _baseDir == null) return;
    try {
      final file = _getFile(key);
      if (file != null && await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore
    }
  }
}
