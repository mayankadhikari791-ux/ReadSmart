import 'package:read_smart/models/user_model.dart';
import 'package:read_smart/models/reading_statistics_model.dart';
import 'package:read_smart/models/reading_goal_model.dart';
import 'package:read_smart/models/language_preference_model.dart';
import '../i_settings_repository.dart';
import '../../storage/i_storage_driver.dart';

class LocalSettingsRepository implements ISettingsRepository {
  final IStorageDriver _storage;

  static const String _userKey = 'user_profile';
  static const String _statsKey = 'reading_statistics';
  static const String _goalsKey = 'reading_goals';
  static const String _langKey = 'language_preferences';
  static const String _themeKey = 'app_theme';
  static const String _fontKey = 'font_size';

  LocalSettingsRepository(this._storage);

  // ─── User Profile ─────────────────────────────────────────────────────────

  @override
  Future<User> getUser() async {
    final data = await _storage.readMap(_userKey);
    if (data == null) {
      return User(
        id: 'user_1',
        name: 'Mayank',
        email: 'mayank@readsmart.app',
        readingLevel: 'Advanced Reader',
        avatarInitials: 'M',
        memberSince: 'Reading since Jan 2024',
      );
    }
    return User.fromJson(data);
  }

  @override
  Future<void> saveUser(User user) async {
    await _storage.writeMap(_userKey, user.toJson());
  }

  // ─── Reading Statistics ──────────────────────────────────────────────────

  @override
  Future<ReadingStatistics> getStatistics() async {
    final data = await _storage.readMap(_statsKey);
    if (data == null) {
      return ReadingStatistics(
        id: 'stats_1',
        streakDays: 7,
        totalPagesRead: 847,
        totalReadingMinutes: 332,
        booksCompleted: 2,
        averageWpm: 280,
        weeklyWpmHistory: [215.0, 230.0, 248.0, 260.0, 272.0, 285.0, 295.0],
        userReadingScore: 78,
      );
    }
    return ReadingStatistics.fromJson(data);
  }

  @override
  Future<void> saveStatistics(ReadingStatistics statistics) async {
    await _storage.writeMap(_statsKey, statistics.toJson());
  }

  // ─── Reading Goals ────────────────────────────────────────────────────────

  @override
  Future<ReadingGoal> getGoals() async {
    final data = await _storage.readMap(_goalsKey);
    if (data == null) {
      return ReadingGoal(
        id: 'goal_1',
        dailyMinutesTarget: 30,
        annualBooksTarget: 24,
        currentDailyMinutes: 45,
        completedBooksThisYear: 12,
      );
    }
    return ReadingGoal.fromJson(data);
  }

  @override
  Future<void> saveGoals(ReadingGoal goal) async {
    await _storage.writeMap(_goalsKey, goal.toJson());
  }

  // ─── Language Preferences ────────────────────────────────────────────────

  @override
  Future<LanguagePreference> getLanguagePreference() async {
    final data = await _storage.readMap(_langKey);
    if (data == null) {
      return LanguagePreference(
        id: 'lang_1',
        interfaceLanguage: 'English (US)',
        primaryDictionaryLanguage: 'English (US)',
        secondaryDictionaryLanguage: 'Hindi (हिंदी)',
        regionalLanguage: 'Punjabi (ਪੰਜਾਬੀ)',
        dualLanguageEnabled: true,
      );
    }
    return LanguagePreference.fromJson(data);
  }

  @override
  Future<void> saveLanguagePreference(LanguagePreference preference) async {
    await _storage.writeMap(_langKey, preference.toJson());
  }

  // ─── Theme Preference ─────────────────────────────────────────────────────

  @override
  Future<String> getThemePreference() async {
    final data = await _storage.readMap(_themeKey);
    return data?['theme'] as String? ?? 'dark';
  }

  @override
  Future<void> saveThemePreference(String themeMode) async {
    await _storage.writeMap(_themeKey, {'theme': themeMode});
  }

  // ─── Font Size ────────────────────────────────────────────────────────────

  @override
  Future<double> getFontSizePreference() async {
    final data = await _storage.readMap(_fontKey);
    return (data?['fontSize'] as num?)?.toDouble() ?? 16.0;
  }

  @override
  Future<void> saveFontSizePreference(double fontSize) async {
    await _storage.writeMap(_fontKey, {'fontSize': fontSize});
  }
}
