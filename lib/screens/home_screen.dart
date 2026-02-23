import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sync_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('SQMS', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white12,
              child: Icon(Icons.notifications_none, size: 20, color: Colors.white),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -50,
            child: _buildGlowCircle(Colors.blue.withOpacity(0.15), 300),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: _buildGlowCircle(Colors.purple.withOpacity(0.1), 250),
          ),
          
          Consumer<SyncService>(
            builder: (context, syncService, child) {
              if (syncService.isLoading && syncService.activeTokens.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: () async {
                  syncService.stopSyncing();
                  syncService.startSyncing();
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
                  children: [
                    const Text('Hello,', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const Text('Your Status', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 24),
                    
                    if (syncService.activeTokens.isEmpty)
                      _buildEmptyState()
                    else
                      ...syncService.activeTokens.map((token) => _buildModernTokenCard(context, token)).toList(),
                    
                    const SizedBox(height: 40),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Announcements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('View all', style: TextStyle(fontSize: 12, color: Colors.blueAccent)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildAnnouncementCard(context, 'Counter 2 is now open for fast-track.', Icons.bolt, Colors.amber),
                    _buildAnnouncementCard(context, 'Morning rush handled. Average wait is now 5 min.', Icons.timer_outlined, Colors.greenAccent),
                  ],
                ),
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildGlowCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 100, spreadRadius: 50),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        children: [
          Icon(Icons.confirmation_number_outlined, size: 48, color: Colors.white24),
          SizedBox(height: 16),
          Text("No active tokens found", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text("Join a queue to get started", style: TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildModernTokenCard(BuildContext context, dynamic token) {
    final queueName = token['queueId']?['name'] ?? 'Queue';
    final tokenNumber = token['tokenNumber'] ?? '---';
    final waitTime = token['estimatedWaitTime']?.toString() ?? '--';
    final status = token['status'] ?? 'WAITING';
    final counterName = token['counterId']?['name'] ?? '---';

    final isServing = status == 'SERVING';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isServing 
                  ? [Colors.green.withOpacity(0.15), Colors.green.withOpacity(0.05)]
                  : [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isServing ? Colors.green.withOpacity(0.3) : Colors.white10,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(queueName.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white54, letterSpacing: 1.2)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isServing ? Colors.green : Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status, 
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isServing ? Colors.white : Colors.blueAccent)
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TOKEN', style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                          Text(tokenNumber, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
                        ],
                      ),
                    ),
                    if (isServing)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('COUNTER', style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                          Text(counterName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.greenAccent)),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('EST. WAIT', style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                          Text('$waitTime min', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                        ],
                      ),
                  ],
                ),
                if (isServing) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(1),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: const Text(
                      'PROCEED NOW', 
                      textAlign: TextAlign.center, 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(BuildContext context, String text, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
