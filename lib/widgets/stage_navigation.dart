import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_stage.dart';
import '../providers/app_data_provider.dart';

/// StageNavigation 위젯은 게임 스테이지 선택 및 시작을 위한 UI를 구성합니다.
/// 좌우 화살표 버튼으로 스테이지를 변경하고, 가운데에는 스테이지 이미지와 이름, 시작 버튼을 표시합니다.
class StageNavigation extends StatelessWidget {
  final Stage stage;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final void Function(Stage) onStartGame;

  /// 생성자: 현재 선택된 스테이지와 이전/다음 스테이지 이동 콜백, 게임 시작 콜백을 받습니다.
  const StageNavigation({
    super.key,
    required this.stage,
    required this.onNext,
    required this.onPrev,
    required this.onStartGame,
  });

  /// build 메서드: 전체 UI를 구성하며,
  /// 좌우 화살표 버튼, 스테이지 이미지 및 이름, 시작 버튼을 포함합니다.
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 왼쪽 화살표 버튼: 이전 스테이지로 이동
          IconButton(
            icon: Stack(
              children: [
                Text(
                  String.fromCharCode(Icons.arrow_left.codePoint),
                  style: TextStyle(
                    fontSize: 60,
                    fontFamily: Icons.arrow_left.fontFamily,
                    package: Icons.arrow_left.fontPackage,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 3
                      ..color = Colors.black,
                  ),
                ),
                Text(
                  String.fromCharCode(Icons.arrow_left.codePoint),
                  style: TextStyle(
                    fontSize: 60,
                    fontFamily: Icons.arrow_left.fontFamily,
                    package: Icons.arrow_left.fontPackage,
                    color: Colors.yellow,
                  ),
                ),
              ],
            ),
            onPressed: onPrev,
          ),
          // 중앙 컬럼: 스테이지 이미지, 이름, 시작 버튼으로 구성
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 스테이지 이미지 표시
              Image.asset(stage.image, width: 200, height: 200),
              const SizedBox(height:8),
              // 스테이지 이름 텍스트: 흰색 테두리와 검은색 본문 텍스트를 겹쳐서 강조 효과 적용
              Stack(
                children: [
                  // 흰색 테두리 텍스트
                  Text(
                    stage.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 3
                        ..color = Colors.white,
                    ),
                  ),
                  // 검은색 본문 텍스트
                  Text(
                    stage.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 시작 버튼: 에너지 소모 후 게임 시작, 에너지 부족 시 다이얼로그 표시
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: FutureBuilder<Map<String, dynamic>?>(
                  future: context.read<AppDataProvider>().loadStageResult(stage.id),
                  builder: (context, snapshot) {
                    final stored = snapshot.data;
                    final isLocked = stored != null && stored.containsKey('locked') ? stored['locked'] as bool : stage.locked;
                    return OutlinedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF9C4), // 노란색 배경
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6), // 작은 둥근 모서리
                          side: const BorderSide(color: Colors.orange),
                        ),
                        side: const BorderSide(color: Colors.orange),
                      ),
                      onPressed: isLocked ? null : () async {
                        final appData = context.read<AppDataProvider>();
                        final ok = await appData.spendEnergy(1); // 에너지 1 소모
                        if (!ok) {
                          // 에너지 부족 시 경고 다이얼로그 표시
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("에너지가 부족합니다"),
                              content: const Text("광고 시청 또는 젬을 사용하여 에너지를 충전하세요."),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("확인"),
                                ),
                              ],
                            ),
                          );
                          return;
                        }
                        // 에너지 충분 시 게임 시작 콜백 호출
                        onStartGame(stage);
                      },
                      child: isLocked
                          ? const Text(
                              "잠김",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 시작 텍스트
                                const Text(
                                  "시 작",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                // 에너지 소모 표시 (번개 아이콘 + 개수)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.flash_on, color: Colors.green, size: 20),
                                    SizedBox(width: 4),
                                    Text(
                                      "X 5",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
          // 오른쪽 화살표 버튼: 다음 스테이지로 이동
          IconButton(
            icon: Stack(
              children: [
                Text(
                  String.fromCharCode(Icons.arrow_right.codePoint),
                  style: TextStyle(
                    fontSize: 60,
                    fontFamily: Icons.arrow_right.fontFamily,
                    package: Icons.arrow_right.fontPackage,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 3
                      ..color = Colors.black,
                  ),
                ),
                Text(
                  String.fromCharCode(Icons.arrow_right.codePoint),
                  style: TextStyle(
                    fontSize: 60,
                    fontFamily: Icons.arrow_right.fontFamily,
                    package: Icons.arrow_right.fontPackage,
                    color: Colors.yellow,
                  ),
                ),
              ],
            ),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}