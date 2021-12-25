import 'package:flutter/foundation.dart';
import 'package:shop_app/providers/product.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;
  late final double price;

  CartItem({
    required this.id,
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

  double get totalAmount {
    double result = 0;

    for (var element in _order.values) {
      result += element.price;
    }

    return result;
  }

  void addProductToCart(Product product) {
    if (_order.containsKey(product.id)) {
      _order.update(
        product.id!,
        (cartItem) => CartItem(
          id: cartItem.id,
          product: product,
          quantity: cartItem.quantity + 1,
        ),
      );
    } else {
      _order.putIfAbsent(
        product.id!,
        () => CartItem(
          id: DateTime.now().toString(),
          product: product,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _order.remove(productId);
    notifyListeners();
  }

  void removeSingleProduct(String productId) {
    if (!_order.containsKey(productId)) {
      return;
    }

    if (_order[productId]!.quantity > 1) {
      _order.update(
        productId,
        (cartItem) => CartItem(
            id: cartItem.id,
            product: cartItem.product,
            quantity: cartItem.quantity - 1),
      );
    } else {
      _order.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _order.clear();
    notifyListeners();
  }
}
