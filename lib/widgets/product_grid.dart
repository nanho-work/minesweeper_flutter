import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../providers/currency_provider.dart';
import '../services/ad_service.dart';

class ProductGrid extends StatelessWidget {
  final ProductType type;

  const ProductGrid({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(4),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.brown.shade300.withOpacity(0.8), // 컨테이너 백그라운드 투명도
            border: Border.all(
              color: Colors.brown.shade600,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.3),
                blurRadius: 6,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: FutureBuilder<List<Product>>(
            future: ProductService.loadProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('상품을 불러오는 중 오류가 발생했습니다.'));
              }

              final products = snapshot.data ?? [];
              final filtered = products.where((p) => p.type == type).toList();

              return LayoutBuilder(
                builder: (context, constraints) {
                  // === 카드 기본 크기를 유지; 가로 스크롤로 4개 표시 ===
                  final spacing = 12.0;
                  // 카드 한 칸의 가로 폭(이전 계산과 동일)
                  final itemWidth = (constraints.maxWidth - (spacing * 3) - 16) / 3;

                  // 이 height는 카드뷰 전체 높이를 늘려 답답하지 않게 하는 것임.
                  const double heightFactor = 1.8; // 높이 비율: 1.0 기본, 줄이거나 늘리고 싶으면 조절
                  return SizedBox(
                    height: itemWidth * heightFactor, // 카드뷰 전체 높이 비율 (heightFactor로 조절 가능)
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(6, 10, 6, 4), // 왼:8, 상:8, 오:8, 하:16
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, idx) {
                        final product = filtered[idx];
                        return SizedBox(
                          width: itemWidth,
                          child: GestureDetector(
                            onTap: () {
                              if (product.type == ProductType.background && product.image != null) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      backgroundColor: Colors.black,
                                      insetPadding: EdgeInsets.all(10),
                                      child: InteractiveViewer(
                                        child: Image.asset(product.image!),
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // ← 둥글기 제거
                              ),
                              clipBehavior: Clip.hardEdge,
                              elevation: 3,
                              child: Stack(
                                children: [
                                  Column(
                                    children: [
                                      Expanded(
                                        child: product.image != null
                                            ? Image.asset(
                                                product.image!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              )
                                            : Center(
                                                child: Icon(
                                                  _mapIcon(product.icon),
                                                  size: itemWidth * 1,
                                                  color: product.type == ProductType.gold
                                                      ? Colors.amber
                                                      : Colors.blueAccent,
                                                ),
                                              ),
                                      ),
                                      if (product.price.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                                          child: Consumer<CurrencyProvider>(
                                            builder: (context, currencyProvider, _) {
                                              // ✅ 리워드 광고 상품
                                              if (product.adType == "rewarded") {
                                                return ElevatedButton(
                                                  onPressed: () {
                                                    AdService.showRewardedAd(
                                                      onReward: () {
                                                        final rewardAmount = int.tryParse(product.name.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                                                        if (product.type == ProductType.gold) {
                                                          context.read<CurrencyProvider>().addGold(rewardAmount);
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text("광고 보상으로 골드 $rewardAmount 획득!")),
                                                          );
                                                        } else if (product.type == ProductType.gem) {
                                                          context.read<CurrencyProvider>().addGems(rewardAmount);
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text("광고 보상으로 보석 $rewardAmount 획득!")),
                                                          );
                                                        }
                                                      },
                                                      onFail: () {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text("광고가 아직 준비되지 않았습니다.")),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.orange.shade300.withOpacity(0.6),
                                                    elevation: 0,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

                                              // ✅ 일반 상품 (보석 소비 또는 골드 소비)
                                              return ElevatedButton(
                                                onPressed: () async {
                                                  final price = int.tryParse(product.price) ?? 0;
                                                  bool success = false;
                                                  if (product.type == ProductType.gold) {
                                                    // 골드 상품은 잼으로 구매
                                                    success = await currencyProvider.spendGems(price);
                                                    if (success) {
                                                      // 제품 이름에 골드 수량이 포함되어 있으면 파싱, 없으면 기본 0
                                                      final goldAmount = int.tryParse(product.name.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                                                      currencyProvider.addGold(goldAmount);
                                                    }
                                                  } else if (product.type == ProductType.gem) {
                                                    // 보석 상품은 골드로 구매
                                                    success = await currencyProvider.spendGold(price);
                                                    if (success) {
                                                      final gemAmount = int.tryParse(product.name.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                                                      currencyProvider.addGems(gemAmount);
                                                    }
                                                  }
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text(success ? "구매 완료!" : (product.type == ProductType.gold ? "보석이 부족합니다." : "골드가 부족합니다."))),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  elevation: 0,
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                ),
                                                child: Text(
                                                  product.type == ProductType.gold
                                                      ? "${product.price} 잼"
                                                      : "${product.price} 골드",
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
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.4),
                                        ),
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
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.brown.shade700.withOpacity(0.8),
                    Colors.brown.shade400.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _typeLabel(type),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _mapIcon(String? iconName) {
    switch (iconName) {
      case "attach_money":
        return Icons.attach_money;
      case "diamond":
        return Icons.diamond;
      default:
        return Icons.help_outline;
    }
  }

  String _typeLabel(ProductType type) {
    switch (type) {
      case ProductType.gold:
        return "골드";
      case ProductType.gem:
        return "보석";
      case ProductType.skin:
        return "스킨";
      case ProductType.background:
        return "게임배경";
      default:
        return "";
    }
  }
}