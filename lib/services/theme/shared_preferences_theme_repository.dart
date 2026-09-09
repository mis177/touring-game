import 'package:shared_preferences/shared_preferences.dart';
import 'package:touring_game/core/errors/app_exception.dart';
import 'package:touring_game/services/theme/theme_repository.dart';

class SharedPreferencesThemeRepository implements ThemeRepository {
  const SharedPreferencesThemeRepository();

  @override
  Future<bool> loadIsDarkTheme() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return preferences.getBool('is_dark_theme') ?? false;
    } on Exception catch (error) {
      throw PreferencesException('Could not load theme preferences.', error);
    }
  }

  @override
  Future<void> saveIsDarkTheme(bool isDarkTheme) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setBool('is_dark_theme', isDarkTheme);
      if (!saved) {
        throw const PreferencesException('Could not save theme preferences.');
      }
    } on PreferencesException {
      rethrow;
    } on Exception catch (error) {
      throw PreferencesException('Could not save theme preferences.', error);
    }
  }
}
