// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import '../providers/inventory_provider.dart';
import '../models/game_theme.dart';
import '../models/product.dart';

class ThemeProvider extends ChangeNotifier {
  final InventoryProvider inventory;
  final List<Product> _allProducts;

  ThemeProvider(this.inventory, this._allProducts);

  GameTheme get currentTheme {
    final buttonId = inventory.getEquippedItem("button");
    final buttonProduct = _allProducts.firstWhere(
      (p) => p.id == buttonId,
      orElse: () => Product(id: null, name: '', price: '', type: ProductType.gold),
    );

    return GameTheme(
      buttonGradient: _resolveButtonGradient(buttonId),
      buttonClosedColor: Colors.grey[200], // 닫힌 상태 기본
      buttonOpenColor: _resolveColor(buttonProduct.colors?["open"]),
      buttonMineColor: _resolveColor(buttonProduct.colors?["mine"]),
      buttonFlagColor: _resolveColor(buttonProduct.colors?["flag"]),
      mineImage: _resolveImage(inventory.getEquippedItem("mine")),
      flagImage: _resolveImage(inventory.getEquippedItem("flag")),
      backgroundImage: _resolveImage(inventory.getEquippedItem("background")),
    );
  }

  /// 버튼 스킨 색상 (gradient)
  List<Color>? _resolveButtonGradient(String? itemId) {
    final product = _allProducts.firstWhere(
      (p) => p.id == itemId,
      orElse: () => Product(id: null, name: '', price: '', type: ProductType.gold),
    );

    if (product.colors != null &&
        product.colors?["closed"]?["gradient"] != null) {
      return (product.colors!["closed"]["gradient"] as List)
          .map((c) => Color(int.parse(c.replaceFirst('#', '0xff'))))
          .toList();
    }
    return null;
  }

  /// 이미지 스킨 (지뢰/깃발/배경)
  String? _resolveImage(String? itemId) {
    if (itemId == null || itemId.isEmpty) {
      // 인벤토리에서 기본 스킨을 항상 세팅해주므로 별도 기본 경로 불필요
      return null;
    }

    final product = _allProducts.firstWhere(
      (p) => p.id == itemId,
      orElse: () => Product(id: null, name: '', price: '', type: ProductType.gold),
    );

    return product.image; // 기본 배경 경로 강제 지정 제거
  }

  /// HEX → Color 변환
  Color? _resolveColor(dynamic value) {
    if (value is String) {
      return Color(int.parse(value.replaceFirst('#', '0xff')));
    }
    return null;
  }
}