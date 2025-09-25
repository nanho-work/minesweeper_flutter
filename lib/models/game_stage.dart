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
final List<Stage> sampleStages = List.generate(30, (index) {
  final id = index + 1;

  int rows, cols, mines, timeLimit, maxHints, maxMistakes;

  if (id <= 10) {
    // 1~10
    rows = 7 + id; // 8 → 17
    cols = 8;
    mines = 10 + id; // 11 → 20
    timeLimit = 180 + id * 2; // 180 → 200
    maxHints = 0;
    maxMistakes = 0;
  } else if (id <= 20) {
    // 11~20
    rows = id - 1; // 10 → 19
    cols = 10;
    mines = 20 + (id - 10) * 2; // 22 → 40
    timeLimit = 240 + (id - 10) * 3; // 243 → 270
    maxHints = 2;
    maxMistakes = 2;
  } else {
    // 21~30
    rows = (id - 9); // 12 → 21
    cols = 12;
    mines = 30 + (id - 20) * 2; // 32 → 50
    timeLimit = 300 + (id - 20) * 6; // 306 → 360
    maxHints = 1;
    maxMistakes = 1;
  }

  return Stage(
    id: id,
    name: "스테이지 $id",
    locked: id != 1, // 1만 오픈, 나머지는 잠금
    image: "assets/images/stage1.png",
    rows: rows,
    cols: cols,
    mines: mines,
    condition: StageCondition(
      maxHints: maxHints,
      maxMistakes: maxMistakes,
      timeLimitSec: timeLimit,
    ),
  );
});