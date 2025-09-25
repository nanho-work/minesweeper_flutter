import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_session_provider.dart';

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
          ElevatedButton(
            onPressed: () {
              Provider.of<GameSessionProvider>(context, listen: false)
                  .useHint(context);
            },
            child: const Icon(Icons.tips_and_updates),
          ),
          ElevatedButton(onPressed: () {}, child: const Text("레이더")),
          ElevatedButton(onPressed: () {}, child: const Text("시간정지")),
        ],
      ),
    );
  }
}