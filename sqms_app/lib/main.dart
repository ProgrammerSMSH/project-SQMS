import 'package:flutter/material.dart';
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
        fontFamily: 'Inter', // Defaulting to Inter
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
