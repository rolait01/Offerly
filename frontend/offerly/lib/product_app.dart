import 'package:flutter/material.dart';
import 'package:offerly/main_screen.dart';
import 'package:offerly/theme/app_theme.dart';
import 'package:offerly/services/theme_service.dart';
import 'screens/product_list_screen.dart';

class ProductApp extends StatefulWidget {
  const ProductApp({super.key});

  @override
  State<ProductApp> createState() => _ProductAppState();
}

class _ProductAppState extends State<ProductApp> {
  final ThemeService _themeService = ThemeService();
  bool _isDarkMode = false;
  bool _isThemeLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final theme = await _themeService.loadTheme();
    setState(() {
      _isDarkMode = theme;
      _isThemeLoaded = true;
    });
  }

  void toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    _themeService.saveTheme(value);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isThemeLoaded) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'Offerly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MainScreen(
        isDarkMode: _isDarkMode,
        onThemeToggle: toggleTheme,
      ),
    );
  }
}

