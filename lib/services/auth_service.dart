import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  void logout() {
    _token = null;
    _userName = null;
    notifyListeners();
  }
}
