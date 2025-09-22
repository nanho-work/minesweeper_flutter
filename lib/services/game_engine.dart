import 'dart:math';
import '../models/game_stage.dart';

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

  /// 게임 보드를 초기화하고 지뢰를 배치하며 주변 지뢰 수를 계산하는 메서드
  void init(Stage stage) {
    rows = stage.rows;
    cols = stage.cols;
    mines = stage.mines;

    // 빈 보드 생성
    board = List.generate(rows, (_) => List.generate(cols, (_) => Cell()));

    _placeMines();       // 지뢰 배치
    _calculateNumbers(); // 주변 지뢰 수 계산
  }

  /// 보드에 지뢰를 무작위로 배치하는 메서드
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

  /// 각 셀 주변에 있는 지뢰 수를 계산하여 셀에 저장하는 메서드
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

  /// 현재 보드에 놓인 깃발의 총 개수를 반환하는 게터
  int get flagsPlaced {
    int count = 0;
    for (var row in board) {
      for (var cell in row) {
        if (cell.isFlagged) count++;
      }
    }
    return count;
  }

  /// 특정 위치의 셀을 오픈(공개)하는 메서드
  /// 빈칸(지뢰가 아니고 neighborMines == 0)이면 주변 칸을 재귀적으로 모두 오픈
  void reveal(int row, int col) {
    final cell = board[row][col];
    if (cell.isRevealed || cell.isFlagged) return; // 이미 열려있거나 깃발이면 무시
    cell.isRevealed = true;

    // 빈칸이면 주변 재귀적으로 오픈
    if (!cell.isMine && cell.neighborMines == 0) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          int nr = row + dr;
          int nc = col + dc;
          if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
            reveal(nr, nc); // 재귀 호출
          }
        }
      }
    }
  }

  /// 특정 위치의 셀에 깃발을 토글하는 메서드
  void toggleFlag(int row, int col) {
    board[row][col].isFlagged = !board[row][col].isFlagged;
  }

  /// 숫자 셀을 롱탭했을 때 주변 셀을 자동으로 여는 메서드
  /// - 주변의 깃발 + 이미 열린 지뢰 칸을 합산하여 카운트
  /// - 이 값이 현재 셀의 숫자와 같으면 나머지 닫힌 칸을 모두 오픈
  void openAdjacent(int row, int col) {
    final cell = board[row][col];
    if (!cell.isRevealed) return; // 현재 셀이 열려있지 않으면 동작하지 않음

    int markedCount = 0; // 깃발 + 열린 지뢰 카운트

    // 주변 8칸 검사
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        int nr = row + dr;
        int nc = col + dc;
        if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
          final neighbor = board[nr][nc];
          if (neighbor.isFlagged || (neighbor.isRevealed && neighbor.isMine)) {
            markedCount++;
          }
        }
      }
    }

    // 주변 마킹 수 == 현재 셀의 숫자일 때 나머지 닫힌 셀 오픈
    if (markedCount == cell.neighborMines) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          int nr = row + dr;
          int nc = col + dc;
          if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
            var neighbor = board[nr][nc];
            if (!neighbor.isRevealed && !neighbor.isFlagged) {
              // 지뢰가 아닌 경우만 열기
              if (!neighbor.isMine) {
                neighbor.isRevealed = true;
                // 주변 지뢰가 없으면 재귀적으로 열기
                if (neighbor.neighborMines == 0) {
                  openAdjacent(nr, nc);
                }
              }
            }
          }
        }
      }
    }
  }
}