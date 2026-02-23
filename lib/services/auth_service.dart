import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  // Use Vercel Backend
  static const String baseUrl = 'https://project-sqms.vercel.app/api/v1';
  String? _token;
  String? _userName;

  String? get token => _token;
  String? get userName => _userName;
  bool get isAuthenticated => _token != null;

  Future<bool> login(String phone, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'name': name}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _userName = data['name'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('userName', _userName!);
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return;
    
    _token = prefs.getString('token');
    _userName = prefs.getString('userName');
    notifyListeners();
  }

  void logout() async {
    _token = null;
    _userName = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userName');
    notifyListeners();
  }
}
