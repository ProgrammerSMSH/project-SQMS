import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqms_app/constants.dart';
import 'package:sqms_app/screens/onboarding_screen.dart';
import 'package:sqms_app/screens/login_screen.dart';
import 'package:sqms_app/screens/services_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        fontFamily: GoogleFonts.outfit().fontFamily,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.textBody,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: AppColors.textBody),
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.light().textTheme,
        ).copyWith(
          bodyLarge: const TextStyle(color: AppColors.textBody),
          bodyMedium: const TextStyle(color: AppColors.textBody),
        ),
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/services': (context) => const ServicesScreen(),
        '/live_ticket': (context) => const LiveTicketScreen(
              ticketNumber: 42,
              serviceName: 'Financial Services',
              initialPosition: 5,
              initialWaitTime: 12,
            ),
      },
    );
  }
}
