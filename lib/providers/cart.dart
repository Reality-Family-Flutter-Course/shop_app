import 'package:flutter/foundation.dart';
import 'package:shop_app/providers/product.dart';

class CartItem {
  final String id;
  final String productID;
  final String productTitle;
  final int quantity;
  late final double price;

  CartItem({
    required this.id,
    required this.productID,
    required this.productTitle,
    required double productPrice,
    required this.quantity,
  }) {
    price = productPrice * quantity;
  }

  CartItem.priced({
    required this.id,
    required this.productID,
    required this.productTitle,
    required this.price,
    required this.quantity,
  });
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
          productID: product.id!,
          productTitle: product.title,
          productPrice: product.price,
          quantity: cartItem.quantity + 1,
        ),
      );
    } else {
      _order.putIfAbsent(
        product.id!,
        () => CartItem(
          id: DateTime.now().toString(),
          productID: product.id!,
          productTitle: product.title,
          productPrice: product.price,
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
        (cartItem) => CartItem.priced(
            id: cartItem.id,
            productID: cartItem.productID,
            productTitle: cartItem.productTitle,
            price: cartItem.price,
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
