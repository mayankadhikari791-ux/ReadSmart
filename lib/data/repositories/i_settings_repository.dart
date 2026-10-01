import '../../models/user_model.dart';
import '../../models/reading_statistics_model.dart';
import '../../models/reading_goal_model.dart';
import '../../models/language_preference_model.dart';

abstract class ISettingsRepository {
  Future<User> getUser();
  Future<void> saveUser(User user);

  Future<ReadingStatistics> getStatistics();
  Future<void> saveStatistics(ReadingStatistics statistics);

  Future<ReadingGoal> getGoals();
  Future<void> saveGoals(ReadingGoal goal);

  Future<LanguagePreference> getLanguagePreference();
  Future<void> saveLanguagePreference(LanguagePreference preference);

  Future<String> getThemePreference();
  Future<void> saveThemePreference(String themeMode);

  Future<double> getFontSizePreference();
  Future<void> saveFontSizePreference(double fontSize);
}
