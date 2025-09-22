import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider 추가
import '../models/product.dart';
import '../widgets/product_grid.dart';
import '../services/product_service.dart';
import '../widgets/ad_banner.dart';
import '../providers/currency_provider.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent, // ✅ 배경 투명
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              const SafeArea(child: AdBanner()),

              Expanded(
                child: ListView(
                  children: [
                    _buildCategorySection("골드", ProductType.gold),
                    _buildCategorySection("보석", ProductType.gem),
                    _buildCategorySection("스킨", ProductType.skin),
                    _buildCategorySection("", ProductType.background),
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
            child: ProductGrid(type: type),
          ),
        ],
      ),
    );
  }
}