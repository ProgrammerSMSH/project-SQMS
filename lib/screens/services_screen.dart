import 'package:flutter/material.dart';
import 'package:sqms_app/constants.dart';
import 'package:sqms_app/services/queue_service.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final QueueService _queueService = QueueService();
  bool _isLoading = false;

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, queueService),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.padding),
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Categories'),
                  const SizedBox(height: 16),
                  _buildCategories(),
                  const SizedBox(height: 30),
                  _buildSectionTitle('All Services'),
                  const SizedBox(height: 16),
                  _buildServiceGrid(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, QueueService queueService) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Services',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textBody,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
              onPressed: () async {
                await queueService.signOut();
                if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: AppStrings.searchServices,
          icon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
          border: InputBorder.none,
          hintStyle: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textBody,
      ),
    );
  }

  Widget _buildCategories() {
    final categories = ['All', 'Hospital', 'Bank', 'Office', 'Restaurant'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isAll = cat == 'All';
          return Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: isAll ? AppColors.primaryGradient : null,
              color: isAll ? null : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isAll
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Text(
              cat,
              style: TextStyle(
                color: isAll ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildServiceGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final titles = [
          'Financial Services',
          'Student Affairs',
          'Academic Registry',
          'Library Support'
        ];
        final icons = [
          Icons.account_balance_rounded,
          Icons.school_rounded,
          Icons.assignment_ind_rounded,
          Icons.local_library_rounded
        ];
        return _buildServiceCard(context, titles[index], icons[index]);
      },
    );
  }

  Widget _buildServiceCard(BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () async {
        setState(() => _isLoading = true);
        // Using a placeholder service ID for demonstration
        final tokenData = await _queueService.generateToken('65d8f1e5f1e5f1e5f1e5f1e5'); 
        setState(() => _isLoading = false);

        if (tokenData != null && context.mounted) {
          Navigator.pushNamed(
            context,
            '/live_ticket',
            arguments: {
              'ticketNumber': tokenData['tokenNumber'],
              'serviceName': title,
              'initialPosition': 5, // Extracted from live status API in a real flow
              'initialWaitTime': tokenData['estimatedWaitTime'] ?? 10,
            },
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator(strokeWidth: 2)
            else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const Spacer(),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '8 min wait',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

  IconData _getIconForService(String iconName) {
    switch (iconName) {
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'school':
        return Icons.school_outlined;
      case 'id':
        return Icons.assignment_ind_outlined;
      case 'computer':
        return Icons.computer_outlined;
      case 'library':
        return Icons.local_library_outlined;
      case 'health':
        return Icons.medical_services_outlined;
      default:
        return Icons.help_outline;
    }
  }
}
