// lib/screens/home/merchant_dashboard.dart
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../profile/profile_screen.dart';
import '../user/merchant/manage_products.dart';
import '../user/merchant/merchant_orders.dart';

class MerchantDashboard extends StatefulWidget {
  const MerchantDashboard({super.key});

  @override
  State<MerchantDashboard> createState() => _MerchantDashboardState();
}

class _MerchantDashboardState extends State<MerchantDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Store',
          style: AppTypography.display(20, weight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.ink700),
            onPressed: () {
              // TODO: فتح شاشة إضافة منتج
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _MerchantHomeContent(),
          ManageProducts(),
          MerchantOrders(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.ink500,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ✅ محتوى الـ Dashboard للتاجر
class _MerchantHomeContent extends StatelessWidget {
  const _MerchantHomeContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // إحصائيات سريعة
          Row(
            children: [
              _StatCard(
                title: 'Products',
                value: '45',
                icon: Icons.inventory_2,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              _StatCard(
                title: 'Orders',
                value: '28',
                icon: Icons.receipt_long,
                color: AppColors.accent,
              ),
              const SizedBox(width: 12),
              _StatCard(
                title: 'Revenue',
                value: '\$1,250',
                icon: Icons.attach_money,
                color: AppColors.gold,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // آخر الطلبات
          Text(
            'Recent Orders',
            style: AppTypography.display(18, weight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...List.generate(3, (index) => _OrderCard()),
          const SizedBox(height: 24),

          // المنتجات الأكثر مبيعاً
          Text(
            'Top Products',
            style: AppTypography.display(18, weight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...List.generate(3, (index) => _ProductCard()),
        ],
      ),
    );
  }
}

// ✅ بطاقة الإحصائيات
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  value,
                  style: AppTypography.display(18, weight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTypography.body(12, color: AppColors.ink500),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ بطاقة الطلب
class _OrderCard extends StatelessWidget {
  const _OrderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #ORD-2024-001',
                  style: AppTypography.body(14, weight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Customer: Ahmed Mohamed',
                  style: AppTypography.body(12, color: AppColors.ink500),
                ),
                Text(
                  'Total: \$45.00',
                  style: AppTypography.body(12, color: AppColors.ink500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Pending',
              style: AppTypography.body(11, color: AppColors.success, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ بطاقة المنتج
class _ProductCard extends StatelessWidget {
  const _ProductCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fastfood, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pizza Margherita',
                  style: AppTypography.body(14, weight: FontWeight.w600),
                ),
                Text(
                  'Category: Italian Food',
                  style: AppTypography.body(12, color: AppColors.ink500),
                ),
                Text(
                  '\$12.99',
                  style: AppTypography.body(14, weight: FontWeight.w700, color: AppColors.primary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '12 sold',
              style: AppTypography.body(11, color: AppColors.primary, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}