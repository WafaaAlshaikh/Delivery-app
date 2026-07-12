// lib/data/models/category_model.dart

import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final int sortOrder;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.sortOrder = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'sort_order': sortOrder,
    };
  }

  static const Map<String, IconData> _iconMap = {
    'UtensilsCrossed': Icons.restaurant_menu,
    'ShoppingCart': Icons.shopping_cart_outlined,
    'Pill': Icons.local_pharmacy_outlined,
    'Shirt': Icons.checkroom_outlined,
    'BookOpen': Icons.menu_book_outlined,
    'Cake': Icons.cake_outlined,
    'Smartphone': Icons.phone_android_outlined,
  };

  IconData get iconData => _iconMap[icon] ?? Icons.shopping_cart_outlined;
}
