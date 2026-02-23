import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/queue_service.dart';

class QueueSelectionScreen extends StatefulWidget {
  const QueueSelectionScreen({super.key});

  @override
  State<QueueSelectionScreen> createState() => _QueueSelectionScreenState();
}

class _QueueSelectionScreenState extends State<QueueSelectionScreen> {
  bool isLoading = true;
  List<dynamic> queues = [];
  String selectedPriority = 'NORMAL';

  @override
  void initState() {
    super.initState();
    _loadQueues();
  }

  Future<void> _loadQueues() async {
    try {
      final dynamic responseData = await context.read<QueueService>().getQueues();
      setState(() {
        // Assuming API might return { queues: [...] } or just [...]
        queues = (responseData is Map && responseData.containsKey('queues')) 
            ? responseData['queues'] 
            : responseData;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error loading queues: $e");
    }
  }

  Future<void> _generateToken(String queueId) async {
    setState(() => isLoading = true);
    try {
      await context.read<QueueService>().generateToken(queueId, priority: selectedPriority);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Token generated successfully!')));
      // Ideally navigate to Home or trigger refresh, handled via state normally.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
        _loadQueues(); // Refresh UI
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join a Queue')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadQueues,
              child: Column(
                children: [
                  _buildPrioritySelector(),
                  const Divider(color: Colors.white12, height: 1),
                  Expanded(
                    child: queues.isEmpty 
                      ? ListView(
                          children: const [
                            SizedBox(height: 100),
                            Center(child: Text("No active queues available right now.", style: TextStyle(color: Colors.grey))),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: queues.length,
                          itemBuilder: (context, index) {
                            final queue = queues[index];
                            return _buildQueueCard(queue);
                          },
                        ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPrioritySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _priorityChip('NORMAL', 'Normal', Icons.person),
          _priorityChip('SENIOR', 'Senior', Icons.elderly),
          _priorityChip('EMERGENCY', 'Emergency', Icons.warning),
        ],
      ),
    );
  }

  Widget _priorityChip(String value, String label, IconData icon) {
    final isSelected = selectedPriority == value;
    final color = value == 'EMERGENCY' ? Colors.red : (value == 'SENIOR' ? Colors.orange : Theme.of(context).primaryColor);
    
    return GestureDetector(
      onTap: () => setState(() => selectedPriority = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(color: isSelected ? color : Colors.white24),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? color : Colors.white54),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isSelected ? color : Colors.white54, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueCard(dynamic queue) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _confirmJoinDialog(queue['_id'], queue['name']);
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.local_hospital, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(queue['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Est. Wait: ${queue['avgWaitTimePerToken']} min/person', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmJoinDialog(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Join $name?'),
        content: Text('Priority: $selectedPriority\nAre you sure you want to generate a token?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.pop(ctx);
              _generateToken(id);
            },
            child: const Text('Generate Token'),
          ),
        ],
      ),
    );
  }
}
