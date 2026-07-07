// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/core/theme/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/typography.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final currentLocale = ref.watch(localeProvider);
    final isArabic = currentLocale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr.t('settings'),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildSectionHeader(tr.t('language')),
          SizedBox(height: 8.h),
          _buildLanguageTile(
            context: context,
            icon: Icons.language_outlined,
            title: tr.t('language'),
            subtitle: isArabic ? 'العربية' : 'English',
            onTap: () => _showLanguageDialog(context),
          ),
          SizedBox(height: 24.h),
          
          _buildSectionHeader('General'),
          SizedBox(height: 8.h),
          _buildSettingsTile(
            icon: Icons.dark_mode_outlined,
            title: tr.t('dark_mode'),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
                // TODO: Implement Dark Mode
              },
              activeColor: AppColors.primary,
            ),
          ),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: tr.t('notifications'),
            trailing: Switch(
              value: _notifications,
              onChanged: (value) {
                setState(() {
                  _notifications = value;
                });
                // TODO: Implement Notifications
              },
              activeColor: AppColors.primary,
            ),
          ),
          SizedBox(height: 24.h),
          
          _buildSectionHeader('Account'),
          SizedBox(height: 8.h),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: tr.t('profile'),
            onTap: () {
              // TODO: Navigate to Profile
            },
          ),
          _buildSettingsTile(
            icon: Icons.history_outlined,
            title: 'Order History',
            onTap: () {
              // TODO: Navigate to Order History
            },
          ),
          _buildSettingsTile(
            icon: Icons.payment_outlined,
            title: 'Payment Methods',
            onTap: () {
              // TODO: Navigate to Payment Methods
            },
          ),
          SizedBox(height: 24.h),
          
          _buildSectionHeader('Support'),
          SizedBox(height: 8.h),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              // TODO: Navigate to Help
            },
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {
              // TODO: Navigate to About
            },
          ),
          _buildSettingsTile(
            icon: Icons.logout_outlined,
            title: tr.t('logout'),
            textColor: Colors.red,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 24.w),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            color: textColor ?? Colors.black87,
          ),
        ),
        trailing: trailing ?? 
            (onTap != null ? Icon(Icons.chevron_right, color: Colors.grey[400]) : null),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      ),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 24.w),
        title: Text(
          title,
          style: TextStyle(fontSize: 14.sp),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
          ],
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final tr = context.tr;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          tr.t('language'),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'العربية',
                style: TextStyle(fontSize: 16.sp),
              ),
              leading: Radio<String>(
                value: 'ar',
                groupValue: currentLocale.languageCode,
                onChanged: (value) {
                  _changeLanguage(value!);
                  Navigator.pop(context);
                },
                activeColor: AppColors.primary,
              ),
            ),
            ListTile(
              title: Text(
                'English',
                style: TextStyle(fontSize: 16.sp),
              ),
              leading: Radio<String>(
                value: 'en',
                groupValue: currentLocale.languageCode,
                onChanged: (value) {
                  _changeLanguage(value!);
                  Navigator.pop(context);
                },
                activeColor: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              tr.t('cancel'),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changeLanguage(String languageCode) {
    ref.read(localeProvider.notifier).setLocale(languageCode);
  }

  void _showLogoutDialog(BuildContext context) {
    final tr = context.tr;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          tr.t('logout'),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              tr.t('cancel'),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement logout
              Navigator.pop(context);
            },
            child: Text(
              tr.t('logout'),
              style: TextStyle(
                color: Colors.red,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}