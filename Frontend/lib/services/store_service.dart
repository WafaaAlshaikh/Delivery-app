// lib/services/store_service.dart
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../data/models/store_model.dart';
import '../data/models/product_model.dart';
import '../data/models/category_model.dart';
import 'api_service.dart';

class StoreResult {
  final bool success;
  final String message;
  final StoreModel? store;

  StoreResult({required this.success, required this.message, this.store});
}

class StoreService {
  final ApiService _apiService = ApiService();

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiService.get(ApiConstants.storeCategories);
      final data = response.data;
      if (data['success'] == true && data['categories'] != null) {
        return (data['categories'] as List)
            .map((c) => CategoryModel.fromJson(c))
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('getCategories error: $e');
      return [];
    }
  }

  Future<StoreResult> getMyStore() async {
    try {
      final response = await _apiService.get(ApiConstants.myStore);
      final data = response.data;

      if (data['success'] == true && data['store'] != null) {
        return StoreResult(
          success: true,
          message: '',
          store: StoreModel.fromJson(data['store']),
        );
      }
      return StoreResult(success: true, message: 'no_store', store: null);
    } catch (e) {
      if (kDebugMode) print('getMyStore error: $e');
      return StoreResult(
        success: false,
        message: 'Network error while fetching your store',
      );
    }
  }

  Future<StoreResult> createStore({
  required String name,
  String? description,
  required String categoryId,
  String? cuisineType,
  String? imageUrl,
  required String address,
  required double locationLat,
  required double locationLng,
  required String city,
  required String region,
  required String phone,
  String? email,
  String? openingTime,
  String? closingTime,
}) async {
  try {
    final response = await _apiService.post(
      ApiConstants.stores,
      data: {
        'name': name,
        'description': description,
        'category_id': categoryId,
        'logo': imageUrl,              // ✅ كان 'image_url'
        'address': address,
        'latitude': locationLat,       // ✅ كان 'location_lat'
        'longitude': locationLng,      // ✅ كان 'location_lng'
        'city': city,
        'region': region,
        'phone': phone,
        'email': email,
        'opening_time': openingTime,
        'closing_time': closingTime,
      },
    );

    final data = response.data;
    return StoreResult(
      success: data['success'] ?? false,
      message: data['message'] ?? '',
      store: data['store'] != null
          ? StoreModel.fromJson(data['store'])
          : null,
    );
  } catch (e) {
    if (kDebugMode) print('createStore error: $e');
    return StoreResult(
      success: false,
      message: 'Network error while creating your store',
    );
  }
}

  Future<StoreResult> updateMyStore(Map<String, dynamic> fields) async {
    try {
      final response = await _apiService.put(
        ApiConstants.myStore,
        data: fields,
      );
      final data = response.data;
      return StoreResult(
        success: data['success'] ?? false,
        message: data['message'] ?? '',
        store: data['store'] != null
            ? StoreModel.fromJson(data['store'])
            : null,
      );
    } catch (e) {
      if (kDebugMode) print('updateMyStore error: $e');
      return StoreResult(
        success: false,
        message: 'Network error while updating your store',
      );
    }
  }

  Future<List<ProductModel>> getStoreProducts(String storeId) async {
    try {
      final response = await _apiService.get('${ApiConstants.stores}/$storeId');
      final data = response.data;
      if (data['success'] == true && data['products'] != null) {
        return (data['products'] as List)
            .map((p) => ProductModel.fromJson(p))
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('getStoreProducts error: $e');
      return [];
    }
  }

  Future<StoreResult> addProduct({
    required String storeId,
    required String name,
    String? description,
    String? imageUrl,
    required double price,
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.stores}/$storeId/products',
        data: {
          'name': name,
          'description': description,
          'image_url': imageUrl,
          'price': price,
        },
      );
      final data = response.data;
      return StoreResult(
        success: data['success'] ?? false,
        message: data['message'] ?? '',
      );
    } catch (e) {
      if (kDebugMode) print('addProduct error: $e');
      return StoreResult(
        success: false,
        message: 'Network error while adding product',
      );
    }
  }


  Future<StoreResult> updateProduct({
    required String storeId,
    required String productId,
    required String name,
    String? description,
    String? imageUrl,
    required double price,
    bool? inStock,
  }) async {
    try {
      final response = await _apiService.put(
        '${ApiConstants.stores}/$storeId/products/$productId',
        data: {
          'name': name,
          'description': description,
          'image_url': imageUrl,
          'price': price,
          if (inStock != null) 'in_stock': inStock,
        },
      );
      final data = response.data;
      return StoreResult(
        success: data['success'] ?? false,
        message: data['message'] ?? '',
      );
    } catch (e) {
      if (kDebugMode) print('updateProduct error: $e');
      return StoreResult(
        success: false,
        message: 'Network error while updating product',
      );
    }
  }

  Future<StoreResult> deleteProduct({
    required String storeId,
    required String productId,
  }) async {
    try {
      final response = await _apiService.delete(
        '${ApiConstants.stores}/$storeId/products/$productId',
      );
      final data = response.data;
      return StoreResult(
        success: data['success'] ?? false,
        message: data['message'] ?? '',
      );
    } catch (e) {
      if (kDebugMode) print('deleteProduct error: $e');
      return StoreResult(
        success: false,
        message: 'Network error while deleting product',
      );
    }
  }
}
