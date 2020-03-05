import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';
import 'auth.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String _authToken;
  String _userId;

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = 'https://flutter-shop-7adb4.firebaseio.com/userOrders/$_userId.json?auth=$_authToken';
    final timestamp = DateTime.now();
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'amount': total,
          'dateTime': timestamp.toIso8601String(),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
        }),
      );
      _orders.insert(
          0,
          OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            dateTime: timestamp,
            products: cartProducts,
          ));
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> fetchAndSetOrders() async {
    final url = 'https://flutter-shop-7adb4.firebaseio.com/userOrders/$_userId.json?auth=$_authToken';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      _orders = extractedData.entries
          .map((entry) => OrderItem(
                id: entry.key,
                amount: entry.value['amount'],
                dateTime: DateTime.parse(entry.value['dateTime']),
                products: (entry.value['products'] as List<dynamic>)
                    .map((prodEntry) => CartItem(
                          id: prodEntry['id'],
                          price: prodEntry['price'],
                          quantity: prodEntry['quantity'],
                          title: prodEntry['title'],
                        ))
                    .toList(),
              ))
          .toList().reversed.toList();
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Orders updateAuthData(Auth auth) {
    _authToken = auth.token;
    _userId = auth.userId;
    return this;
  }

}
