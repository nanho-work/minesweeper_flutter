import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_stage.dart';
import '../widgets/stage_navigation.dart';
import '../widgets/stage_star_rewards.dart'; // ✅ 새 위젯 임포트
import '../providers/app_data_provider.dart';
import 'game_screen.dart';

class StageMapScreen extends StatefulWidget {
  final void Function(Stage) onStartGame;
  final int initialIndex;

  const StageMapScreen({
    super.key,
    required this.onStartGame,
    this.initialIndex = 0,
  });

  @override
  State<StageMapScreen> createState() => _StageMapScreenState();
}

class _StageMapScreenState extends State<StageMapScreen> {
  late int currentIndex = widget.initialIndex;
  final stages = sampleStages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appDataProvider = context.read<AppDataProvider>();
      final nextStageIndex = await appDataProvider.getNextStageToPlayIndex();
      setState(() {
        currentIndex = nextStageIndex;
      });
    });
  }

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
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 40),
                StageStarRewards(stage: stage), // ✅ 분리된 위젯 사용
                StageNavigation(
                  stage: stage,
                  onNext: _nextStage,
                  onPrev: _prevStage,
                  onStartGame: (selectedStage) {
                    widget.onStartGame(selectedStage);
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ],
        ),
      ),
    );
  }
}