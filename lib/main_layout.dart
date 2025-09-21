import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/person_screen.dart';
import 'screens/help_screen.dart';
import 'screens/stage_map_screen.dart';
import 'screens/game_screen.dart';
import 'widgets/app_header.dart';
import 'widgets/app_footer.dart';
import 'models/stage.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;
  const MainLayout({super.key, this.initialIndex = 2});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex = widget.initialIndex; // 기본 Home

  int gems = 10;
  int gold = 500;
  int energy = 5;

  Stage? _activeGameStage;

  void _startGame(Stage stage) {
    setState(() {
      _activeGameStage = stage;
      // 선택된 인덱스는 유지 (헤더/컨테이너 제약을 그대로 받음)
    });
  }

  void _exitGame() {
    setState(() {
      _activeGameStage = null;
    });
  }

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const ShopScreen(),
      const PersonScreen(),
      const HomeScreen(),
      const HelpScreen(),
      const SettingsScreen(),
      StageMapScreen(onStartGame: _startGame),
      // GameScreen은 리스트에서 제거합니다. (stage 파라미터 필요)
    ];
  }

  void _onFooterTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;
          double maxHeight = constraints.maxHeight;
          double headerHeight = maxHeight * 0.04;

          // 모바일 (600 이하) → 전체 꽉 채움
          if (maxWidth < 600) {
            return SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    height: headerHeight,
                    child: AppHeader(gems: gems, gold: gold, energy: energy),
                  ),
                  Expanded(
                    child: _activeGameStage != null
                        ? GameScreen(stage: _activeGameStage!)
                        : _screens[_selectedIndex],
                  ),
                  if (_selectedIndex != 5 && _activeGameStage == null)
                    SizedBox(
                      height: 60,
                      child: AppFooter(
                        currentIndex: _selectedIndex,
                        onTap: _onFooterTap,
                      ),
                    ),
                ],
              ),
            );
          }

          // 태블릿/웹 → 중앙에 9:16 박스로 제한
          return Center(
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: headerHeight,
                      child: AppHeader(gems: gems, gold: gold, energy: energy, showBackButton: _selectedIndex == 5 || _activeGameStage != null),
                    ),
                    Expanded(
                      child: _activeGameStage != null
                          ? GameScreen(stage: _activeGameStage!)
                          : _screens[_selectedIndex],
                    ),
                    if (_selectedIndex != 5 && _activeGameStage == null)
                      SizedBox(
                        height: 60,
                        child: AppFooter(
                          currentIndex: _selectedIndex,
                          onTap: _onFooterTap,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}