import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/queue_service.dart';

class TokenHistoryScreen extends StatefulWidget {
  const TokenHistoryScreen({super.key});

  @override
  State<TokenHistoryScreen> createState() => _TokenHistoryScreenState();
}

class _TokenHistoryScreenState extends State<TokenHistoryScreen> {
  bool isLoading = true;
  List<dynamic> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final dynamic responseData = await context.read<QueueService>().getHistoryTokens();
      setState(() {
        final historyList = (responseData is Map && responseData.containsKey('tokens'))
             ? responseData['tokens']
             : responseData;
        history = (historyList is List) ? historyList : [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error loading history: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Token History')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHistory,
              child: history.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 100),
                        Center(child: Text("No past tokens found.", style: TextStyle(color: Colors.grey))),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        final tokenNumber = item['tokenNumber'] ?? '---';
                        final status = item['status'] ?? 'UNKNOWN';
                        // Ideally parse DateTime safely here, keeping simple for demo
                        final dateStr = item['createdAt']?.toString().split('T').first ?? 'Past'; 

                        final isCompleted = status == 'COMPLETED';
                        final isNoShow = status == 'NO_SHOW';

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
                            title: Text(tokenNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            subtitle: Text(dateStr, style: const TextStyle(color: Colors.white54)),
                            trailing: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
