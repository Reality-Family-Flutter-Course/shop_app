import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String? id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void toggleFavoriteStatus(String authToken, String userID) async {
    final oldStatus = isFavorite;
    setFavValue(!oldStatus);

    final url =
        "https://flutter-synergy-store-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userID/$id.json?auth=$authToken";

    try {
      final response = await http.put(
        Uri.parse(url),
        body: json.encode(
          isFavorite,
        ),
      );
      if (response.statusCode >= 400) {
        setFavValue(oldStatus);
        debugPrint(json.decode(response.body));
      }
    } catch (error) {
      setFavValue(oldStatus);
      debugPrint(error.toString());
    }
  }

  void setFavValue(bool value) {
    isFavorite = value;
    notifyListeners();
  }
}
