// lib/data/mock_data.dart

import 'models/category_model.dart';
import 'models/store_model.dart';
import 'models/product_model.dart';

final List<CategoryModel> mockCategories = [
  CategoryModel(id: 'cat_1', name: 'Restaurants', icon: 'UtensilsCrossed'),
  CategoryModel(id: 'cat_2', name: 'Supermarkets', icon: 'ShoppingCart'),
  CategoryModel(id: 'cat_3', name: 'Pharmacies', icon: 'Pill'),
  CategoryModel(id: 'cat_4', name: 'Clothing', icon: 'Shirt'),
  CategoryModel(id: 'cat_5', name: 'Bookstores', icon: 'BookOpen'),
  CategoryModel(id: 'cat_6', name: 'Bakeries & Desserts', icon: 'Cake'),
  CategoryModel(id: 'cat_7', name: 'Electronics', icon: 'Smartphone'),
];

final List<StoreModel> mockStores = [
  StoreModel(
    id: 'store_1',
    name: 'Bella Italia',
    categoryId: 'cat_1',
    imageUrl:
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500&q=80',
    averageRating: 4.5,
    totalReviews: 128,
    deliveryTime: '30 min',
    deliveryFee: '\$3.99',
  ),
  StoreModel(
    id: 'store_2',
    name: 'Burger House',
    categoryId: 'cat_1',
    imageUrl:
        'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=500&q=80',
    averageRating: 4.3,
    totalReviews: 96,
    deliveryTime: '25 min',
    deliveryFee: '\$2.99',
  ),

  StoreModel(
    id: 'store_3',
    name: 'FreshMart',
    categoryId: 'cat_2',
    imageUrl:
        'https://images.unsplash.com/photo-1542838132-92c53300491e?w=500&q=80',
    averageRating: 4.6,
    totalReviews: 210,
    deliveryTime: '15 min',
    deliveryFee: '\$1.49',
  ),
  StoreModel(
    id: 'store_4',
    name: 'Green Basket',
    categoryId: 'cat_2',
    imageUrl:
        'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=500&q=80',
    averageRating: 4.4,
    totalReviews: 143,
    deliveryTime: '20 min',
    deliveryFee: '\$1.99',
  ),

  StoreModel(
    id: 'store_5',
    name: 'HealthPlus Pharmacy',
    categoryId: 'cat_3',
    imageUrl:
        'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&q=80',
    averageRating: 4.7,
    totalReviews: 89,
    deliveryTime: '10 min',
    deliveryFee: '\$1.99',
  ),
  StoreModel(
    id: 'store_6',
    name: 'CarePoint Pharmacy',
    categoryId: 'cat_3',
    imageUrl:
        'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?w=500&q=80',
    averageRating: 4.5,
    totalReviews: 61,
    deliveryTime: '15 min',
    deliveryFee: '\$1.79',
  ),

  StoreModel(
    id: 'store_7',
    name: 'Urban Style',
    categoryId: 'cat_4',
    imageUrl:
        'https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?w=500&q=80',
    averageRating: 4.4,
    totalReviews: 76,
    deliveryTime: '40 min',
    deliveryFee: '\$3.49',
  ),
  StoreModel(
    id: 'store_8',
    name: 'Classic Threads',
    categoryId: 'cat_4',
    imageUrl:
        'https://images.unsplash.com/photo-1445205170230-053b83016050?w=500&q=80',
    averageRating: 4.2,
    totalReviews: 54,
    deliveryTime: '35 min',
    deliveryFee: '\$3.29',
  ),

  StoreModel(
    id: 'store_9',
    name: 'The Book Nook',
    categoryId: 'cat_5',
    imageUrl:
        'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=500&q=80',
    averageRating: 4.8,
    totalReviews: 312,
    deliveryTime: '10 min',
    deliveryFee: '\$2.49',
  ),
  StoreModel(
    id: 'store_10',
    name: 'Pages & Ink',
    categoryId: 'cat_5',
    imageUrl:
        'https://images.unsplash.com/photo-1521123845560-14093637aa7d?w=500&q=80',
    averageRating: 4.6,
    totalReviews: 118,
    deliveryTime: '20 min',
    deliveryFee: '\$2.29',
  ),

  StoreModel(
    id: 'store_11',
    name: 'Sweet Dreams Bakery',
    categoryId: 'cat_6',
    imageUrl:
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&q=80',
    averageRating: 4.6,
    totalReviews: 187,
    deliveryTime: '25 min',
    deliveryFee: '\$2.99',
  ),
  StoreModel(
    id: 'store_12',
    name: 'Golden Crust',
    categoryId: 'cat_6',
    imageUrl:
        'https://images.unsplash.com/photo-1509440159596-1234509440159?w=500&q=80',
    averageRating: 4.5,
    totalReviews: 92,
    deliveryTime: '30 min',
    deliveryFee: '\$2.79',
  ),

  StoreModel(
    id: 'store_13',
    name: 'TechZone',
    categoryId: 'cat_7',
    imageUrl:
        'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=500&q=80',
    averageRating: 4.7,
    totalReviews: 154,
    deliveryTime: '35 min',
    deliveryFee: '\$2.99',
  ),
  StoreModel(
    id: 'store_14',
    name: 'Gadget Hub',
    categoryId: 'cat_7',
    imageUrl:
        'https://images.unsplash.com/photo-1526406915894-7bcd65f60845?w=500&q=80',
    averageRating: 4.4,
    totalReviews: 88,
    deliveryTime: '40 min',
    deliveryFee: '\$3.49',
  ),
];

