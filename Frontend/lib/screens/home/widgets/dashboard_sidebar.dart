// lib/screens/user/driver/dashboard/widgets/dashboard_sidebar.dart
import 'package:flutter/material.dart';
import 'package:frontend/data/models/user_model.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/localization/app_localizations.dart';

class DashboardSidebar extends StatelessWidget {
  final UserModel? user;
  final int currentIndex;
  final bool isOnline;
  final bool isMobile;
  final VoidCallback? onClose;
  final void Function(int) onNavigate;
  final VoidCallback onLogout;

  const DashboardSidebar({
    super.key,
    required this.user,
    required this.currentIndex,
    required this.isOnline,
    required this.onNavigate,
    required this.onLogout,
    this.isMobile = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final width = isMobile ? 280.0 : 260.0;

    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: AppColors.duskGradient,
        borderRadius: isMobile
            ? const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              )
            : BorderRadius.zero,
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (isMobile)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: onClose,
                ),
              ),

            _buildProfile(tr),

            const SizedBox(height: 8),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _SidebarItem(
                    icon: Icons.dashboard_outlined,
                    label: tr.t('dashboard'),
                    isSelected: currentIndex == 0,
                    onTap: () => onNavigate(0),
                  ),
                  _SidebarItem(
                    icon: Icons.local_shipping_outlined,
                    label: tr.t('available_orders'),
                    isSelected: currentIndex == 1,
                    onTap: () => onNavigate(1),
                  ),
                  _SidebarItem(
                    icon: Icons.delivery_dining_outlined,
                    label: tr.t('my_deliveries'),
                    isSelected: currentIndex == 2,
                    onTap: () => onNavigate(2),
                  ),
                  _SidebarItem(
                    icon: Icons.attach_money_outlined,
                    label: tr.t('Earnings'),
                    isSelected: currentIndex == 3,
                    onTap: () => onNavigate(3),
                  ),
                  _SidebarItem(
                    icon: Icons.navigation_outlined,
                    label: tr.t('current_delivery'),
                    isSelected: currentIndex == 4,
                    onTap: () => onNavigate(4),
                  ),
                  _SidebarItem(
                    icon: Icons.person_outline,
                    label: tr.t('profile'),
                    isSelected: false,
                    onTap: () => onNavigate(5),
                  ),
                  _SidebarItem(
                    icon: Icons.settings_outlined,
                    label: tr.t('settings'),
                    isSelected: false,
                    onTap: () => onNavigate(6),
                  ),
                ],
              ),
            ),

            _buildMoreSection(tr),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(AppLocalizations tr) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppColors.routeGradient,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 34,
              backgroundColor: Colors.transparent,
              backgroundImage: user?.profileImage != null
                  ? NetworkImage(user!.profileImage!)
                  : null,
              child: user?.profileImage == null
                  ? Text(
                      user?.fullName?.isNotEmpty == true
                          ? user!.fullName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user?.fullName ?? 'Driver',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isOnline ? AppColors.success : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isOnline ? tr.t('online') : tr.t('offline'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreSection(AppLocalizations tr) {
    return Column(
      children: [
        const Divider(color: Colors.white24, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              tr.t('more'),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        _SidebarItem(
          icon: Icons.star_outline,
          label: tr.t('ratings'),
          isSelected: false,
          onTap: () => onNavigate(7),
        ),
        _SidebarItem(
          icon: Icons.calendar_today_outlined,
          label: tr.t('scheduling'),
          isSelected: false,
          onTap: () => onNavigate(8),
        ),
        _SidebarItem(
          icon: Icons.notifications_outlined,
          label: tr.t('notifications'),
          isSelected: false,
          onTap: () => onNavigate(9),
        ),
        _SidebarItem(
          icon: Icons.chat_outlined,
          label: tr.t('communication'),
          isSelected: false,
          onTap: () => onNavigate(10),
        ),
        const Divider(color: Colors.white24, height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _SidebarItem(
            icon: Icons.logout_rounded,
            label: tr.t('logout'),
            isSelected: false,
            isDestructive: true,
            onTap: onLogout,
          ),
        ),
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDestructive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: Colors.white.withOpacity(0.2)) : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? AppColors.error
                    : (isSelected ? Colors.white : Colors.white70),
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isDestructive
                        ? AppColors.error
                        : (isSelected ? Colors.white : Colors.white70),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}