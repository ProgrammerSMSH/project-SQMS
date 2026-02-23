import 'package:flutter/material.dart';
import 'package:sqms_app/constants.dart';
import 'package:sqms_app/theme/app_theme.dart';
import 'package:sqms_app/services/queue_service.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final QueueService _queueService = QueueService();
  bool _isLoading = true;
  List<dynamic> _services = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    final Map<String, dynamic>? branch = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (branch != null) {
      final services = await _queueService.getServices(branch['id']);
      if (mounted) {
        setState(() {
          _services = services ?? [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? branch = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String branchName = branch?['name'] ?? 'Services';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, branchName),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _services.isEmpty
                      ? const Center(child: Text('No services found at this location'))
                      : ListView(
                          padding: const EdgeInsets.all(AppSpacing.padding),
                          children: [
                            _buildSearchBar(),
                            const SizedBox(height: 30),
                            _buildSectionTitle('Categories'),
                            const SizedBox(height: 16),
                            _buildCategories(),
                            const SizedBox(height: 30),
                            _buildSectionTitle('Available Services'),
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

  Widget _buildHeader(BuildContext context, String branchName) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  branchName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: context.textBody,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: context.surfaceColor,
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
                await _queueService.signOut();
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
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: AppStrings.searchServices,
          icon: Icon(Icons.search_rounded, color: context.textSecondary),
          border: InputBorder.none,
          hintStyle: TextStyle(color: context.textSecondary),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: context.textBody,
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
              color: isAll ? null : context.surfaceColor,
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
                color: isAll ? Colors.white : context.textSecondary,
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
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        return _buildServiceCard(context, service);
      },
    );
  }

  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> service) {
    return GestureDetector(
      onTap: () async {
        setState(() => _isLoading = true);
        final tokenData = await _queueService.generateToken(service['_id']); 
        setState(() => _isLoading = false);

        if (tokenData != null && context.mounted) {
          Navigator.pushNamed(
            context,
            '/live_ticket',
            arguments: {
              'ticketNumber': tokenData['tokenNumber'],
              'serviceName': service['name'],
              'initialPosition': 5,
              'initialWaitTime': tokenData['estimatedWaitTime'] ?? 10,
            },
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.surfaceColor,
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIconForService(service['name']), color: AppColors.primary),
            ),
            const Spacer(),
            Text(
              service['name'] ?? 'Unknown',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${service['avgServiceTime'] ?? 8} min wait',
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForService(String? name) {
    if (name == null) return Icons.help_outline;
    final n = name.toLowerCase();
    if (n.contains('financial')) return Icons.account_balance_rounded;
    if (n.contains('student')) return Icons.school_rounded;
    if (n.contains('academic')) return Icons.assignment_ind_rounded;
    if (n.contains('library')) return Icons.local_library_rounded;
    return Icons.settings_rounded;
  }
}
