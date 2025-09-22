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

  Stage({
    required this.id,
    required this.name,
    required this.locked,
    required this.image,
    required this.rows,
    required this.cols,
    required this.mines,
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
  ),
  Stage(
    id: 2,
    name: "스테이지 2",
    locked: true,
    image: "assets/images/stage2.png",
    rows: 10,
    cols: 10,
    mines: 20,
  ),
  Stage(
    id: 3,
    name: "스테이지 3",
    locked: true,
    image: "assets/images/stage3.png",
    rows: 12,
    cols: 12,
    mines: 30,
  ),
];