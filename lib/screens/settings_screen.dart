import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "설정 화면 (사운드, 언어 등 옵션 예정)",
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}