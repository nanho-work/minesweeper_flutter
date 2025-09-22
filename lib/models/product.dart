// lib/models/product.dart
import 'package:flutter/material.dart';

enum ProductType { gold, gem, skin, background }

class Product {
  final String name;      // ✅ 이름 추가 (UI에 안 보여줘도 모델엔 필요)
  final String? image;
  final String icon;
  final String price;     // 숫자 문자열 (예: "500", "950")
  final ProductType type;
  final bool locked;
  final String? adType;   // "rewarded" 등

  Product({
    required this.name,   // ✅ 필수로 바꿔줌
    this.image,
    required this.icon,
    required this.price,
    required this.type,
    this.locked = false,
    this.adType,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] ?? '',           // ✅ 매핑
      image: json['image'],
      icon: json['icon'] ?? '',
      price: json['price'] ?? '',
      type: _parseType(json['type']),
      locked: json['locked'] ?? false,
      adType: json['adType'],
    );
  }

  static ProductType _parseType(String? type) {
    switch (type) {
      case 'gold':
        return ProductType.gold;
      case 'gem':
        return ProductType.gem;
      case 'skin':
        return ProductType.skin;
      case 'background':
        return ProductType.background;
      default:
        return ProductType.gold;
    }
  }
}