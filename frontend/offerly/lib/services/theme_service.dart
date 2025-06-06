import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const _themeKey = 'is_dark_mode';

  Future<void> saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  Future<bool> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false; // default to light mode
  }
}
