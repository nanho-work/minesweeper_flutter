// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/sidebar/sidebar_widget.dart';
import '../widgets/character_widget.dart';
import '../widgets/character_items_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<bool> attendance = List.generate(7, (_) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/skins/Character_room_bg.png',
              fit: BoxFit.fill,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 300),
                CharacterWidget(size: 180),
                const SizedBox(height: 8),
                const CharacterItemsWidget(), // ✅ 착용 아이템 미리보기
              ],
            ),
          ),
          SidebarWidget(
            isRight: true,
            attendance: attendance,
          ),
        ],
      ),
    );
  }
}