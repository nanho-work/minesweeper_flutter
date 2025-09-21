import 'package:flutter/material.dart';
import '../models/stage.dart';
import '../services/game_engine.dart';

class GameScreen extends StatefulWidget {
  final Stage stage;
  const GameScreen({super.key, required this.stage});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameEngine engine;

  @override
  void initState() {
    super.initState();
    engine = GameEngine();
    engine.init(widget.stage); // 스테이지 정보 기반 초기화
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.stage.name)),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: engine.cols,
        ),
        itemCount: engine.rows * engine.cols,
        itemBuilder: (context, index) {
          final row = index ~/ engine.cols;
          final col = index % engine.cols;
          final cell = engine.board[row][col];

          return GestureDetector(
            onTap: () {
              setState(() {
                cell.isRevealed = true;
              });
            },
            onLongPress: () {
              setState(() {
                cell.isFlagged = !cell.isFlagged;
              });
            },
            child: Container(
              margin: EdgeInsets.all(1),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                color: cell.isRevealed
                    ? (cell.isMine ? Colors.red : Colors.grey[400])
                    : Colors.grey[300],
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
        },
      ),
    );
  }
}