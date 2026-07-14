// lib/screens/user/driver/dashboard/widgets/welcome_card.dart
import 'package:flutter/material.dart';
import 'package:frontend/data/models/user_model.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/localization/app_localizations.dart';

class WelcomeCard extends StatelessWidget {
  final UserModel? user;
  final bool isOnline;

  const WelcomeCard({
    super.key,
    required this.user,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final firstName = user?.fullName?.split(' ').first ?? 'Driver';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.routeGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: user?.profileImage != null
                  ? NetworkImage(user!.profileImage!)
                  : null,
              child: user?.profileImage == null
                  ? Text(
                      user?.fullName?.isNotEmpty == true
                          ? user!.fullName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${tr.t('hello_driver').replaceAll('{name}', firstName)} 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${tr.t('status')}: ${tr.t(isOnline ? 'online' : 'offline')}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    const Text(
                      '4.8',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: isOnline ? AppColors.success : AppColors.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        (isOnline ? tr.t('online') : tr.t('offline')).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}