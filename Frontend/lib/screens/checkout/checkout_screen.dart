// lib/screens/checkout/checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/cart_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/order_service.dart';
import '../../widgets/app_header.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  static const Color brandColor = Color(0xFF006D32);

  final _addressController = TextEditingController();
  final _instructionsController = TextEditingController();
  String _paymentMethod = 'Cash';
  bool _isPlacingOrder = false;
  String? _errorMessage;

  final Map<String, String> _paymentLabels = const {
    'Cash': 'Cash on Delivery',
    'CreditCard': 'Credit Card',
    'DebitCard': 'Debit Card',
    'Wallet': 'Wallet',
  };

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user?.locationAddress != null && user!.locationAddress!.isNotEmpty) {
      _addressController.text = user.locationAddress!;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Map<String, List<CartItem>> _groupByStore(List<CartItem> items) {
    final Map<String, List<CartItem>> grouped = {};
    for (final item in items) {
      final key = item.product.storeId.isNotEmpty
          ? item.product.storeId
          : item.storeName;
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }

  Future<void> _placeOrder() async {
    final cart = ref.read(cartProvider);

    if (_addressController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter a delivery address');
      return;
    }
    if (cart.items.isEmpty) {
      setState(() => _errorMessage = 'Your cart is empty');
      return;
    }

    setState(() {
      _isPlacingOrder = true;
      _errorMessage = null;
    });

    final orderService = OrderService();
    final grouped = _groupByStore(cart.items);
    final List<String> placedOrderNumbers = [];
    final List<String> failedStores = [];

    for (final entry in grouped.entries) {
      final storeId = entry.value.first.product.storeId;
      final items = entry.value
          .map((item) => {
                'product_id': item.product.id,
                'quantity': item.quantity,
              })
          .toList();

      final result = await orderService.createOrder(
        storeId: storeId,
        items: items,
        deliveryAddress: _addressController.text.trim(),
        paymentMethod: _paymentMethod,
        specialInstructions: _instructionsController.text.trim().isEmpty
            ? null
            : _instructionsController.text.trim(),
      );

      if (result.success && result.order != null) {
        placedOrderNumbers.add(result.order!.orderNumber);
      } else {
        failedStores.add(entry.value.first.storeName);
      }
    }

    if (!mounted) return;

    setState(() => _isPlacingOrder = false);

    if (placedOrderNumbers.isNotEmpty) {
      ref.read(cartProvider.notifier).clear();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OrderSuccessScreen(
            orderNumbers: placedOrderNumbers,
            hasPartialFailure: failedStores.isNotEmpty,
          ),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Could not place your order. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

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
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: padding,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            foregroundColor: Colors.grey[600],
                          ),
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text(
                            'Back to Cart',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _sectionCard(
                          title: 'Delivery Address',
                          child: TextField(
                            controller: _addressController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Street, building, floor, city...',
                              filled: true,
                              fillColor: const Color(0xFFF7F8F7),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _sectionCard(
                          title: 'Payment Method',
                          child: Column(
                            children: _paymentLabels.entries.map((entry) {
                              return RadioListTile<String>(
                                value: entry.key,
                                groupValue: _paymentMethod,
                                onChanged: (value) {
                                  setState(() => _paymentMethod = value!);
                                },
                                activeColor: brandColor,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  entry.value,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _sectionCard(
                          title: 'Special Instructions (optional)',
                          child: TextField(
                            controller: _instructionsController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'e.g. Leave at the door, call on arrival...',
                              filled: true,
                              fillColor: const Color(0xFFF7F8F7),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _orderSummary(cart.items, cart.totalPrice),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _isPlacingOrder ? null : _placeOrder,
                            child: _isPlacingOrder
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Place Order',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
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

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _orderSummary(List<CartItem> items, double totalPrice) {
    final grouped = _groupByStore(items);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          if (grouped.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Your cart has items from ${grouped.length} stores — '
                'this will create ${grouped.length} separate orders.',
                style: TextStyle(fontSize: 12, color: Colors.orange[800]),
              ),
            ),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity}x ${item.product.name}',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '\$${item.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
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
              const Text('Subtotal', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Delivery fee is calculated per store and added by the server.',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
