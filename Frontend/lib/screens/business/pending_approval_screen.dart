// lib/screens/business/pending_approval_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/colors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/store_provider.dart';
import '../../widgets/custom/custom_button.dart';
import '../welcome_screen.dart';
import 'store_setup_screen.dart';
import 'business_dashboard_screen.dart';

class PendingApprovalScreen extends ConsumerStatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  ConsumerState<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends ConsumerState<PendingApprovalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    await ref.read(storeProvider.notifier).fetchMyStore();
  }

  @override
  Widget build(BuildContext context) {
    final storeState = ref.watch(storeProvider);
    final store = storeState.store;

    if (store != null && store.approvalStatus == 'Verified') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BusinessDashboardScreen()),
        );
      });
    }

    final isRejected = store?.approvalStatus == 'Rejected';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: (isRejected ? Colors.red : AppColors.primary).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isRejected ? Icons.error_outline : Icons.hourglass_top_rounded,
                      size: 64,
                      color: isRejected ? Colors.red : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isRejected ? 'تم رفض طلب محلك' : 'طلبك قيد المراجعة',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isRejected
                        ? 'راجع الملاحظات تحت وعدّل بيانات محلك عشان نقدر نراجعه من جديد.'
                        : 'فريقنا عم يراجع بيانات محلك هلق. لو أكملتي كل البيانات المطلوبة (العنوان، رقم الهاتف، الوصف، الموقع) بينعتمد المتجر تلقائياً خلال ثواني — جربي تحدّثي الحالة.',
                    style: TextStyle(color: Colors.grey[600], height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  if (isRejected && (store?.rejectionReason?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Text(
                        store!.rejectionReason!,
                        style: TextStyle(color: Colors.red.shade700),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  if (isRejected)
                    CustomButton(
                      text: 'تعديل وإعادة التقديم',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StoreSetupScreen(),
                          ),
                        );
                      },
                    )
                  else
                    CustomButton(
                      text: 'تحديث الحالة',
                      isLoading: storeState.isLoading,
                      onPressed: _refresh,
                    ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                        (route) => false,
                      );
                    },
                    child: Text('تسجيل الخروج', style: TextStyle(color: Colors.grey[600])),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}