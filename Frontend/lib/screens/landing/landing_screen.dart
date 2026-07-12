// lib/screens/landing/landing_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/auth/signup_screen.dart';
import '../../core/theme/theme_notifier.dart';
import '../../core/i18n/app_localizations.dart';
import '../../core/i18n/locale_notifier.dart';
import '../../data/models/category_model.dart';
import '../../data/models/store_model.dart';
import '../../data/models/product_model.dart';
import '../../data/mock_data.dart';
import '../stores/stores_screen.dart';
import '../stores/store_detail_screen.dart';
import '../../widgets/login_required_dialog.dart';
import 'widgets/delivery_route_widget.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  bool _isLoading = true;
  List<CategoryModel> _categories = [];
  List<StoreModel> _stores = [];
  List<ProductModel> _products = [];
  Map<String, String> _catMap = {};
  Map<String, String> _storeMap = {};

  final Color brandColor = const Color(0xFF006D32);

  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _forYouKey = GlobalKey();
  final GlobalKey _storesKey = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _pageBg =>
      _isDark ? const Color(0xFF0F1722) : const Color(0xFFFAFAFA);
  Color get _surfaceBg => _isDark ? const Color(0xFF15202B) : Colors.white;
  Color get _textPrimary => _isDark ? Colors.white : Colors.black87;
  Color get _textSecondary =>
      _isDark ? Colors.grey.shade400 : Colors.grey.shade600;
  Color get _borderColor => _isDark ? Colors.white24 : Colors.grey.shade200;
  Color get _borderColorSoft => _isDark ? Colors.white12 : Colors.grey.shade100;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHomeData();
    });
  }

  Future<void> _loadHomeData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _categories = mockCategories;
    _stores = mockStores;
    _products = mockProducts;
    _catMap = mockCatMap;
    _storeMap = mockStoreMap;

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isLoading) {
          setState(() => _isLoading = false);
        }
      });
    }
  }

  void _goToRegister({bool startOnLogin = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ValueNotifier<bool>(_isLoading),
      builder: (context, isLoading, child) {
        if (isLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(brandColor),
              ),
            ),
          );
        }

        final screenSize = MediaQuery.of(context).size;
        final width = screenSize.width;
        final bool isWeb = width > 1000;
        final double padding = (isWeb ? width * 0.08 : 16.0).clamp(16.0, 120.0);

        return Scaffold(
          backgroundColor: _pageBg,
          body: _buildContent(
            isWeb: isWeb,
            padding: padding,
            width: width,
          ),
        );
      },
    );
  }

  Widget _buildContent({
    required bool isWeb,
    required double padding,
    required double width,
  }) {
    return Column(
      children: [
        _buildNavbar(isWeb, padding),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  key: _howItWorksKey,
                  child: _buildHero(isWeb, padding),
                ),
                Container(
                  key: _featuresKey,
                  child: _buildFeaturesStrip(isWeb, padding),
                ),
                _buildCategoriesSection(padding, width),
                Container(
                  key: _storesKey,
                  child: _buildPopularStoresSection(padding, width),
                ),
                Container(
                  key: _forYouKey,
                  child: _buildTrendingProductsSection(padding, width),
                ),
                _buildFooterSection(padding, isWeb),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavbar(bool isWeb, double padding) {
    final locale = ref.watch(localeNotifierProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final tr = (String key) => AppLocalizations.t(locale, key);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 14),
      decoration: BoxDecoration(
        color: _surfaceBg,
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
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
              Text(
                tr('app_name'),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary),
              ),
            ],
          ),
          if (isWeb)
            Row(
              children: [
                _navLink(tr('features'),
                    onTap: () => _scrollToSection(_featuresKey)),
                _navLink(tr('how_it_works'),
                    onTap: () => _scrollToSection(_howItWorksKey)),
                _navLink(tr('for_you'),
                    onTap: () => _scrollToSection(_forYouKey)),
                _navLink(tr('stores'),
                    onTap: () => _scrollToSection(_storesKey)),
              ],
            ),
          Row(
            children: [
              PopupMenuButton<Locale>(
                tooltip: 'Language',
                icon: Icon(Icons.language, color: _textPrimary),
                onSelected: (locale) =>
                    ref.read(localeNotifierProvider.notifier).setLocale(locale),
                itemBuilder: (context) => [
                  PopupMenuItem(
                      value: const Locale('en'),
                      child: Text(tr('language_en'))),
                  PopupMenuItem(
                      value: const Locale('ar'),
                      child: Text(tr('language_ar'))),
                  PopupMenuItem(
                      value: const Locale('fr'),
                      child: Text(tr('language_fr'))),
                ],
              ),
              const SizedBox(width: 8),
              PopupMenuButton<ThemeMode>(
                tooltip: 'Theme',
                icon: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : themeMode == ThemeMode.light
                          ? Icons.light_mode
                          : Icons.brightness_auto,
                  color: _textPrimary,
                ),
                onSelected: (mode) =>
                    ref.read(themeNotifierProvider.notifier).setThemeMode(mode),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: ThemeMode.system, child: Text('System')),
                  const PopupMenuItem(
                      value: ThemeMode.light, child: Text('Light')),
                  const PopupMenuItem(
                      value: ThemeMode.dark, child: Text('Dark')),
                ],
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _goToRegister(startOnLogin: true),
                icon: Icon(Icons.person_outline, size: 16, color: _textPrimary),
                label: Text(
                  tr('log_in'),
                  style: TextStyle(
                      color: _textPrimary, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 0,
                  minimumSize: const Size(120, 40),
                ),
                onPressed: () => _goToRegister(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tr('get_started'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navLink(String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          text,
          style: TextStyle(
            color: _isDark ? Colors.grey.shade300 : Colors.grey[700],
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildHero(bool isWeb, double padding) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            brandColor.withOpacity(_isDark ? 0.12 : 0.06),
            _surfaceBg,
            _isDark ? brandColor.withOpacity(0.05) : Colors.orange.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: isWeb ? 60 : 30,
      ),
      child: Flex(
        direction: isWeb ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment:
            isWeb ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: isWeb ? 1 : 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: brandColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delivery_dining_outlined,
                          size: 16, color: brandColor),
                      const SizedBox(width: 6),
                      const Text(
                        'Fast delivery from local stores',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
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
                      color: _textPrimary,
                      height: 1.1,
                      fontFamily: 'sans-serif',
                    ),
                    children: [
                      const TextSpan(text: 'Everything you need,\n'),
                      TextSpan(
                        text: 'delivered',
                        style: const TextStyle(color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Shop from restaurants, supermarkets, pharmacies, bookstores, and more — all in one place. Delivery or pickup, your choice.',
                  style: TextStyle(
                    fontSize: 16,
                    color: _textSecondary,
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
                        backgroundColor: brandColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => _goToRegister(),
                      icon: const Text(
                        'Browse Stores',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      label: const Icon(Icons.arrow_forward, size: 16),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _textPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        side: BorderSide(
                            color: _isDark
                                ? Colors.white30
                                : Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const StoresScreen(isGuest: true),
                          ),
                        );
                      },
                      child: const Text(
                        'View Categories',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isWeb) const SizedBox(width: 40),
          if (isWeb)
            const Expanded(
              flex: 1,
              child: DeliveryRouteWidget(),
            ),
          if (!isWeb) const SizedBox(height: 30),
          if (!isWeb) const DeliveryRouteWidget(),
        ],
      ),
    );
  }

  Widget _buildFeaturesStrip(bool isWeb, double padding) {
    var features = [
      {
        'icon': Icons.local_shipping_outlined,
        'title': 'Fast Delivery',
        'desc': 'From nearby stores'
      },
      {
        'icon': Icons.access_time,
        'title': 'Pickup Ready',
        'desc': 'Skip the wait'
      },
      {
        'icon': Icons.shield_outlined,
        'title': 'Secure Orders',
        'desc': 'Safe & reliable'
      },
    ];

    List<Widget> featureWidgets = features
        .map((f) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: brandColor.withOpacity(0.08),
                  child:
                      Icon(f['icon'] as IconData, color: brandColor, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f['title'] as String,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: _textPrimary),
                    ),
                    Text(
                      f['desc'] as String,
                      style: TextStyle(color: _textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ))
        .toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surfaceBg,
        border:
            Border.symmetric(horizontal: BorderSide(color: _borderColorSoft)),
      ),
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
      child: isWeb
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: featureWidgets)
          : Column(
              children: featureWidgets
                  .map((w) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: w,
                      ))
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
                  Text(
                    'Shop by Category',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary),
                  ),
                  Text(
                    'Find exactly what you need',
                    style: TextStyle(color: _textSecondary, fontSize: 14),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StoresScreen(isGuest: true),
                  ),
                ),
                label: const Icon(Icons.chevron_right, size: 14),
                icon: Text(
                  'View all',
                  style:
                      TextStyle(color: brandColor, fontWeight: FontWeight.bold),
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
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoresScreen(
                        initialCategoryId: cat.id,
                        isGuest: true,
                      ),
                    ),
                  ),
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
                            fontSize: 12, fontWeight: FontWeight.w600),
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
                  Text(
                    'Popular Stores',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary),
                  ),
                  Text(
                    'Top rated by our customers',
                    style: TextStyle(color: _textSecondary, fontSize: 14),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StoresScreen(isGuest: true),
                  ),
                ),
                label: const Icon(Icons.chevron_right, size: 14),
                icon: Text(
                  'See all',
                  style:
                      TextStyle(color: brandColor, fontWeight: FontWeight.bold),
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
              final categoryName = _catMap[store.categoryId] ?? '';
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        StoreDetailScreen(store: store, isGuest: true),
                  ),
                ),
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
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 130,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.error_outline),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  categoryName,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
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
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Trusted platform items.',
                                style: TextStyle(
                                    color: Colors.grey.shade400, fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 14),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${store.averageRating}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                  Text(
                                    ' (${store.totalReviews})',
                                    style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 11),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(Icons.access_time,
                                      color: Colors.grey.shade400, size: 12),
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
          Text(
            'Trending Products',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: _textPrimary),
          ),
          Text(
            'Most popular items right now',
            style: TextStyle(color: _textSecondary, fontSize: 14),
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
              final storeName = _storeMap[product.storeId] ?? '';
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
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.error_outline),
                          ),
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
                                  fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              storeName,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade400),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 12),
                                const SizedBox(width: 2),
                                Text(
                                  '${product.averageRating}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                InkWell(
                                  onTap: () => showLoginRequiredDialog(context),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    height: 28,
                                    width: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.grey.shade200),
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
      color: _surfaceBg,
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
                  .map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: c,
                      ))
                  .toList(),
            ),
    );
  }

  List<Widget> _getFooterColumns() {
    return [
      SizedBox(
        width: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PickNGo',
              style: TextStyle(
                  color: brandColor, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(
              'Your one-stop marketplace for local stores.',
              style: TextStyle(color: _textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
      _buildFooterLinkColumn('Shop', ['Categories', 'All Stores']),
      _buildFooterLinkColumn('Account', ['Log in', 'Sign up']),
      _buildFooterLinkColumn(
          'Business', ['Become a Store Owner', 'Become a Driver']),
    ];
  }

  Widget _buildFooterLinkColumn(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, color: _textPrimary),
        ),
        const SizedBox(height: 12),
        ...links
            .map((link) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(link,
                      style: TextStyle(color: _textSecondary, fontSize: 13)),
                ))
            .toList(),
      ],
    );
  }
}
