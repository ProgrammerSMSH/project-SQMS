import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class QueueService {
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android Emulator localhost
  late io.Socket socket;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  QueueService() {
    _initSocket();
  }

  void _initSocket() {
    socket = io.io('http://10.0.2.2:5000', io.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build());
    
    socket.connect();
    
    socket.onConnect((_) => debugPrint('Connected to Socket.io'));
    socket.onDisconnect((_) => debugPrint('Disconnected from Socket.io'));
  }

  // --- Auth Methods ---
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint('Sign in error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- API Methods ---
  Future<Map<String, dynamic>?> generateToken(String serviceId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final response = await http.post(
        Uri.parse('$baseUrl/tokens/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': user.uid,
          'serviceId': serviceId,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body)['data'];
      }
      return null;
    } catch (e) {
      debugPrint('Generate token error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getLiveStatus(String serviceId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tokens/live/$serviceId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get status error: $e');
      return null;
    }
  }

  // --- Real-time Listeners ---
  void joinServiceRoom(String serviceId) {
    socket.emit('join_queue_room', serviceId);
  }

  void listenToQueueUpdates(Function(dynamic) onUpdate) {
    socket.on('next_called', (data) => onUpdate(data));
  }
}
