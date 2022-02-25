import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'dart:convert';

import 'product.dart';

class Products with ChangeNotifier {
  static int index = 5;

  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> addProduct(Product product) {
    const url =
        "https://flutter-synergy-store-default-rtdb.europe-west1.firebasedatabase.app/products.json";
    return http
        .post(
      Uri.parse(url),
      body: json.encode({
        "title": product.title,
        "description": product.description,
        "imageUrl": product.imageUrl,
        "price": product.price,
        "isFavorite": product.isFavorite,
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
          "https://flutter-synergy-store-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json";
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
        "https://flutter-synergy-store-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json";

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
    const url =
        "https://flutter-synergy-store-default-rtdb.europe-west1.firebasedatabase.app/products.json";

    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;
      if (extractedData == null) {
        return;
      }
      List<Product> loadedProducts = [];
      extractedData.forEach((prodID, prodData) {
        loadedProducts.add(Product(
          id: prodID,
          title: prodData["title"],
          description: prodData["description"],
          imageUrl: prodData["imageUrl"],
          price: prodData["price"],
          isFavorite: prodData["isFavorite"],
        ));

        _items = loadedProducts;
        notifyListeners();
      });
    } catch (error) {
      print(error);
      throw error;
    }
  }

  static Future<Product?> fetchProduct(String id) async {
    final url =
        "https://flutter-synergy-store-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json";

    Product? loadedProduct;

    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      extractedData.forEach((prodID, prodData) {
        loadedProduct = Product(
          id: prodID,
          title: prodData["title"],
          description: prodData["description"],
          imageUrl: prodData["imageUrl"],
          price: prodData["price"],
          isFavorite: prodData["isFavorite"],
        );
      });
    } catch (error) {
      print(error);
      throw error;
    }

    return loadedProduct;
  }
}
