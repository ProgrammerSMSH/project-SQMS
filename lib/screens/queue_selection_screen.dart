import 'dart:ui';
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
  String selectedPriority = 'GENERAL';

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
                   const SizedBox(height: 12),
                  _buildModernPrioritySelector(),
                  const SizedBox(height: 12),
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

  Widget _buildModernPrioritySelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(child: _modernPriorityChip('GENERAL', 'General', Icons.person)),
          Expanded(child: _modernPriorityChip('SENIOR', 'Senior', Icons.elderly)),
          Expanded(child: _modernPriorityChip('EMERGENCY', 'Emergency', Icons.bolt)),
        ],
      ),
    );
  }

  Widget _modernPriorityChip(String value, String label, IconData icon) {
    final isSelected = selectedPriority == value;
    final color = value == 'EMERGENCY' ? Colors.redAccent : (value == 'SENIOR' ? Colors.orangeAccent : Colors.blueAccent);
    
    return GestureDetector(
      onTap: () => setState(() => selectedPriority = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : Colors.white24),
            const SizedBox(width: 6),
            Text(
              label, 
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.white38, 
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueCard(dynamic queue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
            ),
            child: InkWell(
              onTap: () => _confirmJoinDialog(queue['_id'], queue['name']),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.layers_outlined, color: Colors.blueAccent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(queue['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.timer_outlined, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('${queue['avgWaitTimePerToken']}m per person', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmJoinDialog(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C23),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.check_circle_outline, color: Colors.blueAccent, size: 32),
                  ),
                  const SizedBox(height: 20),
                  Text('Confirm Joining', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(
                    'Join $name queue with $selectedPriority priority?', 
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white60, fontSize: 14)
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _generateToken(id);
                          },
                          child: const Text('JOIN NOW', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
