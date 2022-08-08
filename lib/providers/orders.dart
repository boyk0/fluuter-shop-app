import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'cart.dart';

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

class Orders with ChangeNotifier{
  List<OrderItem> _orders = [];

  // Future<List<OrderItem>> get orders async {
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    try {
      var url = Uri.https(
          'flutter-shop-33f16-default-rtdb.firebaseio.com', '/orders.json');
      final response = await http.get(url);
      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body == null) {
        return;
      }
      final List<OrderItem> loadedOrders = [];
      body.forEach((id, orderData) {
        loadedOrders.add(OrderItem(
            id: id,
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']),
            products: (orderData['products'] as List<dynamic>).map((product) => CartItem(
                id: product['id'],
                title: product['title'],
                quantity: product['quantity'],
                price: product['price'],
            )).toList(),
        ));
      });
      _orders = loadedOrders;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    try {
      var url = Uri.https(
          'flutter-shop-33f16-default-rtdb.firebaseio.com', '/orders.json');
      final timestamp = DateTime.now();
      final response = await http.post(url, body: json.encode({
        'amount': total,
        'products': cartProducts.map((cp) => {
          'id': cp.id,
          'title': cp.title,
          'price': cp.price,
          'quantity': cp.quantity,
        })
            .toList(),
        'dateTime': timestamp.toIso8601String(),
      }));
      final body = json.decode(response.body);
      _orders.add(OrderItem(
        id: body['name'],
        amount: total,
        dateTime: DateTime.now(),
        products: cartProducts,
      ));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}