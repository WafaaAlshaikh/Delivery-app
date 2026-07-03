// lib/screens/admin/admin_merchants.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../providers/admin_provider.dart';

class AdminMerchants extends ConsumerWidget {
  const AdminMerchants({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final merchantsAsync = ref.watch(adminMerchantsProvider);
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: isWide
          ? null
          : AppBar(
              title: Text('Merchants', style: AppTypography.display(18, weight: FontWeight.w700)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})],
            ),
      body: merchantsAsync.when(
        data: (merchants) {
          if (merchants.isEmpty) {
            return Center(child: Text('No merchants found', style: AppTypography.body(13, color: AppColors.ink500)));
          }

          if (isWide) {
            return GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.55,
              ),
              itemCount: merchants.length,
              itemBuilder: (context, index) => _MerchantCard(merchant: merchants[index]),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: merchants.length,
            itemBuilder: (context, index) => _MerchantCard(merchant: merchants[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error', style: const TextStyle(color: AppColors.error)),
        ),
      ),
    );
  }
}

class _MerchantCard extends StatelessWidget {
  final Map<String, dynamic> merchant;

  const _MerchantCard({required this.merchant});

  @override
  Widget build(BuildContext context) {
    final business = merchant['business'] ?? {};
    final isActive = merchant['is_active'] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: AppColors.ink900.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.roleMerchant, AppColors.roleMerchant.withOpacity(0.7)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.storefront, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(merchant['full_name'] ?? 'Unknown', style: AppTypography.body(14, weight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                    Text(merchant['email'] ?? '', style: AppTypography.body(12, color: AppColors.ink500), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.successSoft : AppColors.errorSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: AppTypography.body(10, weight: FontWeight.w600, color: isActive ? AppColors.success : AppColors.error),
                ),
              ),
            ],
          ),
          if (business['name'] != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.store_mall_directory_outlined, size: 14, color: AppColors.accentDark),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      business['name'],
                      style: AppTypography.body(12, weight: FontWeight.w600, color: AppColors.accentDark),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}