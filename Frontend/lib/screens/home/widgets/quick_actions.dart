// lib/screens/user/driver/dashboard/widgets/quick_actions.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onUpdateLocation;
  final VoidCallback onOpenCommunication;

  const QuickActions({
    super.key,
    required this.onUpdateLocation,
    required this.onOpenCommunication,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.my_location,
        label: 'Update Location',
        color: AppColors.primary,
        onTap: onUpdateLocation,
      ),
      _QuickAction(
        icon: Icons.chat_outlined,
        label: 'Contact Support',
        color: Colors.purple,
        onTap: onOpenCommunication,
      ),
      _QuickAction(
        icon: Icons.history,
        label: 'History',
        color: Colors.orange,
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.help_outline,
        label: 'Help',
        color: Colors.teal,
        onTap: () {},
      ),
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: _QuickActionButton(action: action),
        );
      }).toList(),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionButton extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionButton({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                action.icon,
                color: action.color,
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              action.label,
              style: AppTypography.body(10, color: AppColors.ink500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}