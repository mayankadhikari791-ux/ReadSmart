import 'package:read_smart/models/reading_session_model.dart';
import '../i_session_repository.dart';
import '../../storage/i_storage_driver.dart';

class LocalSessionRepository implements ISessionRepository {
  final IStorageDriver _storage;

  static const String _sessionsKey = 'reading_sessions';

  LocalSessionRepository(this._storage);

  @override
  Future<List<ReadingSession>> getAllSessions() async {
    final raw = await _storage.readList(_sessionsKey);
    return raw.map(ReadingSession.fromJson).toList();
  }

  @override
  Future<List<ReadingSession>> getSessionsForBook(String bookId) async {
    final all = await getAllSessions();
    return all.where((s) => s.bookId == bookId).toList();
  }

  @override
  Future<void> saveSession(ReadingSession session) async {
    final all = await getAllSessions();
    // Always insert at front for most-recent-first ordering
    all.insert(0, session);
    await _storage.writeList(
        _sessionsKey, all.map((s) => s.toJson()).toList());
  }

  @override
  Future<void> clearAllSessions() async {
    await _storage.writeList(_sessionsKey, []);
  }
}
