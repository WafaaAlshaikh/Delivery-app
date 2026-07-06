// lib/screens/user/driver/widgets/status_update_button.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';

class StatusUpdateButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const StatusUpdateButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    this.isCompleted = false,
    this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isCompleted;
    final color = isCompleted 
        ? AppColors.success 
        : (isActive ? AppColors.primary : AppColors.ink300);

    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isCompleted 
              ? AppColors.successSoft 
              : (isActive ? AppColors.primarySoft : AppColors.surfaceSunken),
          foregroundColor: isCompleted 
              ? AppColors.success 
              : (isActive ? AppColors.primary : AppColors.ink500),
          disabledBackgroundColor: isCompleted 
              ? AppColors.successSoft 
              : AppColors.surfaceSunken,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isCompleted 
                  ? AppColors.success 
                  : (isActive ? AppColors.primary : Colors.transparent),
              width: isCompleted || isActive ? 2 : 0,
            ),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.check_circle : icon,
              size: 18,
            ),
            const SizedBox(height: 2),
            Text(
              isCompleted ? 'Done' : label,
              style: AppTypography.body(10, weight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}