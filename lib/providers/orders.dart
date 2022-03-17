import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  final String authToken;
  final String userID;

  Orders({
    required this.authToken,
    required this.userID,
    required List<OrderItem> orders,
  }) : _orders = orders;

  Orders.empty()
      : _orders = [],
        authToken = "",
        userID = "";

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        "https://flutter-synergy-store-default-rtdb.europe-west1.firebasedatabase.app/orders/$userID.json?auth=$authToken";
    final timeStamp = DateTime.now();

    final response = await http.post(
      Uri.parse(url),
      body: json.encode({
        "amount": total,
        "dateTime": timeStamp.toIso8601String(),
        "products": cartProducts
            .map((cp) => {
                  "id": cp.id,
                  "productID": cp.productID,
                  "productTitle": cp.productTitle,
                  "quantity": cp.quantity,
                  "price": cp.price,
                })
            .toList(),
      }),
    );

    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)["name"],
        amount: total,
        dateTime: DateTime.now(),
        products: cartProducts,
      ),
    );
    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        "https://flutter-synergy-store-default-rtdb.europe-west1.firebasedatabase.app/orders/$userID.json?auth=$authToken";

    final response = await http.get(Uri.parse(url));
    final extractedOrders = json.decode(response.body) as Map<String, dynamic>?;
    if (extractedOrders == null) {
      _orders = [];
      notifyListeners();
      return;
    }
    final List<OrderItem> loadedOrders = [];
    extractedOrders.forEach((orderID, orderData) {
      loadedOrders.add(OrderItem(
        id: orderID,
        amount: orderData["amount"],
        products: (orderData["products"] as List<dynamic>)
            .map(
              (item) => CartItem.priced(
                id: item["id"],
                productID: item["productID"],
                productTitle: item["productTitle"],
                price: item["price"],
                quantity: item["quantity"],
              ),
            )
            .toList(),
        dateTime: DateTime.parse(orderData["dateTime"]),
      ));
    });

    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }
}
