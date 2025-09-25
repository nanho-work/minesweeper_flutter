import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_session_provider.dart';
import '../widgets/game_header.dart';
import '../widgets/game_board.dart';
import '../widgets/game_cta_bar.dart';
import '../models/game_stage.dart';
import '../providers/app_data_provider.dart';

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
                child: AlertDialog(
                  title: const Text("게임 오버"),
                  content: const Text("실패하셨습니다."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        provider.resetGame();
                        Navigator.of(context).pop();
                      },
                      child: const Text("새게임"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).maybePop();
                      },
                      child: const Text("스테이지"),
                    ),
                  ],
                ),
              ),
            );
          });
        };

        provider.onGameClear = () async {
          if (provider.checkClearCondition(stage)) {
            final appData = Provider.of<AppDataProvider>(context, listen: false);
            await appData.saveStageResult(
              stage.id,
              stars: provider.starsEarned,
              mistakes: provider.mistakes,
              elapsed: provider.elapsed,
            );

            Future.microtask(() {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => WillPopScope(
                  onWillPop: () async => false,
                  child: AlertDialog(
                    title: const Text("클리어!"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("⭐️ 별: ${provider.starsEarned} / 3"),
                        Text("남은 생명: ${provider.remainingHearts}"),
                        Text("도전 횟수: ${provider.attempts}"),
                        Text("소요 시간: ${provider.elapsed} 초"),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("다음 스테이지"),
                      ),
                    ],
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
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: const [
                  GameHeader(),
                  Expanded(child: GameBoard()),
                  GameCTAbar(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}