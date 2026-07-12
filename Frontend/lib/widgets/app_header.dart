// lib/widgets/app_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/landing/landing_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/profile/profile_screen.dart'; 
import '../data/models/user_model.dart';

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  final bool isWeb;
  final double padding;

  const AppHeader({super.key, required this.isWeb, required this.padding});

  static const Color brandColor = Color(0xFF006D32);

  @override
  Size get preferredSize => const Size.fromHeight(64);

  void _handleLogout(BuildContext context, WidgetRef ref) async {
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.logout();
    
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LandingScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartProvider).totalCount;
    final authState = ref.watch(authProvider);
    final user = authState.user;

    String displayName = 'Guest';
    if (user != null) {
      final names = user.fullName.split(' ');
      displayName = names.isNotEmpty ? '${names[0]}. ${names.length > 1 ? names[names.length - 1][0] : ''}' : user.fullName;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "PickNGo",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          if (isWeb)
            Container(
              width: 400,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search products, stores...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.black87,
                      size: 22,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                  if (cartCount > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  color: Colors.black87,
                  size: 22,
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                offset: const Offset(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'profile') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  } else if (value == 'orders') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrdersScreen(),
                      ),
                    );
                  } else if (value == 'logout') {
                    _handleLogout(context, ref);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, size: 18, color: Colors.black87),
                        SizedBox(width: 10),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'orders',
                    child: Row(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 18, color: Colors.black87),
                        SizedBox(width: 10),
                        Text('My Orders'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 18, color: Colors.redAccent),
                        SizedBox(width: 10),
                        Text('Log out'),
                      ],
                    ),
                  ),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: brandColor.withOpacity(0.1),
                      child: user != null
                          ? Text(
                              user.fullName.isNotEmpty
                                  ? user.fullName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: brandColor,
                              ),
                            )
                          : const Icon(
                              Icons.person_outline,
                              size: 16,
                              color: brandColor,
                            ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}