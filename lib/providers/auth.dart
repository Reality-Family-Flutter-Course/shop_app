import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expireDate;
  String? _userID;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expireDate != null &&
        _expireDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    } else {
      return null;
    }
  }

  String? get userID {
    return _userID;
  }

  Future<void> singup(String email, String password) async {
    const url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyCzMZLVvmJkbKrN9NBhotYFeX3KwduM9z4";

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            "email": email,
            "password": password,
            "returnSecureToken": true,
          },
        ),
      );

      final responseData = json.decode(response.body);
      if (responseData["error"] != null) {
        throw HttpException(responseData["error"]["message"]);
      }

      _token = responseData["idToken"];
      _expireDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData["expiresIn"]),
        ),
      );
      _userID = responseData["localId"];

      notifyListeners();
    } catch (error) {
      print(error.toString());
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final pref = await SharedPreferences.getInstance();
    if (!pref.containsKey("userData")) {
      return false;
    }
    final extractinUserData =
        json.decode(pref.getString("userData")!) as Map<String, dynamic>;
    final expireDate = DateTime.parse(extractinUserData["expireDate"]);

    if (expireDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractinUserData["token"];
    _userID = extractinUserData["userID"];
    _expireDate = expireDate;
    notifyListeners();
    return true;
  }

  Future<void> auth(String email, String password) async {
    const url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCzMZLVvmJkbKrN9NBhotYFeX3KwduM9z4";

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            "email": email,
            "password": password,
            "returnSecureToken": true,
          },
        ),
      );

      final responseData = json.decode(response.body);
      if (responseData["error"] != null) {
        throw HttpException(responseData["error"]["message"]);
      }

      _token = responseData["idToken"];
      _expireDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData["expiresIn"]),
        ),
      );
      _userID = responseData["localId"];

      notifyListeners();

      final pref = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          "token": _token ?? "",
          "userID": _userID ?? "",
          "expireDate": _expireDate!.toIso8601String(),
        },
      );
      pref.setString("userData", userData);
    } catch (error) {
      print(error.toString());
      throw error;
    }
  }

  void logout() async {
    _token = null;
    _userID = null;
    _expireDate = null;

    final pref = await SharedPreferences.getInstance();
    pref.remove("userData");
    notifyListeners();
  }
}
