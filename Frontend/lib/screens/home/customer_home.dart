// lib/screens/home/customer_home.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category_model.dart';
import '../../data/models/store_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/user_model.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_header.dart';
import '../stores/stores_screen.dart';
import '../stores/store_detail_screen.dart';
import '../../data/mock_data.dart';

class CustomerHome extends ConsumerStatefulWidget {
  final UserModel user;
  final VoidCallback onLogout;

  const CustomerHome({
    Key? key,
    required this.user,
    required this.onLogout,
  }) : super(key: key);

  @override
  ConsumerState<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends ConsumerState<CustomerHome> {
  bool _isLoading = true;
  List<CategoryModel> _categories = [];
  List<StoreModel> _stores = [];
  List<ProductModel> _products = [];

  Map<String, String> _catMap = {};
  Map<String, String> _storeMap = {};

  final Color brandColor = const Color(0xFF006D32); 

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    _categories = mockCategories;
    _stores = mockStores;
    _products = mockProducts;
    _catMap = mockCatMap;
    _storeMap = mockStoreMap;

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
Widget build(BuildContext context) {
  if (_isLoading) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(brandColor),
        ),
      ),
    );
  }

  return Scaffold(
    backgroundColor: const Color(0xFFFAFAFA),
    body: LayoutBuilder(
      builder: (context, constraints) {
        bool isWeb = constraints.maxWidth > 900;
        double paddingPercent = isWeb ? constraints.maxWidth * 0.08 : 16.0;

        return Column(
          children: [
            AppHeader(
              isWeb: isWeb,
              padding: paddingPercent,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroSection(isWeb, paddingPercent),
                    _buildFeaturesStrip(isWeb, paddingPercent),
                    _buildCategoriesSection(
                      paddingPercent,
                      constraints.maxWidth,
                    ),
                    _buildPopularStoresSection(
                      paddingPercent,
                      constraints.maxWidth,
                    ),
                    _buildTrendingProductsSection(
                      paddingPercent,
                      constraints.maxWidth,
                    ),
                    _buildFooterSection(paddingPercent, isWeb),
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

  Widget _buildHeroSection(bool isWeb, double padding) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            brandColor.withOpacity(0.04),
            Colors.white,
            Colors.orange.shade50.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: isWeb ? 60 : 30,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: brandColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delivery_dining_outlined,
                        size: 16,
                        color: brandColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Fast delivery from local stores",
                        style: TextStyle(
                          color: brandColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: isWeb ? 54 : 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.1,
                      fontFamily: 'sans-serif',
                    ),
                    children: [
                      const TextSpan(text: "Everything you need,\n"),
                      TextSpan(
                        text: "delivered",
                        style: TextStyle(color: const Color(0xFF10B981)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Shop from restaurants, supermarkets, pharmacies, bookstores, and more — all in one place. Delivery or pickup, your choice.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StoresScreen(),
                          ),
                        );
                      },
                      icon: const Text(
                        "Browse Stores",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      label: const Icon(Icons.arrow_forward, size: 16),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StoresScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "View Categories",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isWeb) const Expanded(flex: 1, child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildFeaturesStrip(bool isWeb, double padding) {
    var features = [
      {
        'icon': Icons.local_shipping_outlined,
        'title': 'Fast Delivery',
        'desc': 'From nearby stores',
      },
      {
        'icon': Icons.access_time,
        'title': 'Pickup Ready',
        'desc': 'Skip the wait',
      },
      {
        'icon': Icons.shield_outlined,
        'title': 'Secure Orders',
        'desc': 'Safe & reliable',
      },
    ];

    List<Widget> featureWidgets = features
        .map(
          (f) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: brandColor.withOpacity(0.08),
                child: Icon(f['icon'] as IconData, color: brandColor, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f['title'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    f['desc'] as String,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        )
        .toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
      child: isWeb
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: featureWidgets,
            )
          : Column(
              children: featureWidgets
                  .map(
                    (w) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: w,
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildCategoriesSection(double padding, double width) {
    int crossAxisCount = width > 1100 ? 7 : (width > 700 ? 4 : 3);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Shop by Category",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Find exactly what you need",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StoresScreen(),
                    ),
                  );
                },
                label: const Icon(Icons.chevron_right, size: 14),
                icon: Text(
                  "View all",
                  style: TextStyle(
                    color: brandColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.95,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              var cat = _categories[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StoresScreen(initialCategoryId: cat.id),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: brandColor.withOpacity(0.05),
                        child: Icon(cat.iconData, color: brandColor, size: 20),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        cat.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPopularStoresSection(double padding, double width) {
    int crossAxisCount = width > 950 ? 4 : (width > 650 ? 2 : 1);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Popular Stores",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Top rated by our customers",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StoresScreen(),
                    ),
                  );
                },
                label: const Icon(Icons.chevron_right, size: 14),
                icon: Text(
                  "See all",
                  style: TextStyle(
                    color: brandColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemCount: _stores.length,
            itemBuilder: (context, index) {
              var store = _stores[index];
              final categoryName =
                  _catMap[store.categoryId] ??
                  '';
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StoreDetailScreen(store: store, isGuest: false),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Image.network(
                              store.imageUrl,
                              height: 130,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
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
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                store.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Trusted platform items.",
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    "${store.averageRating}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    " (${store.totalReviews})",
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.grey.shade400,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    store.deliveryTime,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingProductsSection(double padding, double width) {
    int crossAxisCount = width > 950 ? 4 : (width > 650 ? 3 : 2);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Trending Products",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            "Most popular items right now",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.76,
            ),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              var product = _products[index];
              final storeName =
                  _storeMap[product.storeId] ??
                  ''; 
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Image.network(
                          product.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              storeName,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  "${product.averageRating}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "\$${product.price.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    ref
                                        .read(cartProvider.notifier)
                                        .addProduct(product, storeName);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${product.name} added to cart',
                                        ),
                                        duration: const Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    height: 28,
                                    width: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      size: 16,
                                      color: Colors.black54,
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
    );
  }

  Widget _buildFooterSection(double padding, bool isWeb) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 40),
      child: isWeb
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _getFooterColumns(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _getFooterColumns()
                  .map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: c,
                    ),
                  )
                  .toList(),
            ),
    );
  }

  List<Widget> _getFooterColumns() {
    return [
      Theme(
        data: Theme.of(
          context,
        ).copyWith(iconTheme: const IconThemeData(color: Colors.black87)),
        child: SizedBox(
          width: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "PickNGo",
                style: TextStyle(
                  color: brandColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Your one-stop marketplace for local stores.",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
      _buildFooterLinkColumn("Shop", ["Categories", "All Stores"]),
      _buildFooterLinkColumn("Account", ["My Orders", "Cart"]),
      _buildFooterLinkColumn("Business", ["Store Dashboard"]),
    ];
  }

  Widget _buildFooterLinkColumn(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        ...links
            .map(
              (link) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  link,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ),
            )
            .toList(),
      ],
    );
  }
}