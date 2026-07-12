// // lib/screens/user/admin/admin_dashboard.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../../../core/localization/app_localizations.dart';
// import '../../../core/theme/colors.dart';
// import '../../../core/theme/typography.dart';
// import '../../../providers/admin_provider.dart';
// import 'widgets/admin_stat_card.dart';
// import 'widgets/admin_shell.dart';
// import 'widgets/admin_side_panel.dart';
// import 'admin_users.dart';
// import 'admin_merchants.dart';
// import 'admin_drivers.dart';
// import 'admin_orders.dart';
// import 'admin_reports.dart';

// class AdminDashboard extends ConsumerStatefulWidget {
//   const AdminDashboard({super.key});

//   @override
//   ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
// }

// class _AdminDashboardState extends ConsumerState<AdminDashboard> {
//   int _currentIndex = 0;

//   List<AdminNavItem> _getNavItems(AppLocalizations tr) {
//     return [
//       AdminNavItem(
//         icon: Icons.dashboard_outlined,
//         activeIcon: Icons.dashboard,
//         label: tr.t('dashboard'),
//       ),
//       AdminNavItem(
//         icon: Icons.people_outlined,
//         activeIcon: Icons.people,
//         label: tr.t('users'),
//       ),
//       AdminNavItem(
//         icon: Icons.storefront_outlined,
//         activeIcon: Icons.storefront,
//         label: tr.t('merchants'),
//       ),
//       AdminNavItem(
//         icon: Icons.delivery_dining_outlined,
//         activeIcon: Icons.delivery_dining,
//         label: tr.t('drivers'),
//       ),
//       AdminNavItem(
//         icon: Icons.receipt_long_outlined,
//         activeIcon: Icons.receipt_long,
//         label: tr.t('orders'),
//       ),
//       AdminNavItem(
//         icon: Icons.analytics_outlined,
//         activeIcon: Icons.analytics,
//         label: tr.t('reports'),
//       ),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     final tr = context.tr;
//     final navItems = _getNavItems(tr);

//     return AdminShell(
//       title: tr.t('admin_panel'),
//       currentIndex: _currentIndex,
//       onIndexChanged: (i) => setState(() => _currentIndex = i),
//       items: navItems,
//       userName: tr.t('admin'),
//       userSubtitle: tr.t('super_admin'),
//       notificationCount: 3,
//       showTopBarSearch: _currentIndex == 0,
//       pages: const [
//         _AdminHomeContent(),
//         AdminUsers(),
//         AdminMerchants(),
//         AdminDrivers(),
//         AdminOrders(),
//         AdminReports(),
//       ],
//     );
//   }
// }

// class _AdminHomeContent extends ConsumerStatefulWidget {
//   const _AdminHomeContent();

//   @override
//   ConsumerState<_AdminHomeContent> createState() => _AdminHomeContentState();
// }

// class _AdminHomeContentState extends ConsumerState<_AdminHomeContent> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.refresh(adminDashboardProvider);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final tr = context.tr;
//     final dashboardAsync = ref.watch(adminDashboardProvider);
//     final width = MediaQuery.of(context).size.width;
//     final isWide = width >= 1100;

//     final mainColumn = _MainColumn(
//       dashboardAsync: dashboardAsync,
//       width: width,
//     );

//     if (!isWide) {
//       return RefreshIndicator(
//         color: AppColors.primary,
//         onRefresh: () async => ref.refresh(adminDashboardProvider),
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.all(20),
//           child: mainColumn,
//         ),
//       );
//     }

//     return RefreshIndicator(
//       color: AppColors.primary,
//       onRefresh: () async => ref.refresh(adminDashboardProvider),
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.all(24),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(flex: 7, child: mainColumn),
//             const SizedBox(width: 20),
//             Expanded(
//               flex: 3,
//               child: dashboardAsync.when(
//                 data: (data) => _RightRail(data: data),
//                 loading: () => const SizedBox.shrink(),
//                 error: (_, __) => const SizedBox.shrink(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _MainColumn extends StatelessWidget {
//   final AsyncValue<Map<String, dynamic>> dashboardAsync;
//   final double width;

//   const _MainColumn({required this.dashboardAsync, required this.width});

