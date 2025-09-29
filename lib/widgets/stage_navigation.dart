import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_stage.dart';
import '../models/stage_result.dart';
import '../providers/app_data_provider.dart';
import 'game_button.dart';


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
            icon: SizedBox(
              width: 40,
              height: 40,
              child: Image.asset('assets/images/left.png'),
            ),
            onPressed: onPrev,
          ),
          // 중앙 컬럼: 스테이지 이름, 이미지, 시작 버튼으로 구성 (순서 변경됨)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 스테이지 이름 텍스트: 흰색 테두리와 검은색 본문 텍스트를 겹쳐서 강조 효과 적용
              // 픽셀 스타일: 검은색 외곽선, 흰색 채움, 굵은 블록체, 그림자 효과로 도트 느낌 강조
              Stack(
                children: [
                  // 검은색 외곽선 텍스트 (두껍게)
                  Text(
                    stage.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 5
                        ..color = Colors.black,
                    ),
                  ),
                  // 흰색 채움 텍스트 + 픽셀 느낌 그림자 추가
                  Text(
                    stage.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(1.5, 1.5),
                          color: Colors.black.withOpacity(0.9),
                          blurRadius: 0.5,
                        ),
                        Shadow(
                          offset: Offset(-1.5, 1.5),
                          color: Colors.black.withOpacity(0.9),
                          blurRadius: 0.5,
                        ),
                        Shadow(
                          offset: Offset(1.5, -1.5),
                          color: Colors.black.withOpacity(0.9),
                          blurRadius: 0.5,
                        ),
                        Shadow(
                          offset: Offset(-1.5, -1.5),
                          color: Colors.black.withOpacity(0.9),
                          blurRadius: 0.5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height:8),
              // 스테이지 이미지 + 클리어 뱃지
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset(stage.image, width: 200, height: 200),
                  FutureBuilder<StageResult?>(
                    future: context.read<AppDataProvider>().loadStageResult(stage.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        final result = snapshot.data!;
                        if (result.cleared) {
                          return Positioned(
                            right: -8,
                            top: -8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "클리어",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 시작 버튼: 에너지 소모 후 게임 시작, 에너지 부족 시 다이얼로그 표시
              SizedBox(
                width: 180,
                height: 50,
                child: FutureBuilder<StageResult?>(
                  future: context.read<AppDataProvider>().loadStageResult(stage.id),
                  builder: (context, snapshot) {
                    final result = snapshot.data;
                    final isLocked = result?.locked ?? stage.locked;
                    if (isLocked) {
                      return GameButton(
                        text: "스테이지 잠김",
                        onPressed: () {},
                        width: 180,
                        height: 50,
                        color: Colors.grey,
                      );
                    } else {
                      return GameButton(
                        text: "게임 시작",
                        onPressed: () async {
                          final appData = context.read<AppDataProvider>();
                          final ok = await appData.spendEnergy(1);
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
                        width: 180,
                        height: 50,
                        color: const Color(0xFFFF9800), // Orange color
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          // 오른쪽 화살표 버튼: 다음 스테이지로 이동
          IconButton(
            icon: SizedBox(
              width: 40,
              height: 40,
              child: Image.asset('assets/images/right.png'),
            ),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}