import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final userName = auth.userName ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(title: const Text('PROFILE', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 40, spreadRadius: 10)],
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent]),
                  ),
                  child: const Icon(Icons.person, size: 50, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(userName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 14, color: Colors.greenAccent),
                SizedBox(width: 4),
                Text('VERIFIED ACCOUNT', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
          ),
          const SizedBox(height: 48),
          _buildGlassTile(Icons.settings_outlined, 'Settings', Colors.white38),
          _buildGlassTile(Icons.language_outlined, 'Language', Colors.white38),
          _buildGlassTile(Icons.help_outline, 'Support & Feedback', Colors.white38),
          const SizedBox(height: 32),
          _buildGlassTile(Icons.logout, 'LOGOUT', Colors.redAccent, isAction: true, onTap: () => auth.logout()),
        ],
      ),
    );
  }

  Widget _buildGlassTile(IconData icon, String title, Color color, {bool isAction = false, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: color),
        ),
        title: Text(title, style: TextStyle(color: color, fontWeight: isAction ? FontWeight.w900 : FontWeight.w600, fontSize: 14, letterSpacing: isAction ? 1.2 : 0)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
      ),
    );
  }
}

extension on CircleAvatar {
  static Widget gradientAvatar({required double radius, required Gradient gradient, required Widget child}) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: gradient),
      child: Center(child: child),
    );
  }
}