//   @override
//   Widget build(BuildContext context) {
//     final tr = context.tr;
//     final columns = width >= 1200 ? 4 : (width >= 800 ? 3 : 2);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         dashboardAsync.when(
//           data: (data) => const _GreetingHero(),
//           loading: () => const _HeaderCardSkeleton(),
//           error: (_, __) => const SizedBox.shrink(),
//         ),
//         const SizedBox(height: 22),

//         Text(
//           tr.t('needs_your_attention'),
//           style: AppTypography.display(16, weight: FontWeight.w700),
//         ),
//         const SizedBox(height: 12),
//         dashboardAsync.when(
//           data: (data) => _AttentionRow(data: data),
//           loading: () => const SizedBox(height: 90),
//           error: (_, __) => const SizedBox.shrink(),
//         ),
//         const SizedBox(height: 24),

//         Text(
//           tr.t('platform_overview'),
//           style: AppTypography.display(18, weight: FontWeight.w700),
//         ),
//         const SizedBox(height: 12),
//         dashboardAsync.when(
//           data: (data) {
//             final users = data['users'] ?? {};
//             final orders = data['orders'] ?? {};
//             final revenue = (data['revenue'] ?? 0).toDouble();
//             final driverStats = data['driverStats'] ?? {};

//             final stats = <Widget>[
//               AdminStatCard(
//                 title: 'total_users',
//                 value: '${users['total'] ?? 0}',
//                 icon: Icons.people,
//                 color: AppColors.roleCustomer,
//               ),
//               AdminStatCard(
//                 title: 'merchants',
//                 value: '${users['merchants'] ?? 0}',
//                 icon: Icons.storefront,
//                 color: AppColors.roleMerchant,
//               ),
//               AdminStatCard(
//                 title: 'drivers',
//                 value: '${users['drivers'] ?? 0}',
//                 icon: Icons.delivery_dining,
//                 color: AppColors.roleDriver,
//               ),
//               AdminStatCard(
//                 title: 'total_orders',
//                 value: '${orders['total'] ?? 0}',
//                 icon: Icons.receipt_long,
//                 color: AppColors.gold,
//               ),
//               AdminStatCard(
//                 title: 'active_orders',
//                 value: '${orders['active'] ?? 0}',
//                 icon: Icons.hourglass_top,
//                 color: AppColors.primary,
//               ),
//               AdminStatCard(
//                 title: 'revenue',
//                 value: '\$${revenue.toStringAsFixed(2)}',
//                 icon: Icons.attach_money,
//                 color: AppColors.success,
//               ),
//               AdminStatCard(
//                 title: 'pending_drivers',
//                 value: '${driverStats['pending'] ?? 0}',
//                 icon: Icons.pending_actions,
//                 color: AppColors.gold,
//               ),
//               AdminStatCard(
//                 title: 'online_drivers',
//                 value: '${driverStats['online'] ?? 0}',
//                 icon: Icons.wifi,
//                 color: AppColors.primary,
//               ),
//             ];

//             final displayStats = width >= 1400 ? stats : stats.take(6).toList();

//             return GridView.count(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               crossAxisCount: width >= 1200 ? 4 : (width >= 800 ? 3 : 2),
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//               childAspectRatio: 1.35,
//               children: displayStats,
//             );
//           },
//           loading: () => const Center(
//             child: Padding(
//               padding: EdgeInsets.all(32),
//               child: CircularProgressIndicator(),
//             ),
//           ),
//           error: (error, stack) => Center(
//             child: Padding(
//               padding: const EdgeInsets.all(32),
//               child: Text(
//                 'Error loading stats: $error',
//                 style: const TextStyle(color: AppColors.error),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 28),

//         dashboardAsync.when(
//           data: (data) {
//             final revenueChart = _RevenueTrendCard(data: data);
//             final statusChart = _OrderStatusCard(data: data);
//             if (width >= 900) {
//               return Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(flex: 3, child: revenueChart),
//                   const SizedBox(width: 16),
//                   Expanded(flex: 2, child: statusChart),
//                 ],
//               );
//             }
//             return Column(children: [revenueChart, const SizedBox(height: 16), statusChart]);
//           },
//           loading: () => const SizedBox.shrink(),
//           error: (_, __) => const SizedBox.shrink(),
//         ),
//         const SizedBox(height: 28),

