import 'package:flutter/material.dart';
import '../services/game_engine.dart';

class GameCell extends StatelessWidget {
  final int row;
  final int col;
  final Cell cell;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const GameCell({
    super.key,
    required this.row,
    required this.col,
    required this.cell,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          // 셀 구분 라인 색상 추가
          border: Border.all(color: Colors.blue, width: 1), // ← 여기
          color: cell.isRevealed
              ? (cell.isMine ? Colors.red : Colors.grey[300])
              : Colors.grey[200],
        ),
        child: Center(
          child: cell.isRevealed
              ? (cell.isMine
                  ? const Icon(Icons.circle, color: Colors.black, size: 16)
                  : (cell.neighborMines > 0
                      ? Text(
                          '${cell.neighborMines}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        )
                      : const SizedBox.shrink()))
              : (cell.isFlagged
                  ? const Icon(Icons.flag, color: Colors.red, size: 16)
                  : const SizedBox.shrink()),
        ),
      ),
    );
  }
}