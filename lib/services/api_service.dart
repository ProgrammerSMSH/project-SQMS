import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use Vercel backend URL
  static const String baseUrl = 'https://project-sqms.vercel.app/api/v1';
  String? jwtToken;

  void setToken(String token) {
    jwtToken = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (jwtToken != null) 'Authorization': 'Bearer $jwtToken',
      };

  Future<dynamic> get(String url) async {
    final response = await http.get(Uri.parse('$baseUrl$url'), headers: _headers);
    return _handleResponse(response);
  }

  Future<dynamic> post(String url, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$url'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.body}');
    }
  }
}
