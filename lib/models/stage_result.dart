import 'dart:convert';

class StageResult {
  final int stageId; // 스테이지의 고유 ID
  final List<bool> conditions; // 조건별 달성 여부
  final int stars; // 획득한 별 개수
  final bool cleared; // 스테이지 클리어 여부
  final bool locked; // 잠금 여부
  final int elapsed; // 소요 시간(초)
  final int mistakes; // 실수 횟수
  final DateTime playedAt; // 플레이한 날짜 및 시간
  final List<bool> rewardsClaimed; // 보상 수령 여부 리스트
  final int attempts; // 시도 횟수
  final int bestElapsed; // 최고 기록(최단 시간)
  final int bestMistakes; // 최소 실수 기록

  StageResult({
    required this.stageId,
    required this.conditions,
    required this.stars,
    required this.cleared,
    required this.locked,
    required this.elapsed,
    required this.mistakes,
    required this.playedAt,
    required this.rewardsClaimed,
    required this.attempts,
    required this.bestElapsed,
    required this.bestMistakes,
  });

  Map<String, dynamic> toJson() => {
        "conditions": conditions,
        "stars": stars,
        "cleared": cleared,
        "locked": locked,
        "elapsed": elapsed,
        "mistakes": mistakes,
        "playedAt": playedAt.toIso8601String(),
        "rewardsClaimed": rewardsClaimed,
        "attempts": attempts,
        "bestElapsed": bestElapsed,
        "bestMistakes": bestMistakes,
      };

  factory StageResult.fromJson(int stageId, Map<String, dynamic> json) {
    return StageResult(
      stageId: stageId,
      conditions:
          List<bool>.from(json["conditions"] ?? [false, false, false]),
      stars: json["stars"] ?? 0,
      cleared: json["cleared"] ?? false,
      locked: json["locked"] ?? true,
      elapsed: json["elapsed"] ?? 0,
      mistakes: json["mistakes"] ?? 0,
      playedAt:
          DateTime.tryParse(json["playedAt"] ?? "") ?? DateTime.now(),
      rewardsClaimed: List<bool>.from(
          json["rewardsClaimed"] ?? [false, false, false]),
      attempts: json["attempts"] ?? 0,
      bestElapsed: json["bestElapsed"] ?? 0,
      bestMistakes: json["bestMistakes"] ?? 0,
    );
  }

  static StageResult initial(int stageId) {
    return StageResult(
      stageId: stageId,
      conditions: [false, false, false],
      stars: 0,
      cleared: false,
      locked: stageId != 1, // 1번만 기본 오픈
      elapsed: 0,
      mistakes: 0,
      playedAt: DateTime.now(),
      rewardsClaimed: [false, false, false],
      attempts: 0,
      bestElapsed: 0,
      bestMistakes: 0,
    );
  }
  StageResult copyWith({
    List<bool>? conditions,
    int? stars,
    bool? cleared,
    bool? locked,
    int? elapsed,
    int? mistakes,
    DateTime? playedAt,
    List<bool>? rewardsClaimed,
    int? attempts,
    int? bestElapsed,
    int? bestMistakes,
  }) {
    return StageResult(
      stageId: stageId,
      conditions: conditions ?? this.conditions,
      stars: stars ?? this.stars,
      cleared: cleared ?? this.cleared,
      locked: locked ?? this.locked,
      elapsed: elapsed ?? this.elapsed,
      mistakes: mistakes ?? this.mistakes,
      playedAt: playedAt ?? this.playedAt,
      rewardsClaimed: rewardsClaimed ?? this.rewardsClaimed,
      attempts: attempts ?? this.attempts,
      bestElapsed: bestElapsed ?? this.bestElapsed,
      bestMistakes: bestMistakes ?? this.bestMistakes,
    );
  }
}