class StageCondition {
  final int maxHints;       // 힌트 허용 개수
  final int maxMistakes;    // 허용 하트 소진 수
  final int timeLimitSec;   // 제한 시간 (초 단위)

  StageCondition({
    required this.maxHints,
    required this.maxMistakes,
    required this.timeLimitSec,
  });
}

class Stage {
  final int id;
  final String name;
  final bool locked;
  final String image;
  final int rows;
  final int cols;
  final int mines;
  final bool cleared;
  final String? timeTaken;
  final int? mistakes;
  final DateTime? playedAt;
  final StageCondition condition;   // ✅ 조건 추가

  Stage({
    required this.id,
    required this.name,
    required this.locked,
    required this.image,
    required this.rows,
    required this.cols,
    required this.mines,
    required this.condition,        // ✅ 필수
    this.cleared = false,
    this.timeTaken,
    this.mistakes,
    this.playedAt,
  });
}

// 샘플 스테이지
final List<Stage> sampleStages = [
  Stage(
    id: 1,
    name: "스테이지 1",
    locked: false,
    image: "assets/images/stage1.png",
    rows: 8,
    cols: 8,
    mines: 10,
    condition: StageCondition(maxHints: 2, maxMistakes: 0, timeLimitSec: 180),
  ),
  Stage(
    id: 2,
    name: "스테이지 2",
    locked: true,
    image: "assets/images/stage1.png",
    rows: 10,
    cols: 10,
    mines: 20,
    condition: StageCondition(maxHints: 1, maxMistakes: 1, timeLimitSec: 300),
  ),
];