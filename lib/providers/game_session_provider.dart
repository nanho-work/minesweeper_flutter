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

  // 힌트 관련 필드
  int hintUsed = 0;
  final int maxHints = 5;

  VoidCallback? onGameOver;
  VoidCallback? onGameClear;

  GameSessionProvider(this.stage) {
    attempts++;
    engine = GameEngine();
    engine.init(stage);
    _startTimer();
  }

  int get remainingHearts => maxHearts - mistakes;
  int get remainingMines => stage.mines - (engine.flagsPlaced + engine.openedMines);
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

  void onCellTap(int row, int col, BuildContext context) {
    final cell = engine.board[row][col];
    if (cell.isFlagged) {
      return; // 깃발이 꽂힌 셀은 무시
    }
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
    _checkClear(context);
  }

  void onCellLongPress(int row, int col, BuildContext context) {
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
    _checkClear(context);
  }

  /// 게임 클리어 판정 및 기록 저장은 외부에서 처리
  void _checkClear(BuildContext context) {
    if (checkClearCondition(stage, context)) {
      stopTimer();
      SoundService.playVictory();
      onGameClear?.call();
    }
  }

  /// 게임 클리어 조건 검사 및 별 개수 계산
  bool checkClearCondition(Stage stage, BuildContext context) {
    for (var row in engine.board) {
      for (var cell in row) {
        if (!cell.isMine && !cell.isRevealed) {
          return false;
        }
      }
    }

    // 조건 배열
    final conditions = [
      hintUsed <= stage.condition.maxHints,
      mistakes <= stage.condition.maxMistakes,
      elapsed <= stage.condition.timeLimitSec,
    ];

    _starsEarned = conditions.where((c) => c).length;

    // 기록 저장 (조건 배열 전달)
    final appData = Provider.of<AppDataProvider>(
      context, listen: false);
    appData.saveStageResult(
      stage.id,
      conditions: conditions,
      elapsed: elapsed,
      mistakes: mistakes,
    );

    return true;
  }
  Future<void> useHint(BuildContext context) async {
    if (hintUsed >= maxHints) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("힌트는 최대 5회까지 사용 가능합니다.")),
      );
      return;
    }

    final appData = Provider.of<AppDataProvider>(context, listen: false);
    if (!await appData.spendGold(50)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("골드가 부족합니다!")),
      );
      return;
    }

    // 좌표 인덱스를 직접 탐색
    for (int r = 0; r < engine.board.length; r++) {
      for (int c = 0; c < engine.board[r].length; c++) {
        final cell = engine.board[r][c];
        if (!cell.isMine && !cell.isRevealed) {
          engine.reveal(r, c); // ✅ row, col 인덱스로 전달
          hintUsed++;
          notifyListeners();
          return;
        }
      }
    }
  }
}