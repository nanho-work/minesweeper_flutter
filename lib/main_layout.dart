import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/person_screen.dart';
import 'screens/stage_map_screen.dart';
import 'screens/game_screen.dart';
import 'screens/help_screen.dart';
import 'widgets/app_header.dart';
import 'widgets/app_footer.dart';
import 'models/game_stage.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;
  const MainLayout({super.key, this.initialIndex = 2});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex = widget.initialIndex; // 기본 Home

  Stage? _activeGameStage;

  void _startGame(Stage stage) {
    setState(() {
      _activeGameStage = stage;
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
      StageMapScreen(onStartGame: _startGame),
      const HelpScreen(), // ✅ SettingsScreen 대신 HelpScreen 배치
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
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_bg2.png',
              fit: BoxFit.cover,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              double maxWidth = constraints.maxWidth;
              double maxHeight = constraints.maxHeight;
              double headerHeight = maxHeight * 0.04;

              if (maxWidth < 600) {
                return SafeArea(
                  child: Column(
                    children: [
                      SizedBox(
                        height: headerHeight,
                        child: const AppHeader(), // ✅ 헤더에 설정 버튼 추가됨
                      ),
                      Expanded(
                        child: _activeGameStage != null
                            ? GameScreen(stage: _activeGameStage!)
                            : _screens[_selectedIndex],
                      ),
                      if (_activeGameStage == null)
                        SizedBox(
                          height: 120,
                          child: AppFooter(
                            currentIndex: _selectedIndex,
                            onTap: _onFooterTap,
                          ),
                        ),
                    ],
                  ),
                );
              }

              // 태블릿/웹
              return Center(
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: SafeArea(
                    child: Column(
                      children: [
                        SizedBox(
                          height: headerHeight,
                          child: const AppHeader(),
                        ),
                        Expanded(
                          child: _activeGameStage != null
                              ? GameScreen(stage: _activeGameStage!)
                              : _screens[_selectedIndex],
                        ),
                        if (_activeGameStage == null)
                          SizedBox(
                            height: 120,
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
        ],
      ),
    );
  }
}