final List<ProductModel> mockProducts = [
  ProductModel(
    id: 'p1',
    name: 'Margherita Pizza',
    description: 'Classic pizza with fresh mozzarella and basil',
    storeId: 'store_1',
    imageUrl:
        'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&q=80',
    price: 12.99,
    averageRating: 4.7,
    totalReviews: 45,
  ),
  ProductModel(
    id: 'p2',
    name: 'Tiramisu',
    description: 'Classic Italian coffee-flavored dessert',
    storeId: 'store_1',
    imageUrl:
        'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=500&q=80',
    price: 8.99,
    averageRating: 4.8,
    totalReviews: 28,
  ),
  ProductModel(
    id: 'p3',
    name: 'Pasta Carbonara',
    description: 'Creamy egg-based pasta with pancetta',
    storeId: 'store_1',
    imageUrl:
        'https://images.unsplash.com/photo-1612874742237-6526221588e3?w=500&q=80',
    price: 14.99,
    averageRating: 4.5,
    totalReviews: 32,
  ),

  ProductModel(
    id: 'p4',
    name: 'Classic Cheeseburger',
    description: 'Beef patty with cheddar and house sauce',
    storeId: 'store_2',
    imageUrl:
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80',
    price: 9.99,
    averageRating: 4.4,
    totalReviews: 61,
  ),
  ProductModel(
    id: 'p5',
    name: 'Crispy Fries',
    description: 'Golden crispy potato fries',
    storeId: 'store_2',
    imageUrl:
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=500&q=80',
    price: 3.99,
    averageRating: 4.3,
    totalReviews: 40,
  ),

  ProductModel(
    id: 'p6',
    name: 'Organic Bananas (1kg)',
    description: 'Fresh organic bananas',
    storeId: 'store_3',
    imageUrl:
        'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=500&q=80',
    price: 2.49,
    averageRating: 4.6,
    totalReviews: 58,
  ),
  ProductModel(
    id: 'p7',
    name: 'Whole Milk (1L)',
    description: 'Fresh whole milk',
    storeId: 'store_3',
    imageUrl:
        'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=500&q=80',
    price: 1.99,
    averageRating: 4.5,
    totalReviews: 44,
  ),

  ProductModel(
    id: 'p8',
    name: 'Mixed Vegetables Box',
    description: 'Seasonal fresh vegetables',
    storeId: 'store_4',
    imageUrl:
        'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500&q=80',
    price: 6.99,
    averageRating: 4.4,
    totalReviews: 37,
  ),

  ProductModel(
    id: 'p9',
    name: 'First Aid Kit',
    description: 'Complete emergency first aid kit',
    storeId: 'store_5',
    imageUrl:
        'https://images.unsplash.com/photo-1603398938378-e54eab446dde?w=500&q=80',
    price: 24.99,
    averageRating: 4.8,
    totalReviews: 19,
  ),
  ProductModel(
    id: 'p10',
    name: 'Vitamin C 1000mg',
    description: 'Immune-boosting vitamin C supplement, 60 tablets',
    storeId: 'store_5',
    imageUrl:
        'https://images.unsplash.com/photo-1550572017-edd951b55104?w=500&q=80',
    price: 12.99,
    averageRating: 4.6,
    totalReviews: 55,
  ),

  ProductModel(
    id: 'p11',
    name: 'Pain Relief Gel',
    description: 'Fast-acting topical pain relief',
    storeId: 'store_6',
    imageUrl:
        'https://images.unsplash.com/photo-1631815589968-fdb09a223b1e?w=500&q=80',
    price: 7.49,
    averageRating: 4.3,
    totalReviews: 22,
  ),

  ProductModel(
    id: 'p12',
    name: 'Cotton T-Shirt',
    description: 'Soft everyday cotton t-shirt',
    storeId: 'store_7',
    imageUrl:
        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500&q=80',
    price: 19.99,
    averageRating: 4.4,
    totalReviews: 31,
  ),
  ProductModel(
    id: 'p13',
    name: 'Denim Jacket',
    description: 'Classic blue denim jacket',
    storeId: 'store_7',
    imageUrl:
        'https://images.unsplash.com/photo-1551537482-f2075a1d41f2?w=500&q=80',
    price: 45.99,
    averageRating: 4.6,
    totalReviews: 27,
  ),

  ProductModel(
    id: 'p14',
    name: 'Wool Scarf',
    description: 'Warm knitted wool scarf',
    storeId: 'store_8',
    imageUrl:
        'https://images.unsplash.com/photo-1520903920243-32b3ac2fbcaf?w=500&q=80',
    price: 15.99,
    averageRating: 4.2,
    totalReviews: 18,
  ),

  ProductModel(
    id: 'p15',
    name: 'The Great Gatsby',
    description: 'Classic novel by F. Scott Fitzgerald',
    storeId: 'store_9',
    imageUrl:
        'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=500&q=80',
    price: 9.99,
    averageRating: 4.9,
    totalReviews: 87,
  ),
  ProductModel(
    id: 'p16',
    name: 'Milk and Honey',
    description: 'Poetry collection by Rupi Kaur',
    storeId: 'store_9',
    imageUrl:
        'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=500&q=80',
    price: 11.99,
    averageRating: 4.8,
    totalReviews: 64,
  ),

  ProductModel(
    id: 'p17',
    name: 'Notebook Set (3-pack)',
    description: 'Hardcover lined notebooks',
    storeId: 'store_10',
    imageUrl:
        'https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=500&q=80',
    price: 13.99,
    averageRating: 4.5,
    totalReviews: 21,
  ),

  ProductModel(
    id: 'p18',
    name: 'Chocolate Cake',
    description: 'Rich double-layer chocolate cake',
    storeId: 'store_11',
    imageUrl:
        'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=500&q=80',
    price: 28.99,
    averageRating: 4.8,
    totalReviews: 43,
  ),
  ProductModel(
    id: 'p19',
    name: 'Croissant',
    description: 'Buttery, flaky French croissant',
    storeId: 'store_11',
    imageUrl:
        'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=500&q=80',
    price: 3.49,
    averageRating: 4.7,
    totalReviews: 56,
  ),

  ProductModel(
    id: 'p20',
    name: 'Sourdough Loaf',
    description: 'Freshly baked artisan sourdough',
    storeId: 'store_12',
    imageUrl:
        'https://images.unsplash.com/photo-1585478259715-4d3b3c1e1a1e?w=500&q=80',
    price: 6.49,
    averageRating: 4.6,
    totalReviews: 33,
  ),

  ProductModel(
    id: 'p21',
    name: 'Wireless Headphones',
    description: 'Noise-cancelling over-ear headphones',
    storeId: 'store_13',
    imageUrl:
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&q=80',
    price: 59.99,
    averageRating: 4.7,
    totalReviews: 71,
  ),
  ProductModel(
    id: 'p22',
    name: 'Phone Charger Cable',
    description: 'Fast-charging USB-C cable',
    storeId: 'store_13',
    imageUrl:
        'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=500&q=80',
    price: 9.99,
    averageRating: 4.4,
    totalReviews: 48,
  ),

  ProductModel(
    id: 'p23',
    name: 'Bluetooth Speaker',
    description: 'Portable waterproof speaker',
    storeId: 'store_14',
    imageUrl:
        'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=500&q=80',
    price: 34.99,
    averageRating: 4.5,
    totalReviews: 39,
  ),
];

final Map<String, String> mockCatMap = {
  for (var c in mockCategories) c.id: c.name,
};
final Map<String, String> mockStoreMap = {
  for (var s in mockStores) s.id: s.name,
};

List<ProductModel> productsForStore(String storeId) {
  return mockProducts.where((p) => p.storeId == storeId).toList();
}
