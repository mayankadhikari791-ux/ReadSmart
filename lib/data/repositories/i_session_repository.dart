import '../../models/reading_session_model.dart';

abstract class ISessionRepository {
  Future<List<ReadingSession>> getAllSessions();
  Future<List<ReadingSession>> getSessionsForBook(String bookId);
  Future<void> saveSession(ReadingSession session);
  Future<void> clearAllSessions();
}
