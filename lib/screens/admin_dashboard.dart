import 'package:flutter/material.dart';
import 'package:sqms_app/constants.dart';
import 'package:sqms_app/theme/app_theme.dart';
import 'package:sqms_app/services/queue_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final QueueService _queueService = QueueService();
  bool _isOnline = true;
  bool _isLoading = false;
  int _currentServing = 42;
  int _waitingCount = 15;

  void _callNext() async {
    setState(() => _isLoading = true);
    // Placeholder logic for calling next token via Node.js API
    await Future.delayed(const Duration(seconds: 1)); 
    setState(() {
      _currentServing++;
      _waitingCount--;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.padding),
                child: Column(
                  children: [
                    _buildStatsGrid(),
                    const SizedBox(height: 30),
                    _buildControlPanel(),
                    const SizedBox(height: 30),
                    _buildRecentHistory(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Staff Portal',
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Counter 04',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: context.textBody,
                ),
              ),
            ],
          ),
          Switch.adaptive(
            value: _isOnline,
            activeColor: AppColors.success,
            onChanged: (val) => setState(() => _isOnline = val),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Waiting',
            _waitingCount.toString(),
            Icons.people_alt_rounded,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Avg Time',
            '8m',
            Icons.timer_rounded,
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: context.textBody,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: context.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Currently Serving',
            style: TextStyle(
              color: context.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '#$_currentServing',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 30),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _callNext,
      child: Container(
        height: 70,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Call Next Token',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildRecentHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.textBody,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(3, (index) => _buildHistoryTile(index)),
      ],
    );
  }

  Widget _buildHistoryTile(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Token #${_currentServing - index - 1}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'Completed',
            style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
