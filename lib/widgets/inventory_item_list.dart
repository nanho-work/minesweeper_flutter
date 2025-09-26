import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class InventoryItemList extends StatelessWidget {
  final String type; // 지뢰 / 깃발 / 버튼
  final Function(String) onItemSelected;

  const InventoryItemList({
    super.key,
    required this.type,
    required this.onItemSelected,
  });

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
                            child: product.image != null
                                ? Image.asset(product.image!, fit: BoxFit.cover)
                                : const Icon(Icons.image_not_supported),
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
              child: SizedBox(
                width: 70,
                child: ElevatedButton(
                  onPressed: () {
                    if (equipped) {
                      inventory.unequipItem(type);
                    } else {
                      inventory.equipItem(type, product.id ?? "");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 30),
                    backgroundColor: equipped ? Colors.red : Colors.green,
                  ),
                  child: Text(
                    equipped ? "해제" : "착용",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}