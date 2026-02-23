import 'package:flutter/material.dart';

class AppColors {
  // Soft, Modern Palette
  static const Color background = Color(0xFFF8F9FD); // Very light grey/blue
  static const Color surface = Colors.white;
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color secondary = Color(0xFFEC4899); // Pink for accents
  static const Color textBody = Color(0xFF1E293B); // Slate 800
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppStrings {
  static const String appName = "SmartQueue";
  static const String onboardingTitle = "Save Your Time";
  static const String onboardingSubtitle = "Join queues remotely and wait stress-free";
  static const String loginTitle = "No more physical lines";
  static const String forgotPassword = "Forgot Password?";
  static const String searchServices = "Search Services";
  static const String selectServices = "Select Services";
  static const String financialServices = "Financial Services";
  static const String studentAffairs = "Student Affairs";
}

class AppSpacing {
  static const double borderRadius = 24.0;
  static const double padding = 20.0;
}
