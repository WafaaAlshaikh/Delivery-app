// lib/screens/user/driver/widgets/empty_offers.dart
import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';

class EmptyOffers extends StatelessWidget {
  const EmptyOffers({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: AppColors.ink300,
          ),
          const SizedBox(height: 16),
          Text(
            tr.t('no_offers_available'),
            style: AppTypography.display(20, weight: FontWeight.w700, color: AppColors.ink500),
          ),
          const SizedBox(height: 8),
          Text(
            tr.t('stay_online_for_offers'),
            style: AppTypography.body(14, color: AppColors.ink300),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  tr.t('new_offers_appear_instantly'),
                  style: AppTypography.body(13, color: AppColors.primaryDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}