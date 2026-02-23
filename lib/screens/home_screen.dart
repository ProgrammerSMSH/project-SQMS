import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/socket_service.dart';
import '../services/queue_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  List<dynamic> activeTokens = [];

  @override
  void initState() {
    super.initState();
    _loadActiveTokens();
  }

  Future<void> _loadActiveTokens() async {
    try {
      final dynamic responseData = await context.read<QueueService>().getActiveTokens();
      setState(() {
         // Handle map encapsulation if backend returns { tokens: [] }
         final tokensList = (responseData is Map && responseData.containsKey('tokens'))
             ? responseData['tokens']
             : responseData;

        // Ensure it's treated as a list, default to empty if null/unexpected type
        activeTokens = (tokensList is List) ? tokensList : [];
        isLoading = false;
      });
      
      // Auto-join socket rooms for active queues
      for (var token in activeTokens) {
        if(token['queueId'] != null) {
          context.read<SocketService>().joinQueue(token['queueId']['_id'], 'user_id_here');
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error loading tokens: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Consumer to listen to live Socket updates
    return Consumer<SocketService>(
      builder: (context, socketService, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Smart Queue', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
            ],
          ),
          body: isLoading 
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadActiveTokens,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      const Text('Your Active Tokens', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 16),
                      if (activeTokens.isEmpty)
                        const Center(child: Padding(
                           padding: EdgeInsets.all(40.0),
                           child: Text("You don't have any active tokens.", style: TextStyle(color: Colors.grey)),
                        ))
                      else
                        ...activeTokens.map((token) => _buildActiveTokenCard(token)).toList(),
                      
                      const SizedBox(height: 32),
                      const Text('Recent Announcements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)),
                      const SizedBox(height: 16),
                      _buildAnnouncementCard('Counter 2 is now open.', Icons.info_outline, Colors.blue),
                      _buildAnnouncementCard('Emergency queue currently experiencing delays.', Icons.warning_amber, Colors.orange),
                    ],
                  ),
                ),
        );
      }
    );
  }

  Widget _buildActiveTokenCard(dynamic token) {
    final queueName = token['queueId']?['name'] ?? 'Unknown Queue';
    final tokenNumber = token['tokenNumber'] ?? '---';
    final waitTime = token['estimatedWaitTime']?.toString() ?? '--';
    final status = token['status'] ?? 'WAITING';
    final counterName = token['counterId']?['name'] ?? 'Waiting...';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5)),
        ],
        border: Border.all(color: status == 'SERVING' ? Colors.green.withOpacity(0.5) : Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(queueName, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'SERVING' ? Colors.green.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: status == 'SERVING' ? Colors.green : Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Token Number', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(tokenNumber, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Est. Time', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('$waitTime min', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (status == 'SERVING')
             Container(
               width: double.infinity,
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
               child: Text('Proceed to $counterName', textAlign: TextAlign.center, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
             ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(String text, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }
}
