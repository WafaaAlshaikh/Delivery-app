// lib/screens/stores/stores_screen.dart

import 'package:flutter/material.dart';
import '../../data/models/store_model.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_header.dart';
import 'store_detail_screen.dart';

class StoresScreen extends StatefulWidget {
  final String? initialCategoryId; 
  final bool isGuest;

  const StoresScreen({super.key, this.initialCategoryId, this.isGuest = false});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  String? _selectedCategoryId;

  final Color brandColor = const Color(0xFF006D32);

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    final filteredStores = _selectedCategoryId == null
        ? mockStores
        : mockStores.where((s) => s.categoryId == _selectedCategoryId).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 900;
          double padding = isWeb ? constraints.maxWidth * 0.08 : 16.0;
          int crossAxisCount = constraints.maxWidth > 950
              ? 4
              : (constraints.maxWidth > 650 ? 2 : 1);

          return Column(
            children: [
              if (!widget.isGuest)
                AppHeader(isWeb: isWeb, padding: padding)
              else
                _buildGuestTopBar(padding),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: padding,
                    vertical: 24,
                  ),
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
                          'Back',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'All Stores',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${filteredStores.length} store${filteredStores.length == 1 ? '' : 's'} found',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      _buildCategoryChips(),
                      const SizedBox(height: 24),
                      filteredStores.isEmpty
                          ? _buildEmptyState()
                          : _buildStoresGrid(filteredStores, crossAxisCount),
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

  Widget _buildGuestTopBar(double padding) {
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

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip(
            label: 'All',
            isSelected: _selectedCategoryId == null,
            onTap: () => setState(() => _selectedCategoryId = null),
          ),
          const SizedBox(width: 8),
          ...mockCategories.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _chip(
                label: cat.name,
                isSelected: _selectedCategoryId == cat.id,
                onTap: () => setState(() => _selectedCategoryId = cat.id),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? brandColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? brandColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.storefront_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No stores in this category yet',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoresGrid(List<StoreModel> stores, int crossAxisCount) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        final categoryName = mockCatMap[store.categoryId] ?? '';
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    StoreDetailScreen(store: store, isGuest: widget.isGuest),
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
                          'Trusted platform items.',
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
                              '${store.averageRating}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              ' (${store.totalReviews})',
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
    );
  }
}
