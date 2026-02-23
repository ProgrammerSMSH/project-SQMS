import 'package:flutter/material.dart';

class TokenHistoryScreen extends StatelessWidget {
  const TokenHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mocking history data for now
    final mockHistory = [
      {'token': 'GN-102', 'date': 'Today, 10:30 AM', 'status': 'COMPLETED'},
      {'token': 'BL-084', 'date': 'Yesterday, 2:15 PM', 'status': 'COMPLETED'},
      {'token': 'GN-090', 'date': 'Oct 14, 9:00 AM', 'status': 'NO_SHOW'},
      {'token': 'EM-012', 'date': 'Oct 12, 11:45 PM', 'status': 'CANCELLED'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Token History')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockHistory.length,
        itemBuilder: (context, index) {
          final item = mockHistory[index];
          final isCompleted = item['status'] == 'COMPLETED';
          final isNoShow = item['status'] == 'NO_SHOW';

          Color statusColor = Colors.grey;
          IconData statusIcon = Icons.cancel;

          if (isCompleted) {
            statusColor = Colors.green;
            statusIcon = Icons.check_circle;
          } else if (isNoShow) {
            statusColor = Colors.orange;
            statusIcon = Icons.access_time_filled;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Icon(statusIcon, color: statusColor, size: 32),
              title: Text(item['token']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text(item['date']!, style: const TextStyle(color: Colors.white54)),
              trailing: Text(item['status']!, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}
