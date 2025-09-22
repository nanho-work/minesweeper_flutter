import 'package:flutter/material.dart';

class GameCTAbar extends StatelessWidget {
  const GameCTAbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(onPressed: () {}, child: const Text("힌트")),
          ElevatedButton(onPressed: () {}, child: const Text("레이더")),
          ElevatedButton(onPressed: () {}, child: const Text("시간정지")),
        ],
      ),
    );
  }
}