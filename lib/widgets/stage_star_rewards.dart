import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_data_provider.dart';
import '../models/game_stage.dart';
import '../models/stage_result.dart';

class StageStarRewards extends StatelessWidget {
  final Stage stage;

  const StageStarRewards({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    final List<GlobalKey> starKeys = List.generate(3, (_) => GlobalKey());
    return Consumer<AppDataProvider>(
      builder: (context, appData, child) {
        final stageResult = appData.stageResults[stage.id];
        if (stageResult == null) {
          return const SizedBox.shrink();
        }

        final stars = stageResult.stars;
        final claimedList = stageResult.rewardsClaimed;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int starIndex = 0; starIndex < 3; starIndex++) ...[
              GestureDetector(
                key: starKeys[starIndex],
                onTap: (stars > starIndex) && !claimedList[starIndex]
                    ? () async {
                        final success = await context
                            .read<AppDataProvider>()
                            .claimStarReward(stage.id, starIndex);
                        if (success) {
                          _showRewardOverlay(context, starIndex, starKeys[starIndex]);
                        }
                      }
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        (stars > starIndex)
                            ? Icons.star // 달성
                            : Icons.star_border, // 미달성
                        size: 46,
                        color: !(stars > starIndex)
                            ? Colors.grey
                            : (claimedList[starIndex]
                                ? Colors.yellow // 수령 완료
                                : Colors.white // 달성, 미수령
                                ),
                      ),
                      if (stars > starIndex && !claimedList[starIndex])
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "NEW",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (starIndex == 2)
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: IconButton(
                    icon: const Icon(Icons.info_outline, size: 28),
                    tooltip: '별 획득 조건 보기',
                    onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                            final stageResult = appData.stageResults[stage.id];
                            if (stageResult == null) return const SizedBox.shrink();

                            final conditionTexts = [
                                "${stage.condition.timeLimitSec}초 이내 성공, 100gold",
                                "실수 ${stage.condition.maxMistakes}회 이하, 20gem",
                                "힌트 ${stage.condition.maxHints}회 이하 사용, 에너지 1",
                            ];

                            return AlertDialog(
                                title: const Text('별 획득 조건'),
                                content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(stageResult.conditions.length, (index) {
                                    return Row(
                                    children: [
                                        Icon(
                                        stageResult.conditions[index] ? Icons.star : Icons.star_border,
                                        color: stageResult.conditions[index] ? Colors.amber : Colors.grey,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                        conditionTexts[index],
                                        style: TextStyle(
                                            color: stageResult.conditions[index] ? Colors.black : Colors.grey,
                                        ),
                                        ),
                                    ],
                                    );
                                }),
                                ),
                                actions: [
                                TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('닫기'),
                                ),
                                ],
                            );
                            },
                        );
                        },
                  ),
                ),
            ],
          ],
        );
      },
    );
  }

  void _showRewardOverlay(BuildContext context, int starIndex, GlobalKey starKey) {
    final overlay = Overlay.of(context);
    final renderBox = starKey.currentContext?.findRenderObject() as RenderBox?;
    if (overlay == null || renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx + size.width / 2 - 40,
        top: offset.dy + size.height + 8,
        width: 80,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                "${starIndex + 1}번째 별 보상 획득!",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}