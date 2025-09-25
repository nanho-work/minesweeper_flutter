import 'package:flutter/material.dart';
import '../models/game_stage.dart';
import '../widgets/stage_info_panel.dart';
import '../widgets/stage_navigation.dart';

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
      if (currentIndex < stages.length - 1) currentIndex++;
    });
  }

  void _prevStage() {
    setState(() {
      if (currentIndex > 0) currentIndex--;
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
                StageInfoPanel(stage: stage), // ✅ 분리된 패널
                StageNavigation(              // ✅ 분리된 네비게이션
                  stage: stage,
                  onNext: _nextStage,
                  onPrev: _prevStage,
                  onStartGame: widget.onStartGame,
                ),
                const SizedBox(height: 40),
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