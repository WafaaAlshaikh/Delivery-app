// lib/screens/cart/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_provider.dart';
import '../../data/models/cart_item_model.dart';
import '../../widgets/app_header.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  static const Color brandColor = Color(0xFF006D32);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    final Map<String, List<CartItem>> grouped = {};
    for (final item in cart.items) {
      grouped.putIfAbsent(item.storeName, () => []).add(item);
    }

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
                            'Continue Shopping',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your Cart',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${cart.totalCount} item${cart.totalCount == 1 ? '' : 's'}',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            if (cart.items.isNotEmpty)
                              TextButton(
                                onPressed: () => cartNotifier.clear(),
                                child: const Text(
                                  'Clear all',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (cart.isEmpty)
                          _buildEmptyState(context)
                        else ...[
                          ...grouped.entries.map(
                            (entry) => _buildStoreGroup(
                              entry.key,
                              entry.value,
                              cartNotifier,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryCard(context, cart),
                        ],
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

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 72,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Add some products to get started',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: brandColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Browse Stores',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreGroup(
    String storeName,
    List<CartItem> items,
    CartNotifier cartNotifier,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8F7),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Text(
              storeName.isEmpty ? 'Store' : storeName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          ...items.map((item) => _buildItemRow(item, cartNotifier)),
        ],
      ),
    );
  }

  Widget _buildItemRow(CartItem item, CartNotifier cartNotifier) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item.product.imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '\$${item.product.price.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _qtyButton(
                icon: Icons.remove,
                onTap: () => cartNotifier.decrement(item.product.id),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              _qtyButton(
                icon: Icons.add,
                onTap: () => cartNotifier.increment(item.product.id),
              ),
            ],
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 56,
            child: Text(
              '\$${item.subtotal.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
              size: 20,
            ),
            onPressed: () => cartNotifier.removeItem(item.product.id),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 13, color: Colors.black87),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, CartState cart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              Text(
                '\$${cart.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Delivery fees calculated at checkout',
            style: TextStyle(color: Colors.grey[400], fontSize: 11),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${cart.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: brandColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            onPressed: cart.isEmpty
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CheckoutScreen(),
                      ),
                    );
                  },
            icon: const Text(
              'Proceed to Checkout',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            label: const Icon(Icons.arrow_forward, size: 16),
          ),
        ],
      ),
    );
  }
}
