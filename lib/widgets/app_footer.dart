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
    final List<Map<String, String>> items = const [
      {'icon': 'assets/images/footer/store.png', 'label': '상점'},
      {'icon': 'assets/images/footer/skin.png', 'label': '스킨'},
      {'icon': 'assets/images/footer/home.png', 'label': '홈'},
      {'icon': 'assets/images/footer/stage.png', 'label': '스테이지'},
      {'icon': 'assets/images/footer/guide.png', 'label': '도움말'}, // ✅ 변경
    ];

    const double baseIconSize = 52;
    const double selectedScale = 1.5;
    const double itemWidth = 70;
    const double footerHeight = 74;

    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.9),
          ],
        ),
      ),
      height: footerHeight + bottomInset,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: baseIconSize,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: Transform.translate(
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
                  if (isSelected) ...[
                    const SizedBox(height: 2),
                    Text(
                      items[index]['label']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black),
                          Shadow(offset: Offset(-1, 1), blurRadius: 2, color: Colors.black),
                          Shadow(offset: Offset(1, -1), blurRadius: 2, color: Colors.black),
                          Shadow(offset: Offset(-1, -1), blurRadius: 2, color: Colors.black),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}