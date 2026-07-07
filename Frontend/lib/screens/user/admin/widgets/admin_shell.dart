// lib/screens/user/admin/widgets/admin_shell.dart
import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';

class AdminNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const AdminNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class AdminShell extends StatelessWidget {
  final String title;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final List<AdminNavItem> items;
  final List<Widget> pages;
  final List<Widget>? actions;
  final String userName;
  final String userSubtitle;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final ValueChanged<String>? onSearchChanged;
  final bool showTopBarSearch;

  const AdminShell({
    super.key,
    required this.title,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.items,
    required this.pages,
    this.actions,
    this.userName = 'Admin',
    this.userSubtitle = 'Super Admin',
    this.notificationCount = 0,
    this.onNotificationTap,
    this.onSearchChanged,
    this.showTopBarSearch = true,
  });

  static const double _wideBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _wideBreakpoint;

        if (isWide) {
          return Scaffold(
            backgroundColor: AppColors.canvas,
            body: Row(
              children: [
                _Sidebar(
                  items: items,
                  currentIndex: currentIndex,
                  onIndexChanged: onIndexChanged,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TopBar(
                        title: title,
                        actions: actions,
                        userName: userName,
                        userSubtitle: userSubtitle,
                        notificationCount: notificationCount,
                        onNotificationTap: onNotificationTap,
                        onSearchChanged: showTopBarSearch ? onSearchChanged : null,
                        showSearch: showTopBarSearch,
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: currentIndex,
                          children: pages,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.canvas,
          appBar: AppBar(
            title: Text(
              title,
              style: AppTypography.display(20, weight: FontWeight.w800),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: actions,
          ),
          body: IndexedStack(index: currentIndex, children: pages),
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              height: 68,
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.primarySoft,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return AppTypography.body(
                  11,
                  weight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.primary : AppColors.ink500,
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: onIndexChanged,
              destinations: items
                  .map(
                    (e) => NavigationDestination(
                      icon: Icon(e.icon, color: AppColors.ink500),
                      selectedIcon: Icon(e.activeIcon, color: AppColors.primary),
                      label: tr.t(e.label), 
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}


class _Sidebar extends StatelessWidget {
  final List<AdminNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const _Sidebar({
    required this.items,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    
    return Container(
      width: 240,
      decoration: const BoxDecoration(gradient: AppColors.duskGradient),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.routeGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.route_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    tr.t('admin'),
                    style: AppTypography.display(18, weight: FontWeight.w800, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final selected = index == currentIndex;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => onIndexChanged(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: selected ? Colors.white.withOpacity(0.10) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: selected
                                ? Border.all(color: Colors.white.withOpacity(0.14))
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                selected ? item.activeIcon : item.icon,
                                size: 20,
                                color: selected ? AppColors.primary : Colors.white70,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                tr.t(item.label),
                                style: AppTypography.body(
                                  14,
                                  weight: selected ? FontWeight.w700 : FontWeight.w500,
                                  color: selected ? Colors.white : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tr.t('super_admin'),
                        style: AppTypography.body(12, weight: FontWeight.w600, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final String userName;
  final String userSubtitle;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final ValueChanged<String>? onSearchChanged;
  final bool showSearch;

  const _TopBar({
    required this.title,
    this.actions,
    required this.userName,
    required this.userSubtitle,
    required this.notificationCount,
    this.onNotificationTap,
    this.onSearchChanged,
    required this.showSearch,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(title, style: AppTypography.display(20, weight: FontWeight.w800)),
          const SizedBox(width: 28),
          if (showSearch)
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: TextField(
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: tr.t('search_hint'), 
                    hintStyle: AppTypography.body(13, color: AppColors.ink300),
                    prefixIcon: const Icon(Icons.search, size: 19, color: AppColors.ink300),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
                    ),
                  ),
                ),
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: 16),
          if (actions != null) ...[...actions!, const SizedBox(width: 8)],
          _IconBadgeButton(
            icon: Icons.notifications_none_rounded,
            count: notificationCount,
            onTap: onNotificationTap,
          ),
          const SizedBox(width: 14),
          _ProfileChip(name: userName, subtitle: userSubtitle),
        ],
      ),
    );
  }
}

class _IconBadgeButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback? onTap;

  const _IconBadgeButton({required this.icon, required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.ink700),
            if (count > 0)
              Positioned(
                top: 6,
                right: 7,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final String name;
  final String subtitle;

  const _ProfileChip({required this.name, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(name, style: AppTypography.body(13, weight: FontWeight.w700)),
            Text(subtitle, style: AppTypography.body(11, color: AppColors.ink500)),
          ],
        ),
        const SizedBox(width: 10),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: AppColors.routeGradient,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          alignment: Alignment.center,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ),
      ],
    );
  }
}