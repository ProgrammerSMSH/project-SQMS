import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqms_app/screens/onboarding_screen.dart';
import 'package:sqms_app/screens/main_screen.dart';
import 'package:sqms_app/screens/live_ticket_screen.dart';
import 'package:sqms_app/services/ticket_storage.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const TicketCheckWrapper();
        }
        return const OnboardingScreen();
      },
    );
  }
}

class TicketCheckWrapper extends StatefulWidget {
  const TicketCheckWrapper({super.key});

  @override
  State<TicketCheckWrapper> createState() => _TicketCheckWrapperState();
}

class _TicketCheckWrapperState extends State<TicketCheckWrapper> {
  bool _isLoading = true;
  Map<String, dynamic>? _activeTicket;

  @override
  void initState() {
    super.initState();
    _checkTicket();
  }

  Future<void> _checkTicket() async {
    final ticket = await TicketStorage.getActiveTicket();
    if (mounted) {
      setState(() {
        _activeTicket = ticket;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_activeTicket != null) {
      return LiveTicketScreen(
        ticketNumber: _activeTicket!['tokenNumber'] ?? 0,
        serviceName: _activeTicket!['serviceName'] ?? 'Unknown Service',
        initialPosition: 5, // Ideally fetched from a live check 
        initialWaitTime: _activeTicket!['estimatedWaitTime'] ?? 10,
      );
    }

    return const MainScreen();
  }
}
