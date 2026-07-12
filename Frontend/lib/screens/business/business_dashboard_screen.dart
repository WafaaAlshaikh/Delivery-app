// lib/screens/business/business_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/store_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/store_provider.dart';
import '../../services/order_service.dart';
import '../../services/store_service.dart';
import '../../widgets/custom/custom_button.dart';
import '../../widgets/custom/custom_text_field.dart';
import '../welcome_screen.dart';
import 'store_setup_screen.dart';

class BusinessDashboardScreen extends ConsumerStatefulWidget {
  const BusinessDashboardScreen({super.key});

  @override
  ConsumerState<BusinessDashboardScreen> createState() =>
      _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState
    extends ConsumerState<BusinessDashboardScreen> {
  static const Color brandColor = Color(0xFF1B835A);

  int _selectedTab = 0; 

  final _orderService = OrderService();
  final _storeService = StoreService();

  List<OrderModel> _orders = [];
  List<ProductModel> _products = [];
  bool _isLoadingOrders = true;
  bool _isLoadingProducts = true;
  bool _storeCheckDone = false; 

  final List<_ToastData> _toasts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(storeProvider.notifier).fetchMyStore();
      if (!mounted) return;
      setState(() => _storeCheckDone = true);
      _loadOrders();
      _loadProducts();
    });
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoadingOrders = true);
    final result = await _orderService.getMyOrders();
    if (!mounted) return;
    setState(() {
      _isLoadingOrders = false;
      if (result.success) _orders = result.orders;
    });
  }

  Future<void> _loadProducts() async {
    final storeId = ref.read(storeProvider).store?.id;
    if (storeId == null) return;
    setState(() => _isLoadingProducts = true);
    final products = await _storeService.getStoreProducts(storeId);
    if (!mounted) return;
    setState(() {
      _products = products;
      _isLoadingProducts = false;
    });
  }

  void _showToast(String message) {
    final toast = _ToastData(message);
    setState(() => _toasts.add(toast));
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _toasts.remove(toast));
    });
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeState = ref.watch(storeProvider);
    final store = storeState.store;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          SafeArea(
            child: !_storeCheckDone && store == null
                ? const Center(child: CircularProgressIndicator())
                : store == null
                ? _buildNoStoreYet()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final padding = constraints.maxWidth > 900
                          ? constraints.maxWidth * 0.06
                          : 20.0;
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: padding,
                          vertical: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(store),
                            const SizedBox(height: 24),
                            _buildStatCards(store),
                            const SizedBox(height: 20),
                            _buildTabsRow(),
                            const SizedBox(height: 20),
                            _buildTabContent(store),
                          ],
                        ),
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
              children: _toasts.map((t) => _buildToast(t)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoStoreYet() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: brandColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.storefront, color: brandColor, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              "You don't have a store yet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Set up your storefront to start receiving orders.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 220,
              child: CustomButton(
                text: 'Create your store',
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StoreSetupScreen()),
                  );
                  if (!mounted) return;
                  ref.read(storeProvider.notifier).fetchMyStore();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(StoreModel store) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              store.name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Store Dashboard',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        Row(
          children: [
            _buildStatusBadge(store.approvalStatus),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black54, size: 20),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String? status) {
    final isPending = (status ?? 'Pending').toLowerCase() == 'pending';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPending
            ? const Color(0xFFEFF3FA)
            : brandColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPending ? 'Pending Approval' : (status ?? ''),
        style: TextStyle(
          color: isPending ? const Color(0xFF334155) : brandColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatCards(StoreModel store) {
    final totalOrders = _orders.length;
    final revenue = _orders.fold<double>(0, (sum, o) => sum + (o.finalAmount));

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 650;
        final cards = [
          _StatCard(
            icon: Icons.inventory_2_outlined,
            iconColor: const Color(0xFF3B82F6),
            iconBg: const Color(0xFF3B82F6).withOpacity(0.1),
            value: '$totalOrders',
            label: 'Total Orders',
          ),
          _StatCard(
            icon: Icons.attach_money,
            iconColor: const Color(0xFF16A34A),
            iconBg: const Color(0xFF16A34A).withOpacity(0.1),
            value: '\$${revenue.toStringAsFixed(2)}',
            label: 'Revenue',
          ),
          _StatCard(
            icon: Icons.shopping_bag_outlined,
            iconColor: const Color(0xFFA855F7),
            iconBg: const Color(0xFFA855F7).withOpacity(0.1),
            value: '${_products.length}',
            label: 'Products',
          ),
          _StatCard(
            icon: Icons.star_outline,
            iconColor: const Color(0xFFF97316),
            iconBg: const Color(0xFFF97316).withOpacity(0.1),
            value: store.averageRating.toStringAsFixed(1),
            label: 'Rating',
          ),
        ];

        if (isNarrow) {
          return Column(
            children: cards
                .map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: c,
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: cards
              .map(
                (c) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: c,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildTabsRow() {
    final tabs = [
      'Orders (${_orders.length})',
      'Products (${_products.length})',
      'Settings',
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
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

  Widget _buildTabContent(StoreModel store) {
    switch (_selectedTab) {
      case 0:
        return _OrdersTabContent(
          orders: _orders,
          isLoading: _isLoadingOrders,
          brandColor: brandColor,
          orderService: _orderService,
          onChanged: () {
            _loadOrders();
          },
          onToast: _showToast,
        );
      case 1:
        return _buildProductsTab(store);
      case 2:
        return _SettingsForm(
          store: store,
          storeService: _storeService,
          brandColor: brandColor,
          onSaved: () {
            _showToast('Store updated');
            ref.read(storeProvider.notifier).fetchMyStore();
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildProductsTab(StoreModel store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: brandColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            onPressed: () => _openProductDialog(store),
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'Add Product',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (_isLoadingProducts)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 80),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_products.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 80),
            child: Center(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  children: [
                    const TextSpan(text: 'No products yet. Add your '),
                    TextSpan(
                      text: 'first product!',
                      style: TextStyle(
                        color: brandColor,
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _openProductDialog(store),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 950
                  ? 4
                  : (constraints.maxWidth > 650 ? 3 : 2);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.78,
                ),
                itemCount: _products.length,
                itemBuilder: (context, i) {
                  final p = _products[i];
                  return _ProductCard(
                    product: p,
                    brandColor: brandColor,
                    onEdit: () => _openProductDialog(store, existing: p),
                    onDelete: () => _confirmDeleteProduct(store, p),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  void _openProductDialog(StoreModel store, {ProductModel? existing}) {
    showDialog(
      context: context,
      builder: (context) => _ProductFormDialog(
        storeId: store.id,
        existing: existing,
        brandColor: brandColor,
        storeService: _storeService,
        onSuccess: (isEdit) {
          Navigator.pop(context);
          _showToast(isEdit ? 'Product updated' : 'Product added');
          _loadProducts();
        },
        onError: (message) {
          _showToast(message);
        },
      ),
    );
  }

  Future<void> _confirmDeleteProduct(
    StoreModel store,
    ProductModel product,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await _storeService.deleteProduct(
      storeId: store.id,
      productId: product.id,
    );
    if (!mounted) return;
    if (result.success) {
      _showToast('Product deleted');
      _loadProducts();
    } else {
      _showToast(result.message.isNotEmpty ? result.message : 'Delete failed');
    }
  }

  Widget _buildToast(_ToastData toast) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        toast.message,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ToastData {
  final String message;
  _ToastData(this.message);
}

class _OrdersTabContent extends StatefulWidget {
  final List<OrderModel> orders;
  final bool isLoading;
  final Color brandColor;
  final OrderService orderService;
  final VoidCallback onChanged;
  final ValueChanged<String> onToast;

  const _OrdersTabContent({
    required this.orders,
    required this.isLoading,
    required this.brandColor,
    required this.orderService,
    required this.onChanged,
    required this.onToast,
  });

  @override
  State<_OrdersTabContent> createState() => _OrdersTabContentState();
}

class _OrdersTabContentState extends State<_OrdersTabContent> {
  final Set<String> _updatingIds = {};

  static const Map<String, String> _nextStatus = {
    'Pending': 'Confirmed',
    'Confirmed': 'Preparing',
    'Preparing': 'Ready',
  };

  static const Map<String, String> _nextActionLabel = {
    'Pending': 'Confirm order',
    'Confirmed': 'Start preparing',
    'Preparing': 'Mark as ready',
  };

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFF97316); 
      case 'Confirmed':
      case 'Preparing':
        return const Color(0xFF3B82F6); 
      case 'Ready':
      case 'PickedUp':
        return const Color(0xFFA855F7); 
      case 'Delivered':
        return widget.brandColor;
      case 'Cancelled':
      case 'Refunded':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    const labels = {
      'Pending': 'Pending',
      'Confirmed': 'Confirmed',
      'Preparing': 'Preparing',
      'Ready': 'Ready for pickup',
      'PickedUp': 'With driver',
      'Delivered': 'Delivered',
      'Cancelled': 'Cancelled',
      'Refunded': 'Refunded',
    };
    return labels[status] ?? status;
  }

  Future<void> _updateStatus(OrderModel order, String newStatus) async {
    setState(() => _updatingIds.add(order.id));
    final result = await widget.orderService.updateOrderStatus(
      orderId: order.id,
      status: newStatus,
    );
    if (!mounted) return;
    setState(() => _updatingIds.remove(order.id));

    if (result.success) {
      widget.onToast(
        newStatus == 'Cancelled'
            ? 'Order cancelled'
            : 'Order marked as ${_statusLabel(newStatus)}',
      );
      widget.onChanged();
    } else {
      widget.onToast(
        result.message.isNotEmpty ? result.message : 'Could not update order',
      );
    }
  }

  Future<void> _confirmCancel(OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel order'),
        content: Text(
          'Are you sure you want to cancel order ${order.orderNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Back'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Yes, cancel',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _updateStatus(order, 'Cancelled');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.orders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: Center(
          child: Text(
            'No orders yet',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
      );
    }

    final activeStatuses = {
      'Pending',
      'Confirmed',
      'Preparing',
      'Ready',
      'PickedUp',
    };
    final active = widget.orders
        .where((o) => activeStatuses.contains(o.status))
        .toList();
    final past = widget.orders
        .where((o) => !activeStatuses.contains(o.status))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (active.isNotEmpty) ...[
          const Text(
            'Active orders',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...active.map(_buildOrderCard),
        ],
        if (past.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Order history',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...past.map(_buildOrderCard),
        ],
      ],
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final color = _statusColor(order.status);
    final isUpdating = _updatingIds.contains(order.id);
    final nextStatus = _nextStatus[order.status];
    final canCancel = !{
      'Delivered',
      'Cancelled',
      'Refunded',
      'PickedUp',
    }.contains(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderNumber,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(order.status),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '${item.quantity}x ${item.name}',
                style: const TextStyle(fontSize: 12.5),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            order.deliveryAddress,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${order.finalAmount.toStringAsFixed(2)} • ${order.paymentMethod}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Row(
                children: [
                  if (canCancel)
                    TextButton(
                      onPressed: isUpdating
                          ? null
                          : () => _confirmCancel(order),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  if (nextStatus != null) ...[
                    const SizedBox(width: 6),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.brandColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: isUpdating
                          ? null
                          : () => _updateStatus(order, nextStatus),
                      child: isUpdating
                          ? const SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_nextActionLabel[order.status] ?? 'Update'),
                    ),
                  ] else if (order.status == 'Ready' ||
                      order.status == 'PickedUp') ...[
                    Text(
                      order.status == 'Ready'
                          ? 'Waiting for a driver to pick up...'
                          : 'On its way with the driver...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
  });

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
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final Color brandColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.brandColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.5,
            child: product.imageUrl.isNotEmpty
                ? Image.network(product.imageUrl, fit: BoxFit.cover)
                : Container(
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.image_outlined, color: Colors.grey),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (product.inStock)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: brandColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'In Stock',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Out of Stock',
                          style: TextStyle(fontSize: 10, color: Colors.black87),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 14),
                        label: const Text(
                          'Edit',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: BorderSide(color: Colors.red.shade100),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onDelete,
                      child: const Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Colors.redAccent,
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

class _ProductFormDialog extends StatefulWidget {
  final String storeId;
  final ProductModel? existing;
  final Color brandColor;
  final StoreService storeService;
  final ValueChanged<bool> onSuccess; 
  final ValueChanged<String> onError;

  const _ProductFormDialog({
    required this.storeId,
    required this.existing,
    required this.brandColor,
    required this.storeService,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _imageCtrl;
  bool _inStock = true;
  bool _isSubmitting = false;

  bool get _isEdit => widget.existing != null;

  bool get _isValid =>
      _nameCtrl.text.trim().isNotEmpty &&
      double.tryParse(_priceCtrl.text.trim()) != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(text: p?.price.toString() ?? '');
    _imageCtrl = TextEditingController(text: p?.imageUrl ?? '');
    _inStock = p?.inStock ?? true;

    for (final c in [_nameCtrl, _descCtrl, _priceCtrl, _imageCtrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_isValid) return;
    setState(() => _isSubmitting = true);

    final price = double.parse(_priceCtrl.text.trim());

    final result = _isEdit
        ? await widget.storeService.updateProduct(
            storeId: widget.storeId,
            productId: widget.existing!.id,
            name: _nameCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            price: price,
            imageUrl: _imageCtrl.text.trim(),
            inStock: _inStock,
          )
        : await widget.storeService.addProduct(
            storeId: widget.storeId,
            name: _nameCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            price: price,
          );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.success) {
      widget.onSuccess(_isEdit);
    } else {
      widget.onError(
        result.message.isNotEmpty ? result.message : 'Something went wrong',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEdit ? 'Edit Product' : 'Add Product',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _nameCtrl,
                label: 'Name *',
                hint: 'e.g. Margherita Pizza',
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _descCtrl,
                label: 'Description',
                hint: '',
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _priceCtrl,
                label: 'Price *',
                hint: '0.00',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _imageCtrl,
                label: 'Image URL',
                hint: 'https://...',
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Checkbox(
                    value: _inStock,
                    activeColor: widget.brandColor,
                    onChanged: (v) => setState(() => _inStock = v ?? true),
                  ),
                  const Text('In Stock', style: TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isValid
                        ? widget.brandColor
                        : widget.brandColor.withOpacity(0.4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  onPressed: (_isValid && !_isSubmitting) ? _submit : null,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isEdit ? 'Update Product' : 'Add Product',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsForm extends StatefulWidget {
  final StoreModel store;
  final StoreService storeService;
  final Color brandColor;
  final VoidCallback onSaved;

  const _SettingsForm({
    required this.store,
    required this.storeService,
    required this.brandColor,
    required this.onSaved,
  });

  @override
  State<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<_SettingsForm> {
  late TextEditingController _descCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _openingTimeCtrl;
  late TextEditingController _closingTimeCtrl;
  late TextEditingController _imageCtrl;

  // ⚠️ الحقول التالية (المدينة + رسوم التوصيل حسب المنطقة + Delivery/Pickup)
  // مش موجودة أصلاً بـ StoreModel/StoreService الحاليين عندك. سايبة الواجهة
  // موجودة زي ما طلبتي بالتصميم، وبترسل قيمها ضمن updateMyStore(fields)
  // كمفاتيح إضافية بالـ Map — بس لازم الباك إند يدعمها وتضيفيها لـ
  // StoreModel.fromJson/toJson حتى ترجع وتظهر صح بعد الـ refresh، وإلا رح
  // تنرجع لقيمها الافتراضية بكل مرة تفتحي فيها الشاشة من جديد.
  late TextEditingController _insideCtrl;
  late TextEditingController _outsideCtrl;
  late TextEditingController _occupiedCtrl;
  String? _selectedCity;
  bool _supportsDelivery = true;
  bool _supportsPickup = true;

  bool _isSaving = false;

  final List<String> _cities = const [
    'رام الله والبيرة',
    'نابلس',
    'الخليل',
    'جنين',
    'طولكرم',
    'قلقيلية',
    'بيت لحم',
    'أريحا',
    'سلفيت',
    'طوباس',
    'غزة',
    'خان يونس',
    'رفح',
    'دير البلح',
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.store;
    _descCtrl = TextEditingController(text: s.description);
    _addressCtrl = TextEditingController(text: s.address);
    _phoneCtrl = TextEditingController(text: s.phone);
    _emailCtrl = TextEditingController(text: s.email);
    _openingTimeCtrl = TextEditingController(text: s.openingTime ?? '');
    _closingTimeCtrl = TextEditingController(text: s.closingTime ?? '');
    _imageCtrl = TextEditingController(text: s.imageUrl);

    // ما في مصدر حقيقي إلها بالموديل الحالي، فبتبلّش بقيم افتراضية بس
    _insideCtrl = TextEditingController(text: '10');
    _outsideCtrl = TextEditingController(text: '20');
    _occupiedCtrl = TextEditingController(text: '70');
    _selectedCity = null;
    _supportsDelivery = true;
    _supportsPickup = true;
  }

  @override
  void dispose() {
    for (final c in [
      _descCtrl,
      _addressCtrl,
      _phoneCtrl,
      _emailCtrl,
      _openingTimeCtrl,
      _closingTimeCtrl,
      _imageCtrl,
      _insideCtrl,
      _outsideCtrl,
      _occupiedCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final result = await widget.storeService.updateMyStore({
      'description': _descCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'opening_time': _openingTimeCtrl.text.trim(),
      'closing_time': _closingTimeCtrl.text.trim(),
      'image_url': _imageCtrl.text.trim(),
      // ⚠️ حقول إضافية مش مدعومة لسا بـ StoreModel — راجعي الملاحظة فوق
      'city': _selectedCity,
      'delivery_fee_inside': double.tryParse(_insideCtrl.text) ?? 10,
      'delivery_fee_outside': double.tryParse(_outsideCtrl.text) ?? 20,
      'delivery_fee_occupied': double.tryParse(_occupiedCtrl.text) ?? 70,
      'is_delivery': _supportsDelivery,
      'is_pickup': _supportsPickup,
    });

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result.success) {
      widget.onSaved();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message.isNotEmpty ? result.message : 'Save failed',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = widget.store.approvalStatus.toLowerCase() == 'pending';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.access_time,
                  color: Colors.orange,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.store.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Pending admin approval',
                      style: TextStyle(color: widget.brandColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (isPending)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF3FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _descCtrl,
                label: 'Description',
                hint: '',
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              _twoCol(
                CustomTextField(
                  controller: _addressCtrl,
                  label: 'Address',
                  hint: 'Street, city',
                ),
                CustomTextField(
                  controller: _phoneCtrl,
                  label: 'Phone',
                  hint: '+970...',
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(height: 16),
              _twoCol(
                CustomTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  hint: 'store@example.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                CustomTextField(
                  controller: _imageCtrl,
                  label: 'Image URL',
                  hint: 'https://...',
                ),
              ),
              const SizedBox(height: 16),
              _twoCol(
                CustomTextField(
                  controller: _openingTimeCtrl,
                  label: 'Opening time',
                  hint: 'e.g. 09:00',
                ),
                CustomTextField(
                  controller: _closingTimeCtrl,
                  label: 'Closing time',
                  hint: 'e.g. 22:00',
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Delivery area pricing',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Set your store location and the delivery fee for each destination type. Customers pick their area at checkout and the matching fee applies.',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'Store location (city)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              _CityDropdown(
                hint: 'Select your city',
                value: _selectedCity,
                items: _cities,
                brandColor: widget.brandColor,
                onChanged: (val) => setState(() => _selectedCity = val),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _insideCtrl,
                      label: 'Inside city (\$)',
                      hint: '10',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _outsideCtrl,
                      label: 'Outside city (\$)',
                      hint: '20',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _occupiedCtrl,
                      label: 'Occupied territories (\$)',
                      hint: '70',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Switch(
                    value: _supportsDelivery,
                    activeColor: widget.brandColor,
                    onChanged: (v) => setState(() => _supportsDelivery = v),
                  ),
                  const Text(
                    'Supports delivery',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: 20),
                  Switch(
                    value: _supportsPickup,
                    activeColor: widget.brandColor,
                    onChanged: (v) => setState(() => _supportsPickup = v),
                  ),
                  const Text('Supports pickup', style: TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Save changes',
                isLoading: _isSaving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _twoCol(Widget field1, Widget field2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: field1),
        const SizedBox(width: 16),
        Expanded(child: field2),
      ],
    );
  }
}

class _CityDropdown extends StatefulWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final Color brandColor;
  final ValueChanged<String?> onChanged;

  const _CityDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.brandColor,
    required this.onChanged,
  });

  @override
  State<_CityDropdown> createState() => _CityDropdownState();
}

class _CityDropdownState extends State<_CityDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggle() => _isOpen ? _close() : _open();

  void _open() {
    final box = context.findRenderObject() as RenderBox;
    final size = box.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _close,
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 6),
            child: Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                child: Container(
                  width: size.width,
                  constraints: const BoxConstraints(maxHeight: 260),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    shrinkWrap: true,
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      final isSelected = item == widget.value;
                      return InkWell(
                        onTap: () {
                          widget.onChanged(item);
                          _close();
                        },
                        child: Container(
                          width: double.infinity,
                          color: isSelected ? widget.brandColor : Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isOpen ? widget.brandColor : Colors.grey.shade300,
              width: _isOpen ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.value ?? widget.hint,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.value != null
                        ? Colors.black87
                        : Colors.grey[400],
                  ),
                ),
              ),
              Icon(
                _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
