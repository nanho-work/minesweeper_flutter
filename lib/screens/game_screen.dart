import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_session_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/game_header.dart';
import '../widgets/game_board.dart';
import '../widgets/game_cta_bar.dart';
import '../models/game_stage.dart';
import '../providers/app_data_provider.dart';
import '../widgets/dialogs/game_dialog.dart';
import '../widgets/ad_banner.dart';
import '../services/sound_service.dart';

class GameScreen extends StatefulWidget {
  final Stage stage;
  final VoidCallback onExit;     // ✅ 추가
  final VoidCallback onRestart;  // ✅ 추가

  const GameScreen({
    super.key,
    required this.stage,
    required this.onExit,
    required this.onRestart,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppDataProvider>().enterGameBgm();
  }

  @override
  void dispose() {
    context.read<AppDataProvider>().exitGameBgm();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = GameSessionProvider(widget.stage);

        provider.onGameOver = () {
          SoundService.playLose();
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
                    widget.onExit(); // ✅ 스테이지 맵으로 복귀
                  },
                ),
              ),
            );
          });
        };

        provider.onGameClear = () async {
          if (provider.checkClearCondition(widget.stage, context)) {
            final appData = Provider.of<AppDataProvider>(context, listen: false);

            await appData.saveStageResult(
              stageId: widget.stage.id,
              conditions: [
                provider.starsEarned >= 1,
                provider.starsEarned >= 2,
                provider.starsEarned >= 3,
              ],
              elapsed: provider.elapsed,
              mistakes: provider.mistakes,
            );

            // ✅ 저장 후 최신 StageResult 불러오기
            final latestResult = await appData.loadStageResult(widget.stage.id);

            SoundService.playVictory();

            Future.microtask(() {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => WillPopScope(
                  onWillPop: () async => false,
                  child: GameDialog(
                    title: "클리어!",
                    content: "⭐️ 별: ${provider.starsEarned} / 3\n"
                        "남은 생명: ${provider.remainingHearts}\n"
                        "도전 횟수: ${latestResult?.attempts ?? 1}\n"
                        "소요 시간: ${provider.elapsed} 초",
                    confirmText: "다음",
                    cancelText: "맵",
                    onConfirm: () {
                      final nextStageId = widget.stage.id + 1;
                      final stages = sampleStages;
                      final nextStage = stages.firstWhere(
                        (s) => s.id == nextStageId,
                        orElse: () => widget.stage,
                      );

                      Navigator.of(context).pop();

                      if (nextStage != widget.stage) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => GameScreen(
                              stage: nextStage,
                              onExit: widget.onExit,
                              onRestart: widget.onRestart,
                            ),
                          ),
                        );
                      }
                    },
                    onCancel: () {
                      Navigator.of(context).pop();
                      widget.onExit();
                    },
                  ),
                ),
              );
            });
          }
        };

        return provider;
      },
      child: Consumer2<GameSessionProvider, ThemeProvider>(
        builder: (context, session, themeProvider, _) {
          final theme = themeProvider.currentTheme;

          return Scaffold(
            body: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200], // 기본 배경
                  image: theme.backgroundImage != null
                      ? DecorationImage(
                          image: AssetImage(theme.backgroundImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Column(
                  children: [
                    const GameHeader(),
                    const Expanded(child: GameBoard()),
                    GameCTAbar(
                      onExit: widget.onExit,
                      onRestart: widget.onRestart,
                    ),
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