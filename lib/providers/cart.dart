import 'package:flutter/foundation.dart';
import 'package:shop_app/providers/product.dart';

class CartItem {
  final Product product;
  final int quantity;
  late final double price;

  CartItem({
    required this.product,
    required this.quantity,
  }) {
    price = product.price * quantity;
  }
}

class Cart with ChangeNotifier {
  final Map<String, CartItem> _order = {};

  Map<String, CartItem> get order => _order;

  int get itemCount => _order.length;

  void addProductToCart(Product product) {
    if (_order.containsKey(product.id)) {
      _order.update(
        product.id,
        (cartItem) => CartItem(
          product: product,
          quantity: cartItem.quantity + 1,
        ),
      );
    } else {
      _order.putIfAbsent(
        product.id,
        () => CartItem(
          product: product,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }
}
