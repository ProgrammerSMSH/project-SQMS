import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TicketStorage {
  static const String _ticketKey = 'active_ticket_data';

  static Future<void> saveTicket(Map<String, dynamic> ticketData) async {
    final prefs = await SharedPreferences.getInstance();
    // Save as JSON string
    prefs.setString(_ticketKey, jsonEncode(ticketData));
  }

  static Future<Map<String, dynamic>?> getActiveTicket() async {
    final prefs = await SharedPreferences.getInstance();
    final String? ticketJson = prefs.getString(_ticketKey);
    
    if (ticketJson != null && ticketJson.isNotEmpty) {
      try {
        return jsonDecode(ticketJson) as Map<String, dynamic>;
      } catch (e) {
        return null; // Handle corrupted data
      }
    }
    return null;
  }

  static Future<void> clearTicket() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_ticketKey);
  }
}
