// lib/screens/orders/orders_screen.dart

import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../../services/order_service.dart';
import '../../widgets/app_header.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const Color brandColor = Color(0xFF006D32);

  final OrderService _orderService = OrderService();
  bool _isLoading = true;
  String? _errorMessage;
  List<OrderModel> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _orderService.getMyOrders();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result.success) {
        _orders = result.orders;
      } else {
        _errorMessage = result.message;
      }
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Confirmed':
      case 'Preparing':
        return Colors.blue;
      case 'Ready':
      case 'PickedUp':
        return Colors.purple;
      case 'Delivered':
        return brandColor;
      case 'Cancelled':
      case 'Refunded':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 900;
          double padding = isWeb ? constraints.maxWidth * 0.08 : 16.0;

          return Column(
            children: [
              AppHeader(isWeb: isWeb, padding: padding),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: padding,
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Orders',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 60),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (_errorMessage != null)
                            _buildErrorState()
                          else if (_orders.isEmpty)
                            _buildEmptyState()
                          else
                            ..._orders.map(_buildOrderCard),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Text(_errorMessage!, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 12),
            TextButton(onPressed: _loadOrders, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 72, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No orders yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Your past and current orders will show up here',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final color = _statusColor(order.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (order.storeName != null) ...[
            const SizedBox(height: 4),
            Text(
              order.storeName!,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.paymentMethod,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              Text(
                '\$${order.finalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
