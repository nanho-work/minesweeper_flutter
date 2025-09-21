class Stage {
  final int id;        // 스테이지 번호
  final String name;   // 스테이지 이름
  final bool locked;   // 잠금 여부
  final String image;  // 스테이지 이미지 경로
  final int rows;      // 보드 행 수
  final int cols;      // 보드 열 수
  final int mines;     // 지뢰 개수

  Stage({
    required this.id,
    required this.name,
    required this.locked,
    required this.image,
    required this.rows,
    required this.cols,
    required this.mines,
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