import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/inventory_provider.dart';
import '../services/purchase_helper.dart';
import '../services/ad_limit_service.dart';
import '../widgets/game_button.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final double itemWidth;

  const ProductCard({super.key, required this.product, required this.itemWidth});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: itemWidth * 1.2,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.amber.shade50, // 아주 연한 배경색
              border: Border.all(
                color: Colors.black,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                _buildPreview(),
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
          ),
        ),
        const SizedBox(height: 4),
        if (product.price.isNotEmpty)
          Consumer<InventoryProvider>(
            builder: (context, inventory, __) {
              // ✅ 기존 버튼 로직 그대로 유지
              final isPurchased = product.id != null &&
                  inventory.isOwned(product.id!);

              if (isPurchased) {
                return GameButton(
                  text: "보유중",
                  onPressed: () {},
                  color: Colors.grey.shade300,
                  textColor: Colors.black54,
                  width: itemWidth,
                  height: 30,
                );
              }

              if (product.adType == "rewarded") {
                return FutureBuilder<int>(
                  future: AdLimitService.getTodayCount(),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return GameButton(
                      text: "광고 ($count/${AdLimitService.maxAdsPerDay})",
                      onPressed: () {
                        PurchaseHelper.handleRewardedAd(context, product);
                      },
                      color: Colors.orange.shade300.withOpacity(0.6),
                      textColor: Colors.black,
                      width: itemWidth,
                      height: 30,
                    );
                  },
                );
              }

              return GameButton(
                text: "${product.price} ${(product.currency ?? "gold") == "gem" ? "잼" : "골드"}",
                onPressed: () async {
                  await PurchaseHelper.purchaseProduct(context, product);
                },
                color: Colors.white,
                textColor: Colors.grey[800],
                width: itemWidth,
                height: 30,
              );
            },
          ),
      ],
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
        fit: BoxFit.contain, // ✅ 비율 유지하며 맞춤
        width: double.infinity,
      );
    }

    return const Icon(Icons.help_outline);
  }
}