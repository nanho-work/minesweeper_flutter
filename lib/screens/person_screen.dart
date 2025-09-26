// lib/screens/person_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../widgets/ad_banner.dart';
import '../widgets/inventory_item_list.dart';

class PersonScreen extends StatefulWidget {
  const PersonScreen({super.key});

  @override
  State<PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends State<PersonScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? selectedItemId; // 현재 선택한 아이템 ID
  String? selectedType;   // 현재 선택한 아이템 타입

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 지뢰/깃발/버튼
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const SafeArea(child: AdBanner()),

          // 탭 메뉴
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.transparent, // 업로드 이미지처럼 선 제거
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "지뢰"),
              Tab(text: "깃발"),
              Tab(text: "버튼"),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                InventoryItemList(
                  type: "mine",
                  onItemSelected: (id) {
                    setState(() {
                      selectedItemId = id;
                      selectedType = "mine";
                    });
                  },
                ),
                InventoryItemList(
                  type: "flag",
                  onItemSelected: (id) {
                    setState(() {
                      selectedItemId = id;
                      selectedType = "flag";
                    });
                  },
                ),
                InventoryItemList(
                  type: "button",
                  onItemSelected: (id) {
                    setState(() {
                      selectedItemId = id;
                      selectedType = "button";
                    });
                  },
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}