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
        
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("⏱ ${session.elapsed}s",
              style: const TextStyle(color: Colors.black87, fontSize: 16)),
          Row(
            children: List.generate(session.maxHearts, (index) {
              if (index < session.remainingHearts) {
                return const Icon(Icons.favorite, color: Colors.red, size: 20);
              } else {
                return const Icon(Icons.favorite_border, color: Colors.red, size: 20);
              }
            }),
          ),
          Text("💣 ${session.remainingMines}",
              style: const TextStyle(color: Colors.black87, fontSize: 16)),
        ],
      ),
    );
  }
}