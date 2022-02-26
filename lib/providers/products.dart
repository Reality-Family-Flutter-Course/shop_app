import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'dart:convert';

import 'product.dart';

class Products with ChangeNotifier {
  static int index = 5;

  List<Product> _items;
  final String authToken;
  final String userID;

  Products({
    required this.authToken,
    required this.userID,
    required List<Product> items,
  }) : _items = items;

  Products.empty()
      : _items = [],
        authToken = "",
        userID = "";

  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Future<void> addProduct(Product product) {
    final url =
        "https://flutter-synergy-store-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken";
    return http
        .post(
      Uri.parse(url),
      body: json.encode({
        "title": product.title,
        "description": product.description,
        "imageUrl": product.imageUrl,
        "price": product.price,
      }),
    )
        .catchError(
      (error) {
        print(error);
        throw error;
      },
    ).then((response) {
      Product newProduct = Product(
        id: json.decode(response.body)["name"],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    });
  }

  Future<void> updateProduct(String id, Product product) async {
    final productIndex = _items.indexWhere((prod) => prod.id == id);
    if (productIndex >= 0) {
      final url =
          "https://flutter-synergy-store-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken";
      await http.patch(
        Uri.parse(url),
        body: json.encode({
          "title": product.title,
          "description": product.description,
          "imageUrl": product.imageUrl,
          "price": product.price,
        }),
      );
      _items[productIndex] = product;
      notifyListeners();
    } else {
      print("Product not found");
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        "https://flutter-synergy-store-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken";

    final extingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? extingProduct = _items[extingProductIndex];

    _items.removeWhere((product) => product.id == id);
    notifyListeners();

    final response = await http.delete(Uri.parse(url));
    if (response.statusCode >= 400) {
      _items.insert(extingProductIndex, extingProduct);
      notifyListeners();
      throw HttpException("Could not delete product.");
    }
    extingProduct = null;
  }

  Future<void> fetchAndSetProducts() async {
    var url =
        "https://flutter-synergy-store-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken";

    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;
      if (extractedData == null) {
        return;
      }

      url =
          "https://flutter-synergy-store-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userID.json?auth=$authToken";
      final favoriteResponse = await http.get(Uri.parse(url));
      final favoriteData = json.decode(favoriteResponse.body);

      List<Product> loadedProducts = [];
      extractedData.forEach((prodID, prodData) {
        loadedProducts.add(Product(
          id: prodID,
          title: prodData["title"],
          description: prodData["description"],
          imageUrl: prodData["imageUrl"],
          price: prodData["price"],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodID] ?? false,
        ));

        _items = loadedProducts;
        notifyListeners();
      });
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
