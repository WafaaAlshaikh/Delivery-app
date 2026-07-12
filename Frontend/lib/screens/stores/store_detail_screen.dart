// lib/screens/stores/store_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/store_model.dart';
import '../../data/mock_data.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/login_required_dialog.dart';

class StoreDetailScreen extends ConsumerWidget {
  final StoreModel store;
  final bool isGuest;

  const StoreDetailScreen({
    super.key,
    required this.store,
    this.isGuest = false,
  });

  static const Color brandColor = Color(0xFF006D32);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = productsForStore(store.id);
    final categoryName = mockCatMap[store.categoryId] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 900;
          double padding = isWeb ? constraints.maxWidth * 0.08 : 16.0;
          int crossAxisCount = constraints.maxWidth > 950
              ? 4
              : (constraints.maxWidth > 650 ? 3 : 2);

          return Column(
            children: [
              if (!isGuest)
                AppHeader(isWeb: isWeb, padding: padding)
              else
                _buildGuestTopBar(context, padding),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStoreHeader(context, categoryName, padding),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: padding,
                          vertical: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Menu',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            products.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 40,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'No products yet',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ),
                                  )
                                : GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                          childAspectRatio: 0.76,
                                        ),
                                    itemCount: products.length,
                                    itemBuilder: (context, index) {
                                      final product = products[index];
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade100,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Image.network(
                                                  product.imageUrl,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  12.0,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      product.name,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      product.description,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors
                                                            .grey
                                                            .shade400,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                          size: 12,
                                                        ),
                                                        const SizedBox(
                                                          width: 2,
                                                        ),
                                                        Text(
                                                          '${product.averageRating}',
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 11,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          '\$${product.price.toStringAsFixed(2)}',
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15,
                                                              ),
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            if (isGuest) {
                                                              showLoginRequiredDialog(
                                                                context,
                                                              );
                                                              return;
                                                            }
                                                            ref
                                                                .read(
                                                                  cartProvider
                                                                      .notifier,
                                                                )
                                                                .addProduct(
                                                                  product,
                                                                  store.name,
                                                                );
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  '${product.name} added to cart',
                                                                ),
                                                                duration:
                                                                    const Duration(
                                                                      seconds:
                                                                          1,
                                                                    ),
                                                                behavior:
                                                                    SnackBarBehavior
                                                                        .floating,
                                                              ),
                                                            );
                                                          },
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                          child: Container(
                                                            height: 28,
                                                            width: 28,
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              border: Border.all(
                                                                color: Colors
                                                                    .grey
                                                                    .shade200,
                                                              ),
                                                            ),
                                                            child: const Icon(
                                                              Icons.add,
                                                              size: 16,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGuestTopBar(BuildContext context, double padding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: brandColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'PickNGo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreHeader(
    BuildContext context,
    String categoryName,
    double padding,
  ) {
    return Stack(
      children: [
        Image.network(
          store.imageUrl,
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 16,
          left: padding,
          child: SafeArea(
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, size: 18),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  store.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      '${store.averageRating}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      ' (${store.totalReviews})',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.access_time,
                      color: Colors.white70,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      store.deliveryTime,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.delivery_dining_outlined,
                      color: Colors.white70,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      store.deliveryFee,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
