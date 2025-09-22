import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_session_provider.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<GameSessionProvider>();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("⏱ ${session.elapsed}s",
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text("♥ ${session.remainingHearts}",
              style: const TextStyle(color: Colors.red, fontSize: 16)),
          Text("💣 ${session.remainingMines}",
              style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}