import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  // 전체 상품 목록을 저장하는 리스트입니다.
  List<Product> _products = [];
  // 상품 데이터 로딩 중 상태를 나타냅니다.
  bool _isLoading = false;
  // 에러 메시지를 저장합니다.
  String? _error;

  // 전체 상품 목록을 반환합니다.
  List<Product> get products => _products;
  // 상품 데이터가 로딩 중인지 여부를 반환합니다.
  bool get isLoading => _isLoading;
  // 에러 메시지를 반환합니다.
  String? get error => _error;

  // 상품 목록을 비동기적으로 불러옵니다.
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await ProductService.loadProducts();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // 특정 상품 타입에 따라 상품을 필터링하여 반환합니다.
  List<Product> filterByType(ProductType type) {
    return _products.where((p) => p.type == type).toList();
  }
}