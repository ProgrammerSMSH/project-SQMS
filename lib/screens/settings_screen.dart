import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqms_app/constants.dart';
import 'package:sqms_app/theme/app_theme.dart';
import 'package:sqms_app/theme/theme_provider.dart';
import 'package:sqms_app/services/queue_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.padding),
        children: [
          _buildThemeToggle(context, themeProvider),
          const SizedBox(height: 20),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  provider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Dark Mode',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.textBody,
                ),
              ),
            ],
          ),
          Switch.adaptive(
            value: provider.isDarkMode,
            activeColor: AppColors.primary,
            onChanged: (value) => provider.toggleTheme(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await QueueService().signOut();
        if (context.mounted) {
           Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          boxShadow: [
             BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
             Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: AppColors.danger),
              ),
              const SizedBox(width: 16),
              const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.danger,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
