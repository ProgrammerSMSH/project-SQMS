import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Shared Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color secondary = Color(0xFFEC4899); // Pink
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8F9FD);
  static const Color lightSurface = Colors.white;
  static const Color lightTextBody = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkTextBody = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextBody,
      ),
      fontFamily: GoogleFonts.outfit().fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.lightTextBody),
        titleTextStyle: TextStyle(
          color: AppColors.lightTextBody,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.lightTextBody),
        bodyMedium: TextStyle(color: AppColors.lightTextSecondary),
      ),
      iconTheme: const IconThemeData(color: AppColors.lightTextBody),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextBody,
      ),
      fontFamily: GoogleFonts.outfit().fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkTextBody),
        titleTextStyle: TextStyle(
          color: AppColors.darkTextBody,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.darkTextBody),
        bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
      ),
      iconTheme: const IconThemeData(color: AppColors.darkTextBody),
    );
  }
}

// Extension to easily access theme colors depending on brightness
extension ThemeColors on BuildContext {
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;
  Color get textBody => Theme.of(this).colorScheme.onSurface;
  Color get textSecondary => Theme.of(this).brightness == Brightness.light ? AppColors.lightTextSecondary : AppColors.darkTextSecondary;
}
