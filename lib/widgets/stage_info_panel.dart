import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_stage.dart';
import '../providers/app_data_provider.dart';

class StageInfoPanel extends StatelessWidget {
  final Stage stage;

  const StageInfoPanel({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "스테이지 ${stage.id}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder<Map<String, dynamic>?>(
            future: context.read<AppDataProvider>().loadStageResult(stage.id),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final data = snapshot.data!;
                final stars = data['stars'] ?? '-';
                final elapsed = data['elapsed'] ?? '-';
                final mistakes = data['mistakes'] ?? '-';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            if (stars is int && index < stars) {
                              return const Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(Icons.star, color: Colors.white, size: 36),
                                  Icon(Icons.star, color: Colors.yellow, size: 32),
                                ],
                              );
                            } else {
                              return const Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(Icons.star_border, color: Colors.white, size: 36),
                                  Icon(Icons.star_border, color: Colors.grey, size: 32),
                                ],
                              );
                            }
                          }),
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('⭐ 별 획득 조건'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("1. 제한 시간 ${stage.condition.timeLimitSec}초 이내 클리어"),
                                      Text("2. 최대 ${stage.condition.maxMistakes}회 이하 실수"),
                                      Text("3. 힌트 ${stage.condition.maxHints}회 이하 사용"),
                                    ],
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
                      ],
                    ),
                    Text("클리어 여부: ${data['cleared'] == true ? "성공" : "실패"}"),
                    Text("플레이 시간: $elapsed"),
                    Text("틀린 횟수: $mistakes"),
                    const SizedBox(height: 16),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            return const Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(Icons.star_border, color: Colors.white, size: 36),
                                Icon(Icons.star_border, color: Colors.grey, size: 32),
                              ],
                            );
                          }),
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('⭐ 별 획득 조건'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("1. 시간 : ${stage.condition.timeLimitSec}초 이내"),
                                      Text("2. 실수 : ${stage.condition.maxMistakes}회 이하"),
                                      Text("3. 힌트 : ${stage.condition.maxHints}회 이하"),
                                    ],
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
                      ],
                    ),
                    const Text("클리어 여부: -"),
                    const Text("플레이 시간: -"),
                    const Text("틀린 횟수: -"),
                    const SizedBox(height: 16),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}