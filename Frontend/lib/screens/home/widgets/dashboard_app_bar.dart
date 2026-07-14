// lib/screens/user/driver/dashboard/widgets/dashboard_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../providers/driver_provider.dart';

class DashboardAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final bool isDesktop;
  final bool isOnline;
  final VoidCallback onToggleOnline;
  final VoidCallback? onToggleSidebar;

  const DashboardAppBar({
    super.key,
    required this.isDesktop,
    required this.isOnline,
    required this.onToggleOnline,
    this.onToggleSidebar,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: onToggleSidebar,
              color: AppColors.ink700,
            ),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.routeGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.delivery_dining,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Deliver',
                style: AppTypography.display(
                  20,
                  weight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const Spacer(),

          if (isDesktop)
            GestureDetector(
              onTap: onToggleOnline,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.successSoft : AppColors.errorSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isOnline ? AppColors.success : AppColors.error,
                        shape: BoxShape.circle,
                        boxShadow: isOnline
                            ? [
                                BoxShadow(
                                  color: AppColors.success.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: AppTypography.body(
                        12,
                        weight: FontWeight.w600,
                        color: isOnline ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (isDesktop) ...[
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // TODO: Open notifications
              },
              color: AppColors.ink700,
            ),
          ],
        ],
      ),
    );
  }
}