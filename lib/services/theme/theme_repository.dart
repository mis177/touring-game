abstract interface class ThemeRepository {
  Future<bool> loadIsDarkTheme();
  Future<void> saveIsDarkTheme(bool isDarkTheme);
}
