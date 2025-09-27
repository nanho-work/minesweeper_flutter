import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_session_provider.dart';
import 'game_button.dart';

class GameCTAbar extends StatelessWidget {
  final VoidCallback onExit;
  final VoidCallback onRestart;

  const GameCTAbar({
    super.key,
    required this.onExit,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GameButton(
            text: "힌트",
            onPressed: () {
              Provider.of<GameSessionProvider>(context, listen: false)
                  .useHint(context);
            },
          ),
          GameButton(
            text: "새게임",
            onPressed: () {
              context.read<GameSessionProvider>().resetGame();
            },
          ),
          GameButton(
            text: "Stage",
            onPressed: onExit, // ✅ 수정
          ),
        ],
      ),
    );
  }
}