import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppFooter({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 아이콘/라벨 데이터
    final List<Map<String, String>> items = const [
      {'icon': 'assets/images/footer/store.png', 'label': '상점'},
      {'icon': 'assets/images/footer/character.png', 'label': '캐릭터'},
      {'icon': 'assets/images/footer/home.png', 'label': '홈'},
      {'icon': 'assets/images/footer/guide.png', 'label': '게임안내'},
      {'icon': 'assets/images/footer/setting.png', 'label': '설정'},
    ];

    // ====== 레이아웃 상수 ======
    const double baseIconSize = 52; // 기본 아이콘 크기
    const double selectedScale = 1.5; // 선택 시 스케일
    const double itemWidth = 70; // 각 버튼영역 가로 폭(스케일 고려해서 여유있게)
    const double footerHeight = 74; // 푸터 고정 높이(텍스트 + 기본 아이콘 기준)

    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      color: Colors.transparent,
      height: footerHeight + bottomInset, // 고정 높이로 오버플로우 방지
      padding: EdgeInsets.only(top: 6, bottom: bottomInset > 0 ? 6 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final bool isSelected = currentIndex == index;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(index),
            child: SizedBox(
              width: itemWidth,
              // Column의 높이를 푸터 높이 안에서만 계산하도록 제한
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ==== 아이콘 영역 ====
                  // 레이아웃 높이는 baseIconSize로 고정하고,
                  // 그림만 스케일 + 위쪽으로 살짝 끌어올려 "튀어나오는" 효과를 냅니다.
                  SizedBox(
                    height: baseIconSize,
                    child: Stack(
                      clipBehavior: Clip.none, // 위쪽으로 그림이 넘어가도록 허용
                      children: [
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: Transform.translate(
                              // 스케일이 커질수록 위로 올려서 아래쪽 오버플로우를 막음
                              offset: Offset(
                                0,
                                isSelected
                                    ? -((baseIconSize * (selectedScale - 1)) / 2)
                                    : 0,
                              ),
                              child: Transform.scale(
                                scale: isSelected ? selectedScale : 1.0,
                                child: Image.asset(
                                  items[index]['icon']!,
                                  width: baseIconSize,
                                  height: baseIconSize,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  // ==== 라벨 ====
                  Text(
                    items[index]['label']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : (Theme.of(context).textTheme.bodySmall?.color ?? Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}