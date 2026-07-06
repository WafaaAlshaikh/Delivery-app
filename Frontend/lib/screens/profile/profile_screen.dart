// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/models/user_model.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  final UserModel? user;
  final VoidCallback? onLogout;

  const ProfileScreen({
    super.key,
    this.user,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentUser = user ?? authState.user;

    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primarySoft,
            backgroundImage: currentUser.profileImage != null
                ? NetworkImage(currentUser.profileImage!)
                : null,
            child: currentUser.profileImage == null
                ? Text(
                    currentUser.fullName.isNotEmpty
                        ? currentUser.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),

          Text(
            currentUser.fullName,
            style: AppTypography.display(22, weight: FontWeight.w800),
          ),
          const SizedBox(height: 4),

          Text(
            currentUser.email,
            style: AppTypography.body(14, color: AppColors.ink500),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: currentUser.isVerified
                  ? AppColors.successSoft
                  : AppColors.errorSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              currentUser.isVerified ? '✓ Verified' : 'Unverified',
              style: AppTypography.body(
                12,
                weight: FontWeight.w600,
                color: currentUser.isVerified ? AppColors.success : AppColors.error,
              ),
            ),
          ),
          const SizedBox(height: 8),

          if (currentUser.roles.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: currentUser.roles.map((role) {
                Color color;
                switch (role) {
                  case 'Admin':
                    color = AppColors.roleAdmin;
                    break;
                  case 'Merchant':
                    color = AppColors.roleMerchant;
                    break;
                  case 'Driver':
                    color = AppColors.roleDriver;
                    break;
                  default:
                    color = AppColors.roleCustomer;
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    role,
                    style: AppTypography.body(12, weight: FontWeight.w600, color: color),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 32),

          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              // TODO: فتح شاشة تعديل الملف الشخصي
            },
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {
              // TODO: فتح شاشة تغيير كلمة المرور
            },
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined, 
            title: 'Notifications',
            onTap: () {
              // TODO: فتح إعدادات الإشعارات
            },
          ),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              // TODO: فتح شاشة الدعم
            },
          ),
          const SizedBox(height: 32),

          if (onLogout != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text(
                  'Log Out',
                  style: TextStyle(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.ink700),
      title: Text(
        title,
        style: AppTypography.body(14, weight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.ink300),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}