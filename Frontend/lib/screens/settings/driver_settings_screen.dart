// lib/screens/settings/driver_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

class DriverSettingsScreen extends ConsumerStatefulWidget {
  const DriverSettingsScreen({super.key});

  @override
  ConsumerState<DriverSettingsScreen> createState() => _DriverSettingsScreenState();
}

class _DriverSettingsScreenState extends ConsumerState<DriverSettingsScreen> {
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
          style: AppTypography.display(18, weight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(tr.t('language')),
          const SizedBox(height: 8),
          _buildLanguageTile(
            context: context,
            icon: Icons.language_outlined,
            title: tr.t('language'),
            subtitle: isArabic ? 'العربية' : 'English',
            onTap: () => _showLanguageDialog(),
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('General'),
          const SizedBox(height: 8),
          _buildSettingsTile(
            icon: Icons.dark_mode_outlined,
            title: tr.t('dark_mode'),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: (value) {
                setState(() => _isDarkMode = value);
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
                setState(() => _notifications = value);
                // TODO: Implement Notifications
              },
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Account'),
          const SizedBox(height: 8),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: tr.t('profile'),
            onTap: () {
              // TODO: Navigate to Profile
            },
          ),
          _buildSettingsTile(
            icon: Icons.history_outlined,
            title: tr.t('order_history'),
            onTap: () {
              // TODO: Navigate to Order History
            },
          ),
          _buildSettingsTile(
            icon: Icons.payment_outlined,
            title: tr.t('payment_methods'),
            onTap: () {
              // TODO: Navigate to Payment Methods
            },
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Support'),
          const SizedBox(height: 8),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: tr.t('help_support'),
            onTap: () {
              // TODO: Navigate to Help & Support
            },
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: tr.t('about'),
            onTap: () {
              // TODO: Navigate to About
            },
          ),
          _buildSettingsTile(
            icon: Icons.logout_outlined,
            title: tr.t('logout'),
            textColor: Colors.red,
            onTap: () => _showLogoutDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
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
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 24),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: textColor ?? Colors.black87,
          ),
        ),
        trailing: trailing ?? 
            (onTap != null ? Icon(Icons.chevron_right, color: Colors.grey[400]) : null),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 24),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
          ],
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  void _showLanguageDialog() {
    final currentLocale = ref.watch(localeProvider);
    final tr = context.tr;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          tr.t('select_language'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('العربية'),
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
              title: const Text('English'),
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
                fontSize: 14,
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

  void _showLogoutDialog() {
    final tr = context.tr;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          tr.t('logout'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(tr.t('logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              tr.t('cancel'),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
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
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}