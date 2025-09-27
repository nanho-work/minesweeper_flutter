import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class CharacterWidget extends StatelessWidget {
  const CharacterWidget({super.key, this.size = 200});

  final double size;

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final products = context.watch<ProductProvider>().products;

    String? _fallbackImage(String type) {
      switch (type) {
        case 'character':
          return 'assets/images/characters/base_male.png';
        case 'hair':
        case 'top':
        case 'bottom':
        case 'shoes':
        default:
          return null; // 해당 파츠는 기본값 없음
      }
    }

    String? getImage(String type) {
      final id = inventory.getEquippedItem(type);
      if (id == null || id.isEmpty) {
        return _fallbackImage(type);
      }
      final product = products.firstWhere(
        (p) => p.id != null && p.id == id, // ⚠️ null ID 매칭 금지
        orElse: () => Product(
          id: null,
          name: '',
          price: '',
          type: ProductType.character,
          image: _fallbackImage(type),
        ),
      );
      return product.image;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (getImage("character") != null)
            Image.asset(getImage("character")!, fit: BoxFit.contain),
          if (getImage("hair") != null)
            Image.asset(getImage("hair")!, fit: BoxFit.contain),
          if (getImage("top") != null)
            Image.asset(getImage("top")!, fit: BoxFit.contain),
          if (getImage("bottom") != null)
            Image.asset(getImage("bottom")!, fit: BoxFit.contain),
          if (getImage("shoes") != null)
            Image.asset(getImage("shoes")!, fit: BoxFit.contain),
        ],
      ),
    );
  }
}