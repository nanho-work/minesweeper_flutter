import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('배경음'),
            value: true, // placeholder
            onChanged: (val) {},
          ),
          SwitchListTile(
            title: const Text('효과음'),
            value: true, // placeholder
            onChanged: (val) {},
          ),
          ListTile(
            title: const Text('게임 데이터'),
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            title: const Text('기타 정보'),
            trailing: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}