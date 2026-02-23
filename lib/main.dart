import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'services/queue_service.dart';
import 'services/socket_service.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Assuming firebase_options is generated)
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        ProxyProvider<ApiService, QueueService>(
          update: (_, api, __) => QueueService(api),
        ),
        ChangeNotifierProvider(create: (_) => SocketService()),
        Provider<FCMService>(create: (_) => FCMService()),
      ],
      child: const SmartQueueApp(),
    ),
  );
}

class SmartQueueApp extends StatelessWidget {
  const SmartQueueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Queue Management System',
      theme: AppTheme.darkTheme,
      home: const MainBottomNavScreen(),
    );
  }
}

// Stub for the main view as defined in architecture doc
class MainBottomNavScreen extends StatefulWidget {
  const MainBottomNavScreen({super.key});

  @override
  State<MainBottomNavScreen> createState() => _MainBottomNavScreenState();
}

class _MainBottomNavScreenState extends State<MainBottomNavScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Queue Dashboard')),
      body: Center(
        child: Text('Integration ready. UI placeholders mapped here.'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Queue'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
