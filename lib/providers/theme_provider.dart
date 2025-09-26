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
    return GameTheme(
      buttonGradient: _resolveButtonGradient(inventory.getEquippedItem("button")),
      buttonClosedColor: Colors.grey[200],
      buttonOpenColor: Colors.grey[300],
      mineImage: _resolveImage(inventory.getEquippedItem("mine")),
      flagImage: _resolveImage(inventory.getEquippedItem("flag")),
      backgroundImage: _resolveImage(inventory.getEquippedItem("background")),
    );
  }

  /// 버튼 스킨 색상 (gradient)
  List<Color>? _resolveButtonGradient(String? itemId) {
    final product = _allProducts.firstWhere(
      (p) => p.id == itemId,
      orElse: () => Product(
        id: null,
        name: '',
        price: '',
        type: ProductType.gold,
      ),
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
    final product = _allProducts.firstWhere(
      (p) => p.id == itemId,
      orElse: () => Product(
        id: null,
        name: '',
        price: '',
        type: ProductType.gold,
      ),
    );
    return product.image;
  }
}