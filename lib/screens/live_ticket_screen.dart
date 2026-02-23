import 'package:flutter/material.dart';
import 'package:sqms_app/constants.dart';
import 'package:sqms_app/theme/app_theme.dart';
import 'package:sqms_app/services/ticket_storage.dart';

class LiveTicketScreen extends StatefulWidget {
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
  State<LiveTicketScreen> createState() => _LiveTicketScreenState();
}

class _LiveTicketScreenState extends State<LiveTicketScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _shadowAnimation = Tween<double>(begin: 15.0, end: 30.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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
            const SizedBox(height: 10),
            _buildAnimatedCard(
              delay: 100,
              child: _buildServiceInfoCard(),
            ),
            const SizedBox(height: 50),
            _buildMainTicketDisplay(),
            const SizedBox(height: 50),
            _buildAnimatedCard(
              delay: 300,
              child: _buildStatusGrid(),
            ),
            const SizedBox(height: 40),
            _buildAnimatedCard(
              delay: 500,
              child: _buildCancelButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({required int delay, required Widget child}) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, double value, childWidget) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildServiceInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.padding),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.03),
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
              color: AppColors.primary.withOpacity(0.1),
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
                  widget.serviceName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Central Branch • Counter 04',
                  style: TextStyle(
                    color: context.textSecondary,
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
    // Determine progress (mock logic for demo: position 0 is 100%, 10 is 0%)
    double progress = 1.0 - (widget.initialPosition / 10).clamp(0.0, 1.0);

    return Column(
      children: [
        Text(
          'YOUR TICKET',
          style: TextStyle(
            letterSpacing: 3,
            fontWeight: FontWeight.w700,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Progress Ring
              SizedBox(
                width: 240,
                height: 240,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progress),
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 8,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                    );
                  },
                ),
              ),
              // Breathing Core
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: _shadowAnimation.value,
                            spreadRadius: _shadowAnimation.value / 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.ticketNumber.toString().padLeft(3, '0'),
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -2,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
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
          value: '#${widget.initialPosition}',
          color: AppColors.primary,
        ),
        const SizedBox(width: 16),
        _buildStatusItem(
          icon: Icons.timer_outlined,
          label: 'Wait Time',
          value: '${widget.initialWaitTime} mins',
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
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () async {
        await TicketStorage.clearTicket();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
        }
      },
      icon: const Icon(Icons.cancel_outlined, color: AppColors.danger),
      label: const Text(
        'Cancel Ticket',
        style: TextStyle(
          color: AppColors.danger,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        backgroundColor: AppColors.danger.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
