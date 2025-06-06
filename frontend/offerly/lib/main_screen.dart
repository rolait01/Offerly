import 'package:flutter/material.dart';
import 'package:offerly/screens/ai_search_screen.dart';
import 'package:offerly/screens/favorites_screen.dart';
import 'package:offerly/screens/product_list_screen.dart';
import 'package:offerly/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeToggle;

  const MainScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          isDarkMode: widget.isDarkMode,
          onThemeToggle: widget.onThemeToggle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Offerly',
          style: TextStyle(
            fontSize: 24, // z. B. 24 statt dem Standard 20
            fontWeight: FontWeight.w600, // optional für etwas mehr Gewicht
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: PageView(
        controller: _controller,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: [
          ProductListScreen(
              isDarkMode: widget.isDarkMode,
              onThemeToggle: widget.onThemeToggle),
          const FavoritesScreen(),
          AiSearchScreen(
              isDarkMode: widget.isDarkMode,
              onThemeToggle: widget.onThemeToggle),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFFFD700),
        onTap: (index) {
          _controller.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Produkte'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favoriten'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'AI Suche'),
        ],
      ),
    );
  }
}
