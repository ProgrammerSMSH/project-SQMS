import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqms_app/constants.dart';
import 'package:sqms_app/screens/onboarding_screen.dart';
import 'package:sqms_app/screens/login_screen.dart';
import 'package:sqms_app/screens/services_screen.dart';

void main() {
  runApp(const SQMSApp());
}

class SQMSApp extends StatelessWidget {
  const SQMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SQMS',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        textTheme: GoogleFonts.tomorrowTextTheme(
          ThemeData.dark().textTheme,
        ),
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.background,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/services': (context) => const ServicesScreen(),
      },
    );
  }
}
