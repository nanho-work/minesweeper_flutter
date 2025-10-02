class Stage {
  final int id;
  final String name;
  final bool locked;
  final String image; // 스테이지 배경 이미지 (assets)

  Stage({
    required this.id,
    required this.name,
    required this.locked,
    required this.image,
  });
}

final List<Stage> sampleStages = [
  Stage(id: 1, name: "스테이지 1", locked: false, image: "assets/images/stage1.png"),
  Stage(id: 2, name: "스테이지 2", locked: true, image: "assets/images/stage2.png"),
  Stage(id: 3, name: "스테이지 3", locked: true, image: "assets/images/stage3.png"),
];