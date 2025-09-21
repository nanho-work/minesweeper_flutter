import 'package:flutter/material.dart';
import '../main_layout.dart'; // 경로 수정

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MainLayout(initialIndex: 5), // const 제거
              ),
            );
          },
          child: const Text('스테이지 맵으로 이동'),
        ),
      ),
    );
  }
}