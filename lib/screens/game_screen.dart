import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_session_provider.dart';
import '../widgets/game_header.dart';
import '../widgets/game_board.dart';
import '../widgets/game_cta_bar.dart';
import '../models/game_stage.dart';

class GameScreen extends StatelessWidget {
  final Stage stage;
  const GameScreen({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = GameSessionProvider(stage);

        /// 게임 오버 시 다이얼로그 실행
        provider.onGameOver = () {
          Future.microtask(() {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return WillPopScope(
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
                );
              },
            );
          });
        };

        /// ✅ 게임 클리어 시 다이얼로그 실행
        provider.onGameClear = () {
          Future.microtask(() {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return WillPopScope(
                  onWillPop: () async => false,
                  child: AlertDialog(
                    title: const Text("클리어!"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("남은 생명: ${provider.remainingHearts}"),
                        Text("도전 횟수: ${provider.attempts}"),
                        Text("소요 시간: ${provider.elapsed} 초"),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // 다음 스테이지 이동 (잠금 해제 처리 필요)
                          Navigator.of(context).pop();
                          // TODO: 다음 스테이지 이동 로직 연결
                        },
                        child: const Text("다음 스테이지"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).maybePop();
                        },
                        child: const Text("스테이지 맵"),
                      ),
                    ],
                  ),
                );
              },
            );
          });
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