//         Text(
//           tr.t('recent_orders'),
//           style: AppTypography.display(18, weight: FontWeight.w700),
//         ),
//         const SizedBox(height: 12),
//         dashboardAsync.when(
//           data: (data) {
//             final recentOrders = data['recentOrders'] ?? [];
//             if (recentOrders.isEmpty) {
//               return Container(
//                 padding: const EdgeInsets.all(24),
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: AppColors.border),
//                 ),
//                 child: Text(
//                   tr.t('no_recent_orders'),
//                   style: AppTypography.body(13, color: AppColors.ink500),
//                 ),
//               );
//             }
//             return Column(
//               children: recentOrders.map<Widget>((order) => _RecentOrderCard(order: order)).toList(),
//             );
//           },
//           loading: () => const Center(
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: CircularProgressIndicator(),
//             ),
//           ),
//           error: (_, __) => const SizedBox.shrink(),
//         ),
//       ],
//     );
//   }
// }

// class _GreetingHero extends StatelessWidget {
//   const _GreetingHero();

//   String _greeting(AppLocalizations tr) {
//     final h = DateTime.now().hour;
//     if (h < 12) return tr.t('good_morning');
//     if (h < 17) return tr.t('good_afternoon');
//     return tr.t('good_evening');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final tr = context.tr;

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: AppColors.routeGradient,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.28),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           Positioned(
//             right: -20,
//             top: -30,
//             child: Container(
//               width: 140,
//               height: 140,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.08),
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//           Positioned(
//             right: 30,
//             bottom: -40,
//             child: Container(
//               width: 90,
//               height: 90,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.10),
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '${_greeting(tr)}, ${tr.t('admin')} 👋',
//                       style: AppTypography.display(22, weight: FontWeight.w800, color: Colors.white),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       tr.t('platform_overview_desc'),
//                       style: AppTypography.body(13, color: Colors.white.withOpacity(0.88)),
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         foregroundColor: AppColors.primary,
//                         minimumSize: const Size(0, 40),
//                         padding: const EdgeInsets.symmetric(horizontal: 18),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         elevation: 0,
//                       ),
//                       child: Text(
//                         tr.t('view_full_report'),
//                         style: AppTypography.body(13, weight: FontWeight.w700),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.16),
//                   borderRadius: BorderRadius.circular(18),
//                 ),
//                 child: const Icon(
//                   Icons.route_rounded,
//                   color: Colors.white,
//                   size: 34,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _HeaderCardSkeleton extends StatelessWidget {
//   const _HeaderCardSkeleton();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 150,
//       decoration: BoxDecoration(
//         color: AppColors.surfaceSunken,
//         borderRadius: BorderRadius.circular(24),
//       ),
//       alignment: Alignment.center,
//       child: const CircularProgressIndicator(),
//     );
//   }
// }

// class _AttentionRow extends StatelessWidget {
//   final Map<String, dynamic> data;

//   const _AttentionRow({required this.data});

//   @override
//   Widget build(BuildContext context) {
//     final tr = context.tr;
//     final orders = data['orders'] ?? {};
//     final driverStats = data['driverStats'] ?? {};

//     final items = [
//       _AttentionItem(
//         tr.t('pending_orders'),
//         '${orders['active'] ?? 0}',
//         Icons.hourglass_top,
//         AppColors.primary,
//       ),
//       _AttentionItem(
//         tr.t('driver_applications'),
//         '${driverStats['pending'] ?? 0}',
//         Icons.delivery_dining,
//         AppColors.roleDriver,
//       ),
//       _AttentionItem(
//         tr.t('new_merchants'),
//         '${data['newMerchants'] ?? 0}',
//         Icons.storefront,
//         AppColors.roleMerchant,
//       ),
//       _AttentionItem(
//         tr.t('support_tickets'),
//         '${data['supportTickets'] ?? 0}',
//         Icons.support_agent,
//         AppColors.roleAdmin,
//       ),
//     ];

//     return SizedBox(
//       height: 96,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: items.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (context, i) => _AttentionCard(item: items[i]),
//       ),
//     );
//   }
// }

// class _AttentionItem {
//   final String label;
//   final String value;
//   final IconData icon;
//   final Color color;

//   _AttentionItem(this.label, this.value, this.icon, this.color);
// }

// class _AttentionCard extends StatelessWidget {
//   final _AttentionItem item;

//   const _AttentionCard({required this.item});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 168,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: AppColors.border),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.ink900.withOpacity(0.02),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 34,
//             height: 34,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [item.color, item.color.withOpacity(0.7)],
//               ),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(item.icon, color: Colors.white, size: 17),
//           ),
//           const Spacer(),
//           Text(
//             item.value,
//             style: AppTypography.display(18, weight: FontWeight.w800),
//           ),
//           Text(
//             item.label,
//             style: AppTypography.body(11, color: AppColors.ink500),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _RightRail extends StatelessWidget {
//   final Map<String, dynamic> data;

//   const _RightRail({required this.data});

//   @override
//   Widget build(BuildContext context) {
//     final tr = context.tr;
//     final driverApps = (data['driverApplications'] as List?) ?? [];
//     final newSignups = (data['newSignups'] as List?) ?? [];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const WeekStrip(),
//         const SizedBox(height: 16),

//         QueueCard(
//           title: '${tr.t('driver_applications')} (${driverApps.length})',
//           onViewAll: () {},
//           children: driverApps.isEmpty
//               ? [
//                   _placeholderTile(
//                     tr.t('no_pending_applications'),
//                     tr.t('new_driver_signups_here'),
//                     AppColors.roleDriver,
//                   )
//                 ]
//               : driverApps.map<Widget>((app) => _DriverApplicationTile(application: app)).toList(),
//         ),
//         const SizedBox(height: 16),

//         QueueCard(
//           title: tr.t('new_signups'),
//           onViewAll: () {},
//           children: newSignups.isEmpty
//               ? [
//                   _placeholderTile(
//                     tr.t('no_new_signups'),
//                     tr.t('recent_signups_here'),
//                     AppColors.roleCustomer,
//                   )
//                 ]
//               : newSignups.map<Widget>((u) => PersonQueueTile(
//                     name: u['full_name'] ?? 'Unknown',
//                     subtitle: u['role'] ?? 'Customer',
//                     accent: AppColors.roleCustomer,
//                     onApprove: () {},
//                     onReject: () {},
//                   )).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _placeholderTile(String title, String subtitle, Color color) {
//     return PersonQueueTile(
//       name: '·',
//       subtitle: subtitle,
//       accent: color,
//       onApprove: null,
//       onReject: null,
//     );
//   }
// }

// class _DriverApplicationTile extends ConsumerStatefulWidget {
//   final Map<String, dynamic> application;

//   const _DriverApplicationTile({required this.application});

//   @override
//   ConsumerState<_DriverApplicationTile> createState() => _DriverApplicationTileState();
// }

// class _DriverApplicationTileState extends ConsumerState<_DriverApplicationTile> {
//   bool _isProcessing = false;

//   Future<void> _handleReview(String action) async {
//     final tr = context.tr;
//     if (_isProcessing) return;
//     setState(() => _isProcessing = true);

//     try {
//       final adminService = ref.read(adminServiceProvider);
//       final response = await adminService.reviewDriverApplication(
//         profileId: widget.application['profile_id'],
//         action: action,
//         notes: action == 'approve'
//             ? 'Auto-approved by system'
//             : 'Manual review required',
//       );

//       if (response['success']) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               action == 'approve'
//                   ? '✅ ${tr.t('driver_approved')}'
//                   : '❌ ${tr.t('driver_rejected')}',
//             ),
//             backgroundColor: action == 'approve' ? AppColors.success : AppColors.error,
//           ),
//         );
//         ref.refresh(adminDashboardProvider);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('${tr.t('error')}: ${e.toString()}'),
//           backgroundColor: AppColors.error,
//         ),
//       );
//     }

//     setState(() => _isProcessing = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final tr = context.tr;
//     final user = widget.application['User'] ?? {};
//     final isPending = widget.application['status'] == 'Pending';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isPending ? AppColors.goldSoft : Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isPending ? AppColors.gold : AppColors.border,
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   AppColors.roleDriver,
//                   AppColors.roleDriver.withOpacity(0.7),
//                 ],
//               ),
//               shape: BoxShape.circle,
//             ),
//             alignment: Alignment.center,
//             child: Text(
//               (user['full_name'] ?? '?')[0].toUpperCase(),
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w700,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   user['full_name'] ?? 'Unknown',
//                   style: AppTypography.body(12, weight: FontWeight.w600),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.car_rental_outlined,
//                       size: 10,
//                       color: AppColors.ink500,
//                     ),
//                     const SizedBox(width: 2),
//                     Text(
//                       widget.application['vehicle_type'] ?? 'N/A',
//                       style: AppTypography.body(10, color: AppColors.ink500),
//                     ),
//                     const SizedBox(width: 8),
//                     Icon(
//                       Icons.credit_card_outlined,
//                       size: 10,
//                       color: AppColors.ink500,
//                     ),
//                     const SizedBox(width: 2),
//                     Text(
//                       widget.application['license_number'] ?? 'N/A',
//                       style: AppTypography.body(10, color: AppColors.ink500),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//             decoration: BoxDecoration(
//               color: _getStatusColor(widget.application['status']).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Text(
//               _getStatusText(tr, widget.application['status']),
//               style: AppTypography.body(
//                 9,
//                 weight: FontWeight.w600,
//                 color: _getStatusColor(widget.application['status']),
//               ),
//             ),
//           ),

//           if (isPending && !_isProcessing) ...[
//             const SizedBox(width: 4),
//             GestureDetector(
//               onTap: () => _handleReview('approve'),
//               child: Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   color: AppColors.successSoft,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: const Icon(
//                   Icons.check_rounded,
//                   color: AppColors.success,
//                   size: 14,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 4),
//             GestureDetector(
//               onTap: () => _handleReview('reject'),
//               child: Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   color: AppColors.errorSoft,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: const Icon(
//                   Icons.close_rounded,
//                   color: AppColors.error,
//                   size: 14,
//                 ),
//               ),
//             ),
//           ],

//           if (_isProcessing)
//             const Padding(
//               padding: EdgeInsets.only(left: 8),
//               child: SizedBox(
//                 width: 16,
//                 height: 16,
//                 child: CircularProgressIndicator(strokeWidth: 2),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Color _getStatusColor(String? status) {
//     switch (status) {
//       case 'Active':
//         return AppColors.success;
//       case 'Pending':
//         return AppColors.gold;
//       case 'Rejected':
//         return AppColors.error;
//       case 'Suspended':
//         return AppColors.warning;
//       default:
//         return AppColors.ink500;
//     }
//   }

//   String _getStatusText(AppLocalizations tr, String? status) {
//     switch (status) {
//       case 'Active':
//         return tr.t('status_active');
//       case 'Pending':
//         return tr.t('status_pending');
//       case 'Rejected':
//         return tr.t('status_rejected');
//       case 'Suspended':
//         return tr.t('status_suspended');
//       default:
//         return status ?? 'Unknown';
//     }
//   }
// }

// class _RevenueTrendCard extends StatefulWidget {
//   final Map<String, dynamic> data;

//   const _RevenueTrendCard({required this.data});

//   @override
//   State<_RevenueTrendCard> createState() => _RevenueTrendCardState();
// }

// class _RevenueTrendCardState extends State<_RevenueTrendCard> {
//   bool _showRevenue = true;

//   @override
//   Widget build(BuildContext context) {
//     final tr = context.tr;
//     final raw = widget.data['revenueTrend'] as List?;
//     final bool isEstimate = raw == null || raw.isEmpty;
//     final points = isEstimate
//         ? _estimateFromTotal((widget.data['revenue'] ?? 0).toDouble())
//         : _fromRaw(raw);

//     final maxY = points.isEmpty ? 1.0 : points.map((p) => p.y).reduce((a, b) => a > b ? a : b) * 1.2;

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   tr.t('revenue_trend'),
//                   style: AppTypography.display(15, weight: FontWeight.w700),
//                 ),
//               ),
//               InkWell(
//                 onTap: () => setState(() => _showRevenue = !_showRevenue),
//                 borderRadius: BorderRadius.circular(20),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: _showRevenue ? AppColors.primarySoft : AppColors.surfaceSunken,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: 8,
//                         height: 8,
//                         decoration: const BoxDecoration(
//                           color: AppColors.primary,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         tr.t('revenue'),
//                         style: AppTypography.body(10, weight: FontWeight.w700, color: AppColors.primaryDark),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               if (isEstimate)
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                   decoration: BoxDecoration(
//                     color: AppColors.goldSoft,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     tr.t('estimate'),
//                     style: AppTypography.body(10, weight: FontWeight.w700, color: AppColors.gold),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 18),
//           SizedBox(
//             height: 200,
//             child: !_showRevenue
//                 ? Center(
//                     child: Text(
//                       tr.t('series_hidden'),
//                       style: AppTypography.body(12, color: AppColors.ink500),
//                     ),
//                   )
//                 : LineChart(
//                     LineChartData(
//                       minY: 0,
//                       maxY: maxY <= 0 ? 1 : maxY,
//                       gridData: FlGridData(
//                         show: true,
//                         drawVerticalLine: false,
//                         horizontalInterval: maxY / 4 == 0 ? 1 : maxY / 4,
//                         getDrawingHorizontalLine: (_) => FlLine(
//                           color: AppColors.border,
//                           strokeWidth: 1,
//                         ),
//                       ),
//                       borderData: FlBorderData(show: false),
//                       titlesData: FlTitlesData(
//                         topTitles: const AxisTitles(
//                           sideTitles: SideTitles(showTitles: false),
//                         ),
//                         rightTitles: const AxisTitles(
//                           sideTitles: SideTitles(showTitles: false),
//                         ),
//                         leftTitles: const AxisTitles(
//                           sideTitles: SideTitles(showTitles: false),
//                         ),
//                         bottomTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             reservedSize: 26,
//                             getTitlesWidget: (value, meta) {
//                               final i = value.toInt();
//                               if (i < 0 || i >= points.length) {
//                                 return const SizedBox.shrink();
//                               }
//                               return Padding(
//                                 padding: const EdgeInsets.only(top: 6),
//                                 child: Text(
//                                   points[i].label,
//                                   style: AppTypography.body(10, color: AppColors.ink500),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                       lineTouchData: LineTouchData(
//                         touchTooltipData: LineTouchTooltipData(
//                           getTooltipColor: (_) => AppColors.ink900,
//                           getTooltipItems: (spots) => spots
//                               .map((s) => LineTooltipItem(
//                                     '\$${s.y.toStringAsFixed(0)}',
//                                     const TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.w700,
//                                     ),
//                                   ))
//                               .toList(),
//                         ),
//                       ),
//                       lineBarsData: [
//                         LineChartBarData(
//                           spots: [
//                             for (int i = 0; i < points.length; i++)
//                               FlSpot(i.toDouble(), points[i].y)
//                           ],
//                           isCurved: true,
//                           color: AppColors.primary,
//                           barWidth: 3,
//                           dotData: const FlDotData(show: false),
//                           belowBarData: BarAreaData(
//                             show: true,
//                             gradient: LinearGradient(
//                               begin: Alignment.topCenter,
//                               end: Alignment.bottomCenter,
//                               colors: [
//                                 AppColors.primary.withOpacity(0.22),
//                                 AppColors.primary.withOpacity(0.0),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<_TrendPoint> _fromRaw(List raw) {
//     return raw.map((e) {
//       final m = e as Map;
//       return _TrendPoint(
//         (m['label'] ?? '').toString(),
//         (m['amount'] ?? 0).toDouble(),
//       );
//     }).toList();
//   }

//   List<_TrendPoint> _estimateFromTotal(double total) {
//     final tr = context.tr;
//     final days = [
//       tr.t('mon'),
//       tr.t('tue'),
//       tr.t('wed'),
//       tr.t('thu'),
//       tr.t('fri'),
//       tr.t('sat'),
//       tr.t('sun'),
//     ];
//     final base = total / 7;
//     const weights = [0.7, 0.85, 0.95, 1.0, 1.15, 1.3, 1.05];
//     return [
//       for (int i = 0; i < 7; i++)
//         _TrendPoint(days[i], base * weights[i])
//     ];
//   }
// }

// class _TrendPoint {
//   final String label;
//   final double y;

//   _TrendPoint(this.label, this.y);
// }

// class _OrderStatusCard extends StatelessWidget {
//   final Map<String, dynamic> data;

//   const _OrderStatusCard({required this.data});

//   static const _palette = [
//     AppColors.primary,
//     AppColors.accent,
//     AppColors.gold,
//     AppColors.roleCustomer,
//     AppColors.roleAdmin,
//     AppColors.success,
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final tr = context.tr;
//     final entries = _resolveCounts(tr);

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             tr.t('orders_by_status'),
//             style: AppTypography.display(15, weight: FontWeight.w700),
//           ),
//           const SizedBox(height: 18),
//           if (entries.isEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 24),
//               child: Center(
//                 child: Text(
//                   tr.t('no_data_yet'),
//                   style: AppTypography.body(12, color: AppColors.ink500),
//                 ),
//               ),
//             )
//           else ...[
//             SizedBox(
//               height: 150,
//               child: PieChart(
//                 PieChartData(
//                   sectionsSpace: 3,
//                   centerSpaceRadius: 42,
//                   sections: [
//                     for (int i = 0; i < entries.length; i++)
//                       PieChartSectionData(
//                         value: entries[i].value.toDouble(),
//                         color: _palette[i % _palette.length],
//                         title: '',
//                         radius: 26,
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 14),
//             Wrap(
//               spacing: 12,
//               runSpacing: 8,
//               children: [
//                 for (int i = 0; i < entries.length; i++)
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: 8,
//                         height: 8,
//                         decoration: BoxDecoration(
//                           color: _palette[i % _palette.length],
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         '${entries[i].key} (${entries[i].value})',
//                         style: AppTypography.body(11, color: AppColors.ink700),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   List<MapEntry<String, int>> _resolveCounts(AppLocalizations tr) {
//     final raw = data['ordersByStatus'];
//     if (raw is Map && raw.isNotEmpty) {
//       return raw.entries
//           .map((e) => MapEntry(
//                 _getStatusText(tr, e.key),
//                 (e.value as num).toInt(),
//               ))
//           .toList();
//     }
//     final recent = data['recentOrders'] as List? ?? [];
//     final counts = <String, int>{};
//     for (final o in recent) {
//       final name = (o['OrderStatus']?['name'] ?? 'Unknown').toString();
//       final translated = _getStatusText(tr, name);
//       counts[translated] = (counts[translated] ?? 0) + 1;
//     }
//     return counts.entries.toList();
//   }

//   String _getStatusText(AppLocalizations tr, String status) {
//     switch (status.toLowerCase()) {
//       case 'pending':
//         return tr.t('status_pending');
//       case 'confirmed':
//         return 'Confirmed';
//       case 'preparing':
//         return 'Preparing';
//       case 'ready':
//         return 'Ready';
//       case 'picked up':
//       case 'pickedup':
//         return tr.t('picked_up');
//       case 'on the way':
//       case 'ontheway':
//         return tr.t('on_the_way');
//       case 'delivered':
//         return tr.t('delivered');
//       case 'cancelled':
//         return tr.t('status_cancelled');
//       default:
//         return status;
//     }
//   }
// }

// class _RecentOrderCard extends StatelessWidget {
//   final Map<String, dynamic> order;

//   const _RecentOrderCard({required this.order});

//   @override
//   Widget build(BuildContext context) {
//     final tr = context.tr;
//     final customer = order['Customer'] ?? {};
//     final business = order['Business'] ?? {};
//     final orderStatus = order['OrderStatus'] ?? {};
//     final statusColor = orderStatus['color'] != null
//         ? Color(int.parse(orderStatus['color'].replaceFirst('#', '0xFF')))
//         : AppColors.primary;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppColors.border),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.ink900.withOpacity(0.02),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 42,
//             height: 42,
//             decoration: BoxDecoration(
//               color: statusColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(Icons.receipt_long, color: statusColor),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '${tr.t('order')} #${order['order_id']}',
//                   style: AppTypography.body(14, weight: FontWeight.w600),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   '${customer['full_name'] ?? 'Unknown'} • ${business['name'] ?? 'Unknown Store'}',
//                   style: AppTypography.body(12, color: AppColors.ink500),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   '\$${order['total']?.toStringAsFixed(2) ?? '0.00'}',
//                   style: AppTypography.body(14, weight: FontWeight.w700, color: AppColors.primary),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: statusColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               _getStatusText(tr, orderStatus['name'] ?? 'Unknown'),
//               style: AppTypography.body(10, weight: FontWeight.w600, color: statusColor),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getStatusText(AppLocalizations tr, String status) {
//     switch (status.toLowerCase()) {
//       case 'pending':
//         return tr.t('status_pending');
//       case 'confirmed':
//         return 'Confirmed';
//       case 'preparing':
//         return 'Preparing';
//       case 'ready':
//         return 'Ready';
//       case 'picked up':
//       case 'pickedup':
//         return tr.t('picked_up');
//       case 'on the way':
//       case 'ontheway':
//         return tr.t('on_the_way');
//       case 'delivered':
//         return tr.t('delivered');
//       case 'cancelled':
//         return tr.t('status_cancelled');
//       default:
//         return status;
//     }
//   }
// }