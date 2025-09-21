import 'dart:math';
import '../models/stage.dart';

class Cell {
  bool isMine;
  bool isRevealed;
  bool isFlagged;
  int neighborMines;

  Cell({
    this.isMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.neighborMines = 0,
  });
}

class GameEngine {
  late int rows;
  late int cols;
  late int mines;
  late List<List<Cell>> board;

  void init(Stage stage) {
    rows = stage.rows;
    cols = stage.cols;
    mines = stage.mines;

    // 보드 초기화
    board = List.generate(rows, (_) =>
      List.generate(cols, (_) => Cell()));

    _placeMines();
    _calculateNumbers();
  }

  void _placeMines() {
    int placed = 0;
    final random = Random();
    while (placed < mines) {
      int r = random.nextInt(rows);
      int c = random.nextInt(cols);
      if (!board[r][c].isMine) {
        board[r][c].isMine = true;
        placed++;
      }
    }
  }

  void _calculateNumbers() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (board[r][c].isMine) continue;
        int count = 0;
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            int nr = r + dr;
            int nc = c + dc;
            if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
              if (board[nr][nc].isMine) count++;
            }
          }
        }
        board[r][c].neighborMines = count;
      }
    }
  }
}