// lib/data/models/cart_item_model.dart

import 'product_model.dart';

class CartItem {
  final ProductModel product;
  final String storeName;
  final int quantity;

  CartItem({required this.product, required this.storeName, this.quantity = 1});

  double get subtotal => product.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      storeName: storeName,
      quantity: quantity ?? this.quantity,
    );
  }
}
