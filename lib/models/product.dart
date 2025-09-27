// lib/models/product.dart
import 'package:flutter/material.dart';

enum ProductType {
  gold,
  gem,
  mine,
  flag,
  button,
  background,
  character,
  hair,
  top,
  bottom,
  shoes,
}

class Product {
  final String? id;        // 스킨 아이템 구분용 ID (gold/gem엔 없음)
  final String name;       // 상품 이름
  final String? image;     // 이미지 경로
  final String? icon;      // 아이콘 (없을 수도 있음)
  final String price;      // 가격 (문자열로 처리)
  final ProductType type;  // 상품 타입
  final bool locked;       // 잠금 여부 (스킨 해금 전용)
  final String? adType;    // 광고 타입 (rewarded 등)
  final Map<String, dynamic>? colors; // 버튼 스킨 상태별 색상
  final String? currency;  // 구매 화폐 (gold/gem)

  Product({
    this.id,
    required this.name,
    this.image,
    this.icon,
    required this.price,
    required this.type,
    this.locked = false,
    this.adType,
    this.colors,
    this.currency,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['image'],
      icon: json['icon'],
      price: json['price'] ?? '',
      type: _parseType(json['type']),
      locked: json['locked'] ?? false,
      adType: json['adType'],
      colors: json['colors'] != null ? Map<String, dynamic>.from(json['colors']) : null,
      currency: json['currency'],
    );
  }

  static ProductType _parseType(String? type) {
    switch (type) {
      case 'gold':
        return ProductType.gold;
      case 'gem':
        return ProductType.gem;
      case 'mine':
        return ProductType.mine;
      case 'flag':
        return ProductType.flag;
      case 'button':
        return ProductType.button;
      case 'background':
        return ProductType.background;
      case 'character':
        return ProductType.character;
      case 'hair':
        return ProductType.hair;
      case 'top':
        return ProductType.top;
      case 'bottom':
        return ProductType.bottom;
      case 'shoes':
        return ProductType.shoes;
      default:
        return ProductType.gold;
    }
  }
}