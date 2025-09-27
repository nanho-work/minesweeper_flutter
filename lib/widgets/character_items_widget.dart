// lib/widgets/character_items_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class CharacterItemsWidget extends StatelessWidget {
  final double iconSize;

  const CharacterItemsWidget({
    super.key,
    this.iconSize = 48, // 아이템 프리뷰 크기
  });

  Widget _buildPreview(Product product, double iconSize) {
    if (product.type == ProductType.button && product.colors != null) {
      final closedColor = product.colors!['closed'];
      if (closedColor is Map && closedColor['gradient'] is List) {
        final gradientColors = (closedColor['gradient'] as List)
            .map((c) => Color(int.parse(c.toString().replaceFirst('#', '0xff'))))
            .toList();
        return Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      } else if (closedColor is String) {
        final color = Color(int.parse(closedColor.replaceFirst('#', '0xff')));
        return Container(
          width: iconSize,
          height: iconSize,
          color: color,
        );
      }
    }
    if (product.image != null) {
      return Image.asset(
        product.image!,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
      );
    }
    return const Icon(Icons.help_outline, size: 28);
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final products = context.watch<ProductProvider>().products;

    // 현재 착용중인 아이템 전체
    final equipped = inventory.getAllEquippedItems();

    // 표시 순서 고정 (헤어, 상의, 하의, 신발, 지뢰, 깃발, 버튼, 배경)
    final order = [
      ProductType.hair,
      ProductType.top,
      ProductType.bottom,
      ProductType.shoes,
      ProductType.mine,
      ProductType.flag,
      ProductType.button,
      ProductType.background,
    ];

    // 아이템 찾기
    List<Product?> equippedProducts = order.map((type) {
      final itemId = equipped[type.name];
      if (itemId == null) return null;
      return products.firstWhere(
        (p) => p.id == itemId,
        orElse: () => Product(
          id: null,
          name: '',
          price: '',
          type: type,
        ),
      );
    }).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8, // 1줄에 4개
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1, // 정사각형
      ),
      itemCount: equippedProducts.length,
      itemBuilder: (context, index) {
        final product = equippedProducts[index];
        // Always render a card view, even if no product equipped
        if (product == null) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            child: Center(
              child: Text(
                "미착용",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: _buildPreview(product, iconSize),
        );
      },
    );
  }
}