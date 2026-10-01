abstract class IStorageDriver {
  Future<void> initialize();
  Future<List<Map<String, dynamic>>> readList(String collectionName);
  Future<void> writeList(String collectionName, List<Map<String, dynamic>> data);
  Future<Map<String, dynamic>?> readMap(String documentName);
  Future<void> writeMap(String documentName, Map<String, dynamic> data);
  Future<void> delete(String key);
}
