// lib/screens/user/admin/widgets/admin_side_panel.dart
import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';

class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    
    final labels = [
      tr.t('mon'),
      tr.t('tue'),
      tr.t('wed'),
      tr.t('thu'),
      tr.t('fri'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                tr.t('this_week'),
                style: AppTypography.display(14, weight: FontWeight.w700),
              ),
              const Spacer(),
              Icon(Icons.calendar_today_outlined, size: 15, color: AppColors.ink500),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (i) {
              final day = monday.add(Duration(days: i));
              final isToday = day.day == now.day && day.month == now.month;
              return Column(
                children: [
                  Text(labels[i], style: AppTypography.body(10, color: AppColors.ink500)),
                  const SizedBox(height: 6),
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: isToday ? AppColors.routeGradient : null,
                      color: isToday ? null : AppColors.surfaceSunken,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${day.day}',
                      style: AppTypography.body(
                        12,
                        weight: FontWeight.w700,
                        color: isToday ? Colors.white : AppColors.ink700,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class PersonQueueTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final Color accent;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const PersonQueueTile({
    super.key,
    required this.name,
    required this.subtitle,
    required this.accent,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [accent, accent.withOpacity(0.7)]),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.body(12.5, weight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: AppTypography.body(11, color: AppColors.ink500),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _MiniIconButton(
            icon: Icons.check_rounded,
            color: AppColors.success,
            onTap: onApprove,
          ),
          const SizedBox(width: 6),
          _MiniIconButton(
            icon: Icons.close_rounded,
            color: AppColors.error,
            onTap: onReject,
          ),
        ],
      ),
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _MiniIconButton({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}

class QueueCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onViewAll;

  const QueueCard({
    super.key,
    required this.title,
    required this.children,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tr.t(title),
                  style: AppTypography.display(14, weight: FontWeight.w700),
                ),
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    tr.t('view_all'),
                    style: AppTypography.body(
                      11,
                      weight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (children.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                tr.t('nothing_here_yet'),
                style: AppTypography.body(12, color: AppColors.ink500),
              ),
            )
          else
            ...children,
        ],
      ),
    );
  }
}