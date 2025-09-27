import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../widgets/product_grid.dart';
import '../providers/product_provider.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ Provider에서 상품 불러오기 (앱 실행 시 1회)
    Future.microtask(() {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // ✅ 배경 투명
      body: Stack(
        children: [
          Column(
            children: [

              Expanded(
                child: ListView(
                  children: [
                    _buildCategorySection("골드", ProductType.gold),
                    _buildCategorySection("보석", ProductType.gem),
                    _buildCategorySection("지뢰", ProductType.mine),
                    _buildCategorySection("깃발", ProductType.flag),
                    _buildCategorySection("버튼", ProductType.button),
                    _buildCategorySection("배경", ProductType.background),
                    _buildCategorySection("헤어", ProductType.hair),
                    _buildCategorySection("상의", ProductType.top),
                    _buildCategorySection("하의", ProductType.bottom),
                    _buildCategorySection("신발", ProductType.shoes),
                  ],
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String title, ProductType type) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: ProductGrid(type: type), // ✅ Provider 기반으로 상품 표시
          ),
        ],
      ),
    );
  }
}