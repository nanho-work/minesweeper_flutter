import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppFooter({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.store), label: "상점"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "캐릭터"),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
        BottomNavigationBarItem(icon: Icon(Icons.help), label: "게임안내"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "설정"),
      ],
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}