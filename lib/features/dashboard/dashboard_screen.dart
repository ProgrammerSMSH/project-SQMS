import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQMS Dashboard'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Quality Manager',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Active Audits',
                    '12',
                    Icons.assignment_turned_in_rounded,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Pending Tasks',
                    '05',
                    Icons.pending_actions_rounded,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Large Chart Card Placeholder
            _buildChartPlaceholder(context),
            
            const SizedBox(height: AppConstants.paddingLarge),
            
            Text(
              'Recent Inspections',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            _buildInspectionItem(
              context,
              'Supplier A - Electronics',
              'Passed',
              '2 hours ago',
              AppColors.success,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildInspectionItem(
              context,
              'Supplier B - Safety Gear',
              'Warning',
              '5 hours ago',
              AppColors.warning,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('New Audit'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        width: double.infinity,
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Compliance Overview', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            Center(
              child: Icon(
                Icons.bar_chart_rounded,
                size: 80,
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionItem(BuildContext context, String title, String status, String time, Color statusColor) {
    return Card(
      child: ListTile(
        title: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
        subtitle: Text(time),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
