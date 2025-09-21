import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게임 안내'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('게임 방법: 칸을 눌러 열기, 깃발로 표시하기'),
            SizedBox(height: 8),
            Text('지뢰: 지뢰가 있는 칸을 열면 게임 종료'),
            SizedBox(height: 8),
            Text('숫자: 주변 지뢰 개수를 나타냄'),
            SizedBox(height: 8),
            Text('보석: 보석을 모아 점수 획득'),
          ],
        ),
      ),
    );
  }
}