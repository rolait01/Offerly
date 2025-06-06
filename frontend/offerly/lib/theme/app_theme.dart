// app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.lightAppBar,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightAppBar,
      foregroundColor: AppColors.lightText,
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightAppBar,
      secondary: AppColors.lightCard,
      surface: AppColors.lightSearchBar,
      onPrimary: AppColors.lightText,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkAppBar,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkAppBar,
      foregroundColor: AppColors.darkText,
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkAppBar,
      secondary: AppColors.darkCard,
      surface: AppColors.darkSearchBar,
      onPrimary: AppColors.darkText,
    ),
  );
}
