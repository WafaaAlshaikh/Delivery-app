// lib/providers/cart_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get totalCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.subtotal);

  bool get isEmpty => items.isEmpty;

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addProduct(ProductModel product, String storeName) {
    final index = state.items.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (index >= 0) {
      final updated = [...state.items];
      updated[index] = updated[index].copyWith(
        quantity: updated[index].quantity + 1,
      );
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(product: product, storeName: storeName),
        ],
      );
    }
  }

  void increment(String productId) {
    final updated = state.items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();
    state = state.copyWith(items: updated);
  }

  void decrement(String productId) {
    final updated = <CartItem>[];
    for (final item in state.items) {
      if (item.product.id == productId) {
        if (item.quantity > 1) {
          updated.add(item.copyWith(quantity: item.quantity - 1));
        }
      } else {
        updated.add(item);
      }
    }
    state = state.copyWith(items: updated);
  }

  void removeItem(String productId) {
    final updated = state.items
        .where((item) => item.product.id != productId)
        .toList();
    state = state.copyWith(items: updated);
  }

  void clear() {
    state = const CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);
