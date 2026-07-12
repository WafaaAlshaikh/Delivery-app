// lib/screens/stores/store_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoreDashboardScreen extends ConsumerStatefulWidget {
  const StoreDashboardScreen({super.key});

  @override
  ConsumerState<StoreDashboardScreen> createState() =>
      _StoreDashboardScreenState();
}

class _StoreDashboardScreenState extends ConsumerState<StoreDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const Color brandColor = Color(
    0xFF006D32,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Store Management Panel',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: brandColor,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.playlist_add), text: 'New Orders'),
            Tab(icon: Icon(Icons.restaurant), text: 'Preparing'),
            Tab(icon: Icon(Icons.check_circle_outline), text: 'Ready'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList('Pending'), 
          _buildOrdersList('Preparing'), 
          _buildOrdersList('Ready'),
        ],
      ),
    );
  }

  Widget _buildOrdersList(String status) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 2, 
      itemBuilder: (context, index) {
        return _buildOrderCard(status, index);
      },
    );
  }

  Widget _buildOrderCard(String status, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #102${index + 4}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  status == 'Pending' ? 'Action Required' : 'In Progress',
                  style: TextStyle(
                    color: status == 'Pending' ? Colors.orange : Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  index == 0
                      ? '• 2x Classic Cheeseburger'
                      : '• 1x Pepperoni Pizza Large',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  index == 0
                      ? '• 1x Large Crispy Fries'
                      : '• 2x Garlic Sauce Extra',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.notes, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Note: Deliver as hot as possible.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == 'Pending') ...[
                  TextButton(
                    onPressed: () {
                      // كود رفض الطلب وإلغائه عبر الـ API
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                    ),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // كود قبول الطلب وتحويل حالته إلى 'Preparing'
                    },
                    child: const Text('Accept & Prepare'),
                  ),
                ] else if (status == 'Preparing') ...[
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // كود إنهاء التحضير وتحويل الحالة إلى 'Ready' ليظهر للمندوبين
                    },
                    icon: const Icon(Icons.done, size: 16),
                    label: const Text('Mark as Ready'),
                  ),
                ] else ...[
                  Row(
                    children: [
                      SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.grey[400]),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Waiting for PickNGo driver to pick up...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
