import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null && _expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String get userId {
    if (_expiryDate != null && _expiryDate.isAfter(DateTime.now())) {
      return _userId;
    }
    return null;
  }

  Future<void> authenticate(
      String email, String password, String urlSegment) async {
    final url = urlSegment + '?key=AIzaSyCQi9M7VrDcS9ER38e67fD5OLAu8Alx-ws';
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      notifyListeners();
    } catch (error) {
      throw error;
    }
    // print(json.decode(response.body));
  }

  Future<void> signup(String email, String password) async {
    const urlSegment =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp';
    return authenticate(email, password, urlSegment);
  }

  Future<void> login(String email, String password) async {
    const urlSegment =
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword';
    return authenticate(email, password, urlSegment);
  }
}
