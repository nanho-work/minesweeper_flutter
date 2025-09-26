import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_session_provider.dart';
import 'game_button.dart';

class GameCTAbar extends StatelessWidget {
  const GameCTAbar({super.key});

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
              Provider.of<GameSessionProvider>(context, listen: false).resetGame();
            },
          ),
          GameButton(
            text: "stage",
            onPressed: () {
              Navigator.of(context).maybePop();
            },
          ),
        ],
      ),
    );
  }
}