import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'services/queue_service.dart';
import 'services/sync_service.dart';
import 'services/fcm_service.dart';
import 'services/auth_service.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/queue_selection_screen.dart';
import 'screens/qr_scan_screen.dart';
import 'screens/token_history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize AuthService and try auto-login
  final authService = AuthService();
  await authService.tryAutoLogin();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
        ProxyProvider<AuthService, ApiService>(
          update: (_, auth, __) {
             final api = ApiService();
             if(auth.token != null) api.setToken(auth.token!);
             return api;
          },
        ),
        ProxyProvider<ApiService, QueueService>(
          update: (_, api, __) => QueueService(api),
        ),
        ChangeNotifierProxyProvider<ApiService, SyncService>(
          create: (context) => SyncService(context.read<ApiService>()),
          update: (_, api, previousSync) {
            if (previousSync == null) return SyncService(api)..startSyncing();
            previousSync.updateApi(api);
            return previousSync;
          },
        ),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
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
      title: 'SQMS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppRoot(),
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkFirstSeen(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        
        final bool showOnboarding = snapshot.data!;
        
        if (showOnboarding) {
          return const OnboardingScreen();
        }

        return Consumer<AuthService>(
          builder: (context, auth, _) {
            return auth.isAuthenticated ? const MainBottomNavScreen() : const AuthScreen();
          },
        );
      },
    );
  }

  Future<bool> _checkFirstSeen() async {
    final prefs = await SharedPreferences.getInstance();
    // Use a unique key for the new onboarding
    return !(prefs.getBool('seen_onboarding_v2') ?? false);
  }
}

class MainBottomNavScreen extends StatefulWidget {
  const MainBottomNavScreen({super.key});

  @override
  State<MainBottomNavScreen> createState() => _MainBottomNavScreenState();
}

class _MainBottomNavScreenState extends State<MainBottomNavScreen> {

  final List<Widget> _screens = [
    const HomeScreen(),
    const QueueSelectionScreen(),
    const QRScanScreen(),
    const TokenHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Start background syncing when main screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SyncService>().startSyncing();
    });
  }

  @override
  void dispose() {
    // Though usually alive for app lifetime, good practice
    if(mounted) context.read<SyncService>().stopSyncing();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    return Scaffold(
      body: IndexedStack(
        index: nav.currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: nav.currentIndex,
        onTap: (i) => nav.setIndex(i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Queue'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
