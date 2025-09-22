import 'dart:async';
import 'package:flutter/material.dart';

import '../models/game_stage.dart';
import '../services/game_engine.dart';
import '../services/sound_service.dart';

class GameSessionProvider extends ChangeNotifier {
  final Stage stage;
  late GameEngine engine;

  int elapsed = 0;
  int mistakes = 0;
  int maxHearts = 3;
  Timer? _timer;

  /// 게임 오버 시 실행할 콜백
  VoidCallback? onGameOver;

  /// 게임 클리어 시 실행할 콜백
  VoidCallback? onGameClear;

  /// 게임 시도 횟수
  int attempts = 0;

  GameSessionProvider(this.stage) {
    attempts++;
    engine = GameEngine();
    engine.init(stage);
    _startTimer();
  }

  int get remainingHearts => maxHearts - mistakes;
  int get remainingMines => stage.mines - engine.flagsPlaced;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsed++;
      notifyListeners();
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void resetGame() {
    stopTimer();        // 기존 타이머 중단
    elapsed = 0;        // 시간 초기화
    mistakes = 0;       // 실수 초기화
    engine.init(stage); // 보드 다시 생성
    attempts++;         // 게임 시도 횟수 증가
    _startTimer();      // 타이머 다시 시작
    notifyListeners();  // UI 갱신
  }

  void onCellTap(int row, int col) {
    if (engine.board[row][col].isMine) {
      mistakes++;
      SoundService.playBomb();
      if (remainingHearts <= 0) {
        stopTimer();
        SoundService.playLose();
        onGameOver?.call(); // 게임 오버 즉시 실행
      }
    } else {
      SoundService.playTap();
    }
    engine.reveal(row, col);
    notifyListeners();
    _checkClear();
  }

  void onCellLongPress(int row, int col) {
    final cell = engine.board[row][col];
    if (cell.isRevealed && cell.neighborMines > 0) {
      engine.openAdjacent(row, col);
      // Check if any newly revealed cell is a mine
      for (var rowCells in engine.board) {
        for (var c in rowCells) {
          if (c.isRevealed && c.isMine) {
            mistakes++;
            if (remainingHearts <= 0) {
              stopTimer();
              onGameOver?.call();
              break;
            }
          }
        }
      }
    } else if (!cell.isRevealed) {
      engine.toggleFlag(row, col);
      SoundService.playFlag();
    }
    notifyListeners();
  }

  /// 모든 지뢰가 아닌 칸이 공개되었는지 확인하는 메서드
  void _checkClear() {
    for (var row in engine.board) {
      for (var cell in row) {
        if (!cell.isMine && !cell.isRevealed) {
          return;
        }
      }
    }
    stopTimer();
    SoundService.playVictory();
    onGameClear?.call();
  }
}