import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
  @required this.id,
  @required this.title,
  @required this.description,
  @required this.price,
  @required this.imageUrl,
  this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus() async {
    try {
      final url = Uri.https('flutter-shop-33f16-default-rtdb.firebaseio.com',
          '/products/${this.id}.json');
      await http.patch(url, body: json.encode({
        'isFavorite': !this.isFavorite,
      }));
      this.isFavorite = !this.isFavorite;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
