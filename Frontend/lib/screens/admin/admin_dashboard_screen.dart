// lib/screens/admin/admin_dashboard_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/models/admin_models.dart';
import '../../services/admin_service.dart';
import '../../widgets/app_header.dart';
import '../../utils/admin_report.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const Color brandColor = Color(0xFF006D32);
  static const List<Color> _palette = [
    Color(0xFF16A34A),
    Color(0xFFF97316),
    Color(0xFF3B82F6),
    Color(0xFFA855F7),
    Color(0xFFDC2626),
    Color(0xFF0EA5E9),
    Color(0xFFCA8A04),
  ];

  final _adminService = AdminService();

  int _selectedTab = 0; // 0=Stores 1=Orders 2=Users 3=Categories

  AdminDashboardStats _stats = AdminDashboardStats.empty();
  List<AdminStoreModel> _stores = [];
  List<AdminUserModel> _users = [];
  List<AdminCategoryModel> _categories = [];

  bool _isLoading = true;
  bool _isGeneratingReport = false;
  final Set<String> _busyStoreIds = {};
  final List<_ToastData> _toasts = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
  setState(() => _isLoading = true);
  try {
    final results = await Future.wait([
      _adminService.getDashboardStats(),
      _adminService.getStores(),
      _adminService.getUsers(),
      _adminService.getCategories(),
    ]);
    
    if (!mounted) return;
    
    setState(() {
      _stats = results[0] as AdminDashboardStats;
      _stores = results[1] as List<AdminStoreModel>;
      
      // ✅ إصلاح: تحويل results[2] إلى Map أولاً
      final usersResponse = results[2] as Map<String, dynamic>;
      final usersData = usersResponse['data']?['users'] as List? ?? [];
      _users = usersData.map((u) => AdminUserModel.fromJson(u)).toList();
      
      _categories = results[3] as List<AdminCategoryModel>;
      _isLoading = false;
    });
  } catch (e) {
    print('Error loading data: $e');
    if (!mounted) return;
    setState(() => _isLoading = false);
  }
}

  void _showToast(String message) {
    final toast = _ToastData(message);
    setState(() => _toasts.add(toast));
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _toasts.remove(toast));
    });
  }

  Future<void> _printReport() async {
    setState(() => _isGeneratingReport = true);
    try {
      await printAdminReport(
        stats: _stats,
        stores: _stores,
        users: _users,
        categories: _categories,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      if (mounted) _showToast('Could not generate report');
    } finally {
      if (mounted) setState(() => _isGeneratingReport = false);
    }
  }

  Future<void> _approveStore(AdminStoreModel store) async {
    setState(() => _busyStoreIds.add(store.id));
    final result = await _adminService.approveStore(store.id);
    if (!mounted) return;
    setState(() => _busyStoreIds.remove(store.id));
    if (result.success) {
      _showToast('Store approved');
      _loadAll();
    } else {
      _showToast(result.message.isNotEmpty ? result.message : 'Could not approve store');
    }
  }

  Future<void> _confirmDeleteStore(AdminStoreModel store) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete store'),
        content: Text('Are you sure you want to delete "${store.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busyStoreIds.add(store.id));
    final result = await _adminService.deleteStore(store.id);
    if (!mounted) return;
    setState(() => _busyStoreIds.remove(store.id));
    if (result.success) {
      _showToast('Store deleted');
      _loadAll();
    } else {
      _showToast(result.message.isNotEmpty ? result.message : 'Could not delete store');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWeb = constraints.maxWidth > 900;
                final padding = isWeb ? constraints.maxWidth * 0.06 : 16.0;
                return Column(
                  children: [
                    AppHeader(isWeb: isWeb, padding: padding),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : RefreshIndicator(
                              onRefresh: _loadAll,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.symmetric(horizontal: padding, vertical: 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHeader(),
                                    const SizedBox(height: 24),
                                    _buildStatCards(isWeb),
                                    const SizedBox(height: 20),
                                    _buildChartsRow(isWeb),
                                    const SizedBox(height: 20),
                                    _buildTabsRow(),
                                    const SizedBox(height: 20),
                                    _buildTabContent(),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _toasts.map(_buildToast).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Admin Dashboard', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          SizedBox(height: 2),
          Text('Platform overview and management', style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
      SizedBox(
        width: 160,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: brandColor,
            side: const BorderSide(color: brandColor),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _isGeneratingReport ? null : _printReport,
          icon: _isGeneratingReport
              ? const SizedBox(
                  height: 14,
                  width: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: brandColor),
                )
              : const Icon(Icons.picture_as_pdf_outlined, size: 18),
          label: const Text('Print Report'),
        ),
      ),
    ],
  );
}

  Widget _buildStatCards(bool isWeb) {
    final cards = [
      _StatCard(
        icon: Icons.people_outline,
        iconColor: const Color(0xFF3B82F6),
        value: '${_stats.totalUsers}',
        label: 'Total Users',
      ),
      _StatCard(
        icon: Icons.storefront_outlined,
        iconColor: const Color(0xFFA855F7),
        value: '${_stats.totalStores}',
        label: 'Total Stores',
      ),
      _StatCard(
        icon: Icons.inventory_2_outlined,
        iconColor: const Color(0xFFF97316),
        value: '${_stats.totalOrders}',
        label: 'Total Orders',
      ),
      _StatCard(
        icon: Icons.attach_money,
        iconColor: const Color(0xFF16A34A),
        value: '\$${_stats.revenue.toStringAsFixed(0)}',
        label: 'Revenue',
      ),
    ];

    if (!isWeb) {
      return Column(
        children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList(),
      );
    }
    return Row(
      children: cards
          .map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: c)))
          .toList(),
    );
  }

  Widget _buildChartsRow(bool isWeb) {
    final ordersCard = _ChartCard(
      title: 'Orders by Status',
      child: _stats.ordersByStatus.isEmpty
          ? _emptyChartPlaceholder()
          : _OrdersByStatusList(data: _stats.ordersByStatus),
    );
    final categoriesCard = _ChartCard(
      title: 'Stores by Category',
      child: _categories.where((c) => c.storeCount > 0).isEmpty
          ? _emptyChartPlaceholder()
          : _CategoryPieChart(categories: _categories, palette: _palette),
    );

    if (!isWeb) {
      return Column(children: [ordersCard, const SizedBox(height: 16), categoriesCard]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: ordersCard),
        const SizedBox(width: 16),
        Expanded(child: categoriesCard),
      ],
    );
  }

  Widget _emptyChartPlaceholder() {
    return Container(
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('No data yet', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
    );
  }

  Widget _buildTabsRow() {
    final tabs = [
      'Stores (${_stores.length})',
      'Orders (${_stats.totalOrders})',
      'Users (${_users.length})',
      'Categories (${_categories.length})',
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
      child: Wrap(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 4, bottom: 4),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 1))]
                      : [],
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.black87 : Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildStoresTab();
      case 1:
        return _buildOrdersTab();
      case 2:
        return _buildUsersTab();
      case 3:
        return _buildCategoriesTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStoresTab() {
    if (_stores.isEmpty) {
      return _emptyState('No stores yet');
    }
    return Column(children: _stores.map(_buildStoreRow).toList());
  }

  Widget _buildStoreRow(AdminStoreModel store) {
  final isBusy = _busyStoreIds.contains(store.id);
  final isApproved = store.approvalStatus.toLowerCase() == 'approved';
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 48,
            height: 48,
            child: store.imageUrl.isNotEmpty
                ? Image.network(
                    store.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.storefront_outlined, color: Colors.grey),
                    ),
                  )
                : Container(
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.storefront_outlined, color: Colors.grey),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(store.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 2),
              Text(
                [if (store.category != null) store.category!, store.address].join(' • '),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _statusBadge(store.approvalStatus, isApproved),
        if (!isApproved) ...[
          const SizedBox(width: 8),
          // ✅ لف الزر بـ SizedBox
          SizedBox(
            width: 100,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: isBusy ? null : () => _approveStore(store),
              icon: isBusy
                  ? const SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Approve'),
            ),
          ),
        ],
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: isBusy ? null : () => _confirmDeleteStore(store),
        ),
      ],
    ),
  );
}

  Widget _statusBadge(String status, bool isApproved) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isApproved ? brandColor.withOpacity(0.1) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isApproved ? brandColor : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    if (_stats.totalOrders == 0) {
      return _emptyState('No orders yet');
    }
    return _emptyState('Order management is coming soon');
  }

  Widget _buildUsersTab() {
    if (_users.isEmpty) {
      return _emptyState('No users yet');
    }
    return Column(children: _users.map(_buildUserRow).toList());
  }

  Widget _buildUserRow(AdminUserModel user) {
    final isAdmin = user.role == 'Admin';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: brandColor.withOpacity(0.1),
            child: Icon(Icons.person_outline, color: brandColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(user.email, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isAdmin ? brandColor.withOpacity(0.1) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              user.role,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isAdmin ? brandColor : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    if (_categories.isEmpty) {
      return _emptyState('No categories yet');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 950 ? 3 : (constraints.maxWidth > 650 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.6,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, i) {
            final c = _categories[i];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 6),
                  Text(
                    '${c.storeCount} stores • ${c.productCount} products',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _emptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(child: Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 14))),
    );
  }

  Widget _buildToast(_ToastData toast) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Text(toast.message, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}

class _ToastData {
  final String message;
  _ToastData(this.message);
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({required this.icon, required this.iconColor, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 14),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _OrdersByStatusList extends StatelessWidget {
  final List<AdminOrdersByStatus> data;

  const _OrdersByStatusList({required this.data});

  static const Map<String, Color> _statusColors = {
    'Pending': Color(0xFFF97316),
    'Confirmed': Color(0xFF3B82F6),
    'Preparing': Color(0xFF3B82F6),
    'Ready': Color(0xFFA855F7),
    'PickedUp': Color(0xFFA855F7),
    'Delivered': Color(0xFF16A34A),
    'Cancelled': Color(0xFFDC2626),
    'Refunded': Color(0xFFDC2626),
  };

  @override
  Widget build(BuildContext context) {
    final maxCount = data.map((d) => d.count).fold<int>(0, math.max);
    return Column(
      children: data.map((d) {
        final color = _statusColors[d.status] ?? Colors.grey;
        final ratio = maxCount == 0 ? 0.0 : d.count / maxCount;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(d.status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('${d.count}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final List<AdminCategoryModel> categories;
  final List<Color> palette;

  const _CategoryPieChart({required this.categories, required this.palette});

  @override
  Widget build(BuildContext context) {
    final withStores = categories.where((c) => c.storeCount > 0).toList();
    final total = withStores.fold<int>(0, (sum, c) => sum + c.storeCount);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: CustomPaint(
            painter: _PieChartPainter(
              values: withStores.map((c) => c.storeCount).toList(),
              colors: List.generate(withStores.length, (i) => palette[i % palette.length]),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(withStores.length, (i) {
              final c = withStores[i];
              final percent = total == 0 ? 0 : (c.storeCount / total * 100).round();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: palette[i % palette.length], shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${c.name} (${c.storeCount})',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text('$percent%', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<int> values;
  final List<Color> colors;

  _PieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    double startAngle = -math.pi / 2;

    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * math.pi;
      final paint = Paint()..color = colors[i];
      canvas.drawArc(rect, startAngle, sweep, true, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.colors != colors;
}
