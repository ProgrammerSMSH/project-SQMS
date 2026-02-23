import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF1E88E5), // Soft blue for primary actions
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E), // Rounded cards
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF1E88E5),
      secondary: Color(0xFF03DAC6),
      surface: Color(0xFF1E1E1E),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: Color(0xFF1E88E5),
      unselectedItemColor: Colors.grey,
    ),
  );
}
