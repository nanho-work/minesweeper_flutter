import 'package:flutter/material.dart';
import '../models/stage.dart';
import '../widgets/stage_node.dart';
import 'game_screen.dart';

class StageMapScreen extends StatelessWidget {
  final void Function(Stage) onStartGame;

  const StageMapScreen({super.key, required this.onStartGame});

  @override
  Widget build(BuildContext context) {
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stages = sampleStages;
            final count = stages.length;

            // segment를 화면 높이에 맞춰 동적으로 조정하여 한 화면에 2개의 노드만 보이도록 함
            final double segment = constraints.maxHeight / 2;      // vertical distance between nodes
            const double topPadding = 80;    // extra space at top
            const double bottomPadding = 160; // extra space at bottom
            final double totalHeight = topPadding + bottomPadding + segment * (count - 1) + 240;

            return Center(
              child: SizedBox(
                width: constraints.maxWidth * 0.6,
                height: totalHeight,
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: totalHeight,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/path.png'),
                                fit: BoxFit.none, // 원본 크기 유지
                                repeat: ImageRepeat.repeatY, // 세로 반복
                                alignment: Alignment.center, // 중앙 기준
                              ),
                            ),
                          ),
                        ),
                        ...List.generate(count, (i) {
                          final stage = stages[i];
                          final bool rightSide = i.isEven;

                          // Place nodes from bottom to top visually
                          final double top = totalHeight - bottomPadding - (i * segment) - 120;

                          return Positioned(
                            // 스테이지의 세로(위치) 조정 → 위에서부터 얼마나 떨어질지
                            top: top,

                            // 스테이지의 가로 위치 조정 (오른쪽 기준, 첫 스테이지가 오른쪽에 위치하고 번갈아 배치)
                            left: rightSide ? null : -110,

                            // 스테이지의 가로 위치 조정 (왼쪽 기준)
                            right: rightSide ? -0 : null,
                            
                            child: StageNode(
                              stage: stage,
                              onTap: () {
                                onStartGame(stage);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}