import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../main.dart';
import 'signup_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter email and password")));
      return;
    }

    setState(() => _isLoading = true);
    final error = await context.read<AuthService>().login(
      _emailController.text,
      _passwordController.text,
    );
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (error == null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainBottomNavScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      body: Stack(
        children: [
          // Background Glows
          Positioned(top: -50, left: -50, child: _buildGlow(Colors.blueAccent)),
          Positioned(bottom: -50, right: -50, child: _buildGlow(Colors.purpleAccent)),
          
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const SizedBox(height: 100),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white10),
                      boxShadow: [
                         BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 40)
                      ]
                    ),
                    child: const Icon(Icons.qr_code_2, color: Color(0xFF4DA1FF), size: 50),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "SQMS",
                  style: GoogleFonts.tomorrow(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "SMART QUEUE SYSTEM",
                  style: GoogleFonts.tomorrow(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: Colors.white38,
                  ),
                ),
                const SizedBox(height: 60),
                _buildGlassInput("Email Address", Icons.email_outlined, _emailController),
                const SizedBox(height: 20),
                _buildGlassInput("Password", Icons.lock_outline, _passwordController, isPassword: true),
                const SizedBox(height: 40),
                
                GestureDetector(
                  onTap: _isLoading ? null : _login,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF4DA1FF), Color(0xFF8B5CF6)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF4DA1FF).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 5))
                      ],
                    ),
                    child: Center(
                      child: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            "LOGIN",
                            style: GoogleFonts.tomorrow(fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white),
                          ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                  child: Text(
                    "NEW HERE? CREATE ACCOUNT",
                    style: GoogleFonts.tomorrow(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color) {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.05),
      ),
    );
  }

  Widget _buildGlassInput(String label, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.white24, fontSize: 13),
              prefixIcon: Icon(icon, color: const Color(0xFF4DA1FF), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        ),
      ),
    );
  }
}
