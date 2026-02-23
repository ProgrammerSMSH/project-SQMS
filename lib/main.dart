import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqms_app/theme/app_theme.dart';
import 'package:sqms_app/theme/theme_provider.dart';
import 'package:sqms_app/screens/onboarding_screen.dart';
import 'package:sqms_app/screens/login_screen.dart';
import 'package:sqms_app/screens/locations_screen.dart';
import 'package:sqms_app/screens/services_screen.dart';
import 'package:sqms_app/screens/live_ticket_screen.dart';
import 'package:sqms_app/screens/admin_dashboard.dart';
import 'package:sqms_app/screens/main_screen.dart';
import 'package:sqms_app/screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const SQMSApp(),
    ),
  );
}

class SQMSApp extends StatelessWidget {
  const SQMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SQMS',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const AuthWrapper(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/main': (context) => const MainScreen(),
            '/locations': (context) => const LocationsScreen(),
            '/services': (context) => const ServicesScreen(),
            '/admin': (context) => const AdminDashboard(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/live_ticket') {
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) {
                  return LiveTicketScreen(
                    ticketNumber: args?['ticketNumber'] ?? 0,
                    serviceName: args?['serviceName'] ?? 'Unknown',
                    initialPosition: args?['initialPosition'] ?? 0,
                    initialWaitTime: args?['initialWaitTime'] ?? 0,
                  );
                },
              );
            }
            return null;
          },
        );
      },
    );
  }
}
