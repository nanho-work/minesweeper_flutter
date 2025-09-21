import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/product.dart';

class ProductService {
  static Future<List<Product>> loadProducts() async {
    final String response =
        await rootBundle.loadString('assets/data/products.json');
    final data = json.decode(response) as List;
    return data.map((item) => Product.fromJson(item)).toList();
  }
}