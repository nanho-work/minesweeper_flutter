import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_session_provider.dart';
import 'game_cell.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<GameSessionProvider>();
    final engine = session.engine;

    return Container(
      // 전체 보드 아웃라인 색상 추가
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 4), // ← 여기
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: engine.cols,
        ),
        itemCount: engine.rows * engine.cols,
        itemBuilder: (context, index) {
          final row = index ~/ engine.cols;
          final col = index % engine.cols;
          final cell = engine.board[row][col];

          return GameCell(
            row: row,
            col: col,
            cell: cell,
            onTap: () => session.onCellTap(row, col),
            onLongPress: () => session.onCellLongPress(row, col),
          );
        },
      ),
    );
  }
}