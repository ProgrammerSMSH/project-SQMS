import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Color Palette
  static const Color darkBg = Color(0xFF0F0F13);
  static const Color cardBg = Color(0xFF1C1C23);
  static const Color accentBlue = Color(0xFF4DA1FF);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color surfaceNav = Color(0xFF16161D);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: accentBlue,
    scaffoldBackgroundColor: darkBg,
    
    colorScheme: const ColorScheme.dark(
      primary: accentBlue,
      secondary: accentPurple,
      surface: cardBg,
      background: darkBg,
    ),

    textTheme: GoogleFonts.tomorrowTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.tomorrow(fontWeight: FontWeight.w900, color: Colors.white),
      titleLarge: GoogleFonts.tomorrow(fontWeight: FontWeight.bold, color: Colors.white),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF1C1C23).withOpacity(0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Colors.white10, width: 1),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceNav,
      selectedItemColor: accentBlue,
      unselectedItemColor: Colors.white24,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}
