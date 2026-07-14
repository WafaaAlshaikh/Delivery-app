// lib/screens/user/driver/dashboard/widgets/live_status_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';

class LiveStatusCard extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onToggle;
  final Map<String, dynamic> stats;

  const LiveStatusCard({
    super.key,
    required this.isOnline,
    required this.onToggle,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOnline ? AppColors.successSoft : AppColors.errorSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOnline ? AppColors.success : AppColors.error,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isOnline ? AppColors.success : AppColors.error,
              shape: BoxShape.circle,
            ),
            child: isOnline
                ? AnimatedContainer(
                    duration: const Duration(milliseconds: 1500),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 1500),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isOnline ? '🟢 Online' : '🔴 Offline',
                      style: AppTypography.display(
                        14,
                        weight: FontWeight.w700,
                        color: isOnline ? AppColors.success : AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${stats['current_orders'] ?? 0} active',
                        style: AppTypography.body(10, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                Text(
                  isOnline
                      ? 'You are receiving orders'
                      : 'Tap to go online and start earning',
                  style: AppTypography.body(12, color: AppColors.ink500),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isOnline ? AppColors.success : AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (isOnline ? AppColors.success : AppColors.primary)
                        .withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isOnline ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOnline ? 'Pause' : 'Go Online',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}