import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_data_provider.dart';
import '../models/game_stage.dart';
import '../services/game_engine.dart';
import '../services/sound_service.dart';

class GameSessionProvider extends ChangeNotifier {
  final Stage stage;
  late GameEngine engine;

  int elapsed = 0;
  int mistakes = 0;
  int maxHearts = 3;
  int attempts = 0;
  int _starsEarned = 0;
  Timer? _timer;

  VoidCallback? onGameOver;
  VoidCallback? onGameClear;

  GameSessionProvider(this.stage) {
    attempts++;
    engine = GameEngine();
    engine.init(stage);
    _startTimer();
  }

  int get remainingHearts => maxHearts - mistakes;
  int get remainingMines => stage.mines - engine.flagsPlaced;
  int get starsEarned => _starsEarned;

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
    stopTimer();
    elapsed = 0;
    mistakes = 0;
    engine.init(stage);
    attempts++;
    _startTimer();
    notifyListeners();
  }

  void onCellTap(int row, int col) {
    final cell = engine.board[row][col];
    if (!cell.isRevealed && cell.isMine) {
      mistakes++;
      SoundService.playBomb();
      if (remainingHearts <= 0) {
        stopTimer();
        SoundService.playLose();
        onGameOver?.call();
      }
    } else if (!cell.isMine) {
      SoundService.playTap();
    }
    engine.reveal(row, col);
    notifyListeners();
    _checkClear();
  }

  void onCellLongPress(int row, int col) {
    final cell = engine.board[row][col];
    if (cell.isRevealed && cell.neighborMines > 0) {
      final newlyOpened = engine.openAdjacent(row, col);
      for (var p in newlyOpened) {
        final openedCell = engine.board[p.x][p.y];
        if (openedCell.isMine) {
          mistakes++;
          SoundService.playBomb();
          if (remainingHearts <= 0) {
            stopTimer();
            SoundService.playLose();
            onGameOver?.call();
            break;
          }
        }
      }
    } else if (!cell.isRevealed) {
      engine.toggleFlag(row, col);
      SoundService.playFlag();
    }
    notifyListeners();
    _checkClear();
  }

  /// 게임 클리어 판정 및 기록 저장은 외부에서 처리
  void _checkClear() {
    if (checkClearCondition(stage)) {
      stopTimer();
      SoundService.playVictory();
      onGameClear?.call();
    }
  }

  /// 게임 클리어 조건 검사 및 별 개수 계산
  bool checkClearCondition(Stage stage) {
    for (var row in engine.board) {
      for (var cell in row) {
        if (!cell.isMine && !cell.isRevealed) {
          return false;
        }
      }
    }

    // ✅ 조건 판정
    final conditions = [
      true, // 힌트 조건(미구현 → 임시 true)
      mistakes <= stage.condition.maxMistakes,
      elapsed <= stage.condition.timeLimitSec,
    ];

    _starsEarned = conditions.where((c) => c).length;
    return true;
  }
}