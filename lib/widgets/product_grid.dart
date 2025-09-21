import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductGrid extends StatelessWidget {
  final ProductType type;

  const ProductGrid({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/wood.png'),
          fit: BoxFit.fill,
        ),
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
              final itemWidth = (constraints.maxWidth - (12 * 3) - 16) / 4; // 카드 한 칸의 가로 폭
              final iconSize = itemWidth * 0.6; // 아이콘/이미지 크기 비율
              final fontSize = itemWidth * 0.15; // 글자 크기 비율
              return GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3 / 3.3, // 카드의 가로세로 비율
                ),
                itemCount: filtered.length,
                itemBuilder: (context, idx) {
                  final product = filtered[idx];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                product.image != null
                                    ? Image.asset(
                                        product.image!,
                                        width: iconSize,
                                        height: iconSize,
                                        fit: BoxFit.contain,
                                      )
                                    : Icon(
                                        _mapIcon(product.icon),
                                        size: iconSize,
                                        color: product.type == ProductType.gold
                                            ? Colors.amber
                                            : Colors.blueAccent,
                                      ),
                                // Removed product name display
                                if (product.price != null && product.price!.isNotEmpty) ...[
                                  SizedBox(height: itemWidth * 0.03), // 여백 (이름/가격 사이)
                                  Text(
                                    product.price!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: fontSize * 0.9,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        if (product.locked)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
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
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// JSON 문자열 아이콘명을 실제 Flutter IconData로 매핑
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
}