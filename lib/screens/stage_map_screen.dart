import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_stage.dart';
import '../providers/app_data_provider.dart';
import '../widgets/stage_info_panel.dart';
import '../widgets/stage_navigation.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appDataProvider = context.read<AppDataProvider>();
      for (int i = 0; i < stages.length; i++) {
        final stage = stages[i];
        final result = await appDataProvider.loadStageResult(stage.id);
        final isCleared = result != null && result['cleared'] == true;
        final isUnlocked = result != null ? result['locked'] == false : !stage.locked;

        if (isUnlocked && !isCleared) {
          setState(() {
            currentIndex = i;
          });
          break;
        }
      }
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
                StageInfoPanel(stage: stage), // ✅ 분리된 패널
                StageNavigation(              // ✅ 분리된 네비게이션
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