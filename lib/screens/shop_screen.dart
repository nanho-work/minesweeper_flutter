import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_grid.dart';
import '../services/product_service.dart';
import '../widgets/ad_banner.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  ProductType _selectedType = ProductType.gold;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double spacing = screenWidth < 400 ? 8 : (screenWidth < 800 ? 12 : 20);
    double sidePadding = screenWidth < 400 ? 8 : 24;

    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/shop_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              const AdBanner(),
              const SizedBox(height: 14),

              // 상품 목록
              Expanded(
                child: ProductGrid(type: _selectedType),
                ),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: sidePadding),
                  child: Row(
                    children: [
                      _buildTabButton("골드", ProductType.gold),
                      SizedBox(width: spacing),
                      _buildTabButton("보석", ProductType.gem),
                      SizedBox(width: spacing),
                      _buildTabButton("스킨", ProductType.skin),
                      SizedBox(width: spacing),
                      _buildTabButton("부스터", ProductType.booster),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, ProductType type) {
    return TextButton(
      onPressed: () {
        setState(() => _selectedType = type);
      },
      style: TextButton.styleFrom(
        backgroundColor: _selectedType == type
            ? Colors.amber.shade200
            : Colors.grey.shade200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}