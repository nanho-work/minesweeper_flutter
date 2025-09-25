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
        children: [
          Text("스테이지 ${stage.id} 기록",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                    Text("클리어 여부: ${stars != '-' ? "성공" : "실패"}"),
                    Text("플레이 시간: $elapsed"),
                    Text("틀린 횟수: $mistakes"),
                  ],
                );
              } else {
                return Column(
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
                    const Text("클리어 여부: -"),
                    const Text("플레이 시간: -"),
                    const Text("틀린 횟수: -"),
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