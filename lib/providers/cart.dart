import 'package:flutter/foundation.dart';
import 'package:shop_app/providers/product.dart';

class _CartItem {
  final String id;
  final Product product;
  final int quantity;
  late final double price;

  _CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  }) {
    price = product.price * quantity;
  }
}

class Cart with ChangeNotifier {
  final Map<String, _CartItem> _order = {};

  Map<String, _CartItem> get order => _order;

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
        product.id,
        (cartItem) => _CartItem(
          id: cartItem.id,
          product: product,
          quantity: cartItem.quantity + 1,
        ),
      );
    } else {
      _order.putIfAbsent(
        product.id,
        () => _CartItem(
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
}
