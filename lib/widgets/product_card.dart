import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/inventory_provider.dart';
import '../services/purchase_helper.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final double itemWidth;

  const ProductCard({super.key, required this.product, required this.itemWidth});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.hardEdge,
      elevation: 3,
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _buildPreview(),
              ),
              if (product.price.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Consumer<InventoryProvider>(
                    builder: (context, inventory, __) {
                      // ✅ 구매 여부 확인
                      final isPurchased = product.id != null &&
                          inventory.isOwned(product.id!);

                      if (isPurchased) {
                        // 이미 구매한 상품이면 "구매 완료" 표시
                        return ElevatedButton(
                          onPressed: null, // 비활성화
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                          child: Text(
                            "구매 완료",
                            style: TextStyle(
                              fontSize: itemWidth * 0.13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        );
                      }

                      // ✅ 광고 상품
                      if (product.adType == "rewarded") {
                        return ElevatedButton(
                          onPressed: () {
                            PurchaseHelper.handleRewardedAd(context, product);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.orange.shade300.withOpacity(0.6),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                          child: Text(
                            "광고",
                            style: TextStyle(
                              fontSize: itemWidth * 0.13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        );
                      }

                      // ✅ 일반 상품
                      return ElevatedButton(
                        onPressed: () async {
                          await PurchaseHelper.purchaseProduct(
                              context, product);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                        ),
                        child: Text(
                          "${product.price} ${(product.currency ?? "gold") == "gem" ? "잼" : "골드"}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                            fontSize: itemWidth * 0.13,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
          if (product.locked)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (product.type == ProductType.button && product.colors != null) {
      final closed = product.colors!['closed'];
      if (closed != null) {
        if (closed is Map &&
            closed['gradient'] != null &&
            closed['gradient'] is List) {
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
    }

    if (product.image != null) {
      return Image.asset(
        product.image!,
        fit: BoxFit.fill,
        width: double.infinity,
      );
    }

    return const Icon(Icons.help_outline);
  }
}