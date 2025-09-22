import 'package:flutter/material.dart';
import '../models/game_stage.dart';
import '../widgets/stage_node.dart';
import 'game_screen.dart';

class StageMapScreen extends StatefulWidget {
  final void Function(Stage) onStartGame;

  const StageMapScreen({super.key, required this.onStartGame});

  @override
  State<StageMapScreen> createState() => _StageMapScreenState();
}

class _StageMapScreenState extends State<StageMapScreen> {
  int currentIndex = 0;
  final stages = sampleStages;

  void _nextStage() {
    setState(() {
      if (currentIndex < stages.length - 1) {
        currentIndex++;
      }
    });
  }

  void _prevStage() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final stage = stages[currentIndex];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/stage_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text("스테이지 ${stage.id} 기록",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("클리어 여부: ${stage.cleared ? "성공" : "실패"}"),
                      Text("플레이 시간: ${stage.timeTaken ?? '-'}"),
                      Text("틀린 횟수: ${stage.mistakes ?? '-'}"),
                    ],
                  ),
                ),

                // ✅ 중앙: 좌/우 버튼 + 스테이지 이미지 + 이름
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_left, size: 40),
                        onPressed: _prevStage,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(stage.image, width: 150, height: 150),
                          const SizedBox(height: 12),
                          Text(stage.name,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => widget.onStartGame(stage),
                            child: const Text("게임 시작"),
                          )
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_right, size: 40),
                        onPressed: _nextStage,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40), // 푸터 여백
              ],
            ),
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}