import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import 'game_button.dart';

class InventoryItemList extends StatelessWidget {
  final String type; // 지뢰 / 깃발 / 버튼
  final Function(String) onItemSelected;

  const InventoryItemList({
    super.key,
    required this.type,
    required this.onItemSelected,
  });

  Widget _buildPreview(Product product) {
    if (product.type == ProductType.button && product.colors != null) {
      final closed = product.colors!['closed'];

      if (closed is Map && closed['gradient'] != null && closed['gradient'] is List) {
        final gradientColors = (closed['gradient'] as List)
            .whereType<String>()
            .map((c) => Color(int.parse(c.replaceFirst('#', '0xff'))))
            .toList();
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      } else if (closed is String) {
        return Container(
          color: Color(int.parse(closed.replaceFirst('#', '0xff'))),
        );
      }
    }

    if (product.image != null) {
      return Image.asset(product.image!, fit: BoxFit.cover);
    }

    return const Icon(Icons.help_outline);
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final products = context.watch<ProductProvider>().products;

    // 보유한 아이템 중에서 현재 type에 해당하는 것만 필터
    final ownedProducts = products.where((p) =>
      p.type.name == type && inventory.isOwned(p.id ?? "")
    ).toList();

    if (ownedProducts.isEmpty) {
      return const Center(child: Text("보유한 아이템이 없습니다."));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75, // ✅ 카드+버튼 세로 비율 조정
      ),
      itemCount: ownedProducts.length,
      itemBuilder: (context, index) {
        final product = ownedProducts[index];
        final equipped = inventory.isEquipped(type, product.id ?? "");

        return Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onItemSelected(product.id ?? ""),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: equipped ? Colors.green : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: _buildPreview(product),
                          ),
                          Text(
                            product.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (equipped)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "착용중",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: GameButton(
                text: equipped ? "해제" : "착용",
                onPressed: () {
                  if (equipped) {
                    inventory.unequipItem(type);
                  } else {
                    inventory.equipItem(type, product.id ?? "");
                  }
                },
                color: equipped ? Colors.red : Colors.green,
                textColor: Colors.white,
                width: 80,
                height: 30,
              ),
            ),
          ],
        );
      },
    );
  }
}