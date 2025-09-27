import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import 'product_card.dart';

class ProductGrid extends StatelessWidget {
  final ProductType type;

  const ProductGrid({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.error != null) {
          return Center(child: Text('상품 오류: ${provider.error}'));
        }

        final filtered = provider.filterByType(type);

        return LayoutBuilder(
          builder: (context, constraints) {
            final spacing = 12.0;
            final itemWidth =
                (constraints.maxWidth - (spacing * 3) - 16) / 3;
            const double heightFactor = 0.5;

            return SizedBox(
              height: itemWidth * heightFactor,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(6, 5, 6, 4),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, idx) {
                  return SizedBox(
                    width: itemWidth,
                    child: ProductCard(
                      product: filtered[idx],
                      itemWidth: itemWidth,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}