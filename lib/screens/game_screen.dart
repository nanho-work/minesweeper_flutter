import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_session_provider.dart';
import '../widgets/game_header.dart';
import '../widgets/game_board.dart';
import '../widgets/game_cta_bar.dart';
import '../models/game_stage.dart';
import '../providers/app_data_provider.dart';
import '../widgets/dialogs/game_dialog.dart';
import '../widgets/ad_banner.dart';

class GameScreen extends StatelessWidget {
  final Stage stage;
  const GameScreen({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = GameSessionProvider(stage);

        provider.onGameOver = () {
          Future.microtask(() {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => WillPopScope(
                onWillPop: () async => false,
                child: GameDialog(
                  title: "게임 오버",
                  content: "실패하셨습니다.",
                  confirmText: "새게임",
                  cancelText: "스테이지",
                  onConfirm: () {
                    provider.resetGame();
                    Navigator.of(context).pop();
                  },
                  onCancel: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).maybePop();
                  },
                ),
              ),
            );
          });
        };

        provider.onGameClear = () async {
          if (provider.checkClearCondition(stage, context)) {
            final appData = Provider.of<AppDataProvider>(context, listen: false);
            await appData.saveStageResult(
              stage.id,
              conditions: [
                provider.starsEarned >= 1,
                provider.starsEarned >= 2,
                provider.starsEarned >= 3,
              ],
              elapsed: provider.elapsed,
              mistakes: provider.mistakes,
            );

            Future.microtask(() {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => WillPopScope(
                  onWillPop: () async => false,
                  child: GameDialog(
                    title: "클리어!",
                    content:
                        "⭐️ 별: ${provider.starsEarned} / 3\n남은 생명: ${provider.remainingHearts}\n도전 횟수: ${provider.attempts}\n소요 시간: ${provider.elapsed} 초",
                    confirmText: "다음 스테이지",
                    cancelText: "스테이지 맵",
                    onConfirm: () {
                      // 현재 스테이지 ID + 1
                      final nextStageId = stage.id + 1;
                      // 스테이지 리스트에서 다음 스테이지 찾기
                      final stages = sampleStages;
                      final nextStage = stages.firstWhere(
                        (s) => s.id == nextStageId,
                        orElse: () => stage,
                      );
                      // 다이얼로그 닫기
                      Navigator.of(context).pop();
                      // 새로운 GameScreen으로 이동
                      if (nextStage != stage) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => GameScreen(stage: nextStage),
                          ),
                        );
                      }
                    },
                    onCancel: () {
                      Navigator.of(context).pop();      // 다이얼로그 닫기
                      Navigator.of(context).maybePop(); // 🔥 스택에 StageMapScreen이 남아 있으면 복귀
                    },
                  ),
                ),
              );
            });
          }
        };

        return provider;
      },
      child: Consumer<GameSessionProvider>(
        builder: (context, session, _) {
          return Scaffold(
            body: SafeArea(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/background-texture-sky.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: const [
                    SafeArea(child: AdBanner()),
                    GameHeader(),
                    Expanded(child: GameBoard()),
                    GameCTAbar(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}