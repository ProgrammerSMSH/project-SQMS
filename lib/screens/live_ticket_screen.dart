import 'package:flutter/material.dart';
import 'package:sqms_app/constants.dart';

class LiveTicketScreen extends StatelessWidget {
  final int ticketNumber;
  final String serviceName;
  final int initialPosition;
  final int initialWaitTime;

  const LiveTicketScreen({
    super.key,
    required this.ticketNumber,
    required this.serviceName,
    required this.initialPosition,
    required this.initialWaitTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Status'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.padding),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildServiceInfoCard(),
            const SizedBox(height: 30),
            _buildMainTicketDisplay(),
            const SizedBox(height: 40),
            _buildStatusGrid(),
            const SizedBox(height: 40),
            _buildCancelButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.padding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.business_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Central Branch • Counter 04',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTicketDisplay() {
    return Column(
      children: [
        const Text(
          'YOUR TICKET',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Center(
            child: Text(
              ticketNumber.toString().padLeft(3, '0'),
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusGrid() {
    return Row(
      children: [
        _buildStatusItem(
          icon: Icons.people_outline,
          label: 'Position',
          value: '#$initialPosition',
          color: AppColors.primary,
        ),
        const SizedBox(width: 16),
        _buildStatusItem(
          icon: Icons.timer_outlined,
          label: 'Wait Time',
          value: '$initialWaitTime mins',
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.padding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        // Handle cancellation
      },
      child: const Text(
        'Cancel Token',
        style: TextStyle(
          color: AppColors.danger,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
