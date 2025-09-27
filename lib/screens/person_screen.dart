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
    _tabController = TabController(length: 9, vsync: this); // 지뢰/깃발/버튼/배경/캐릭터/헤어/상의/하의/신발
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // 탭 메뉴
          PreferredSize(
            preferredSize: const Size.fromHeight(90), // enough for 3 lines
            child: Stack(
              children: [
                Container(
                  color: Colors.pink[50],
                  padding: const EdgeInsets.only(right: 40),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.red[400],
                      shadows: [
                        Shadow(
                          offset: Offset(0, 0),
                          blurRadius: 3,
                          color: Colors.pink,
                        ),
                      ],
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    isScrollable: true,
                    // tabAlignment: TabAlignment.start, // Uncomment if available in your Flutter version
                    tabs: const [
                      Tab(text: "지뢰"),
                      Tab(text: "깃발"),
                      Tab(text: "버튼"),
                      Tab(text: "배경"),
                      Tab(text: "캐릭터"),
                      Tab(text: "헤어"),
                      Tab(text: "상의"),
                      Tab(text: "하의"),
                      Tab(text: "신발"),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 40,
                    child: Image.asset("assets/images/left.png", fit: BoxFit.contain),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 40,
                    child: Image.asset("assets/images/right.png", fit: BoxFit.contain),
                  ),
                ),
              ],
            ),
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
                InventoryItemList(
                  type: "background",
                  onItemSelected: (id) {
                    setState(() {
                      selectedItemId = id;
                      selectedType = "background";
                    });
                  },
                ),
                InventoryItemList(
                  type: "character",
                  onItemSelected: (id) {
                    setState(() {
                      selectedItemId = id;
                      selectedType = "character";
                    });
                  },
                ),
                InventoryItemList(
                  type: "hair",
                  onItemSelected: (id) {
                    setState(() {
                      selectedItemId = id;
                      selectedType = "hair";
                    });
                  },
                ),
                InventoryItemList(
                  type: "top",
                  onItemSelected: (id) {
                    setState(() {
                      selectedItemId = id;
                      selectedType = "top";
                    });
                  },
                ),
                InventoryItemList(
                  type: "bottom",
                  onItemSelected: (id) {
                    setState(() {
                      selectedItemId = id;
                      selectedType = "bottom";
                    });
                  },
                ),
                InventoryItemList(
                  type: "shoes",
                  onItemSelected: (id) {
                    setState(() {
                      selectedItemId = id;
                      selectedType = "shoes";
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