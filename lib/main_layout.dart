// lib/main_layout.dart
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/person_screen.dart';
import 'screens/stage_map_screen.dart';
import 'screens/game_screen.dart';
import 'screens/help_screen.dart';
import 'widgets/app_header.dart';
import 'widgets/app_footer.dart';
import 'models/game_stage.dart';
import 'providers/app_data_provider.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;
  const MainLayout({super.key, this.initialIndex = 2}); // 기본값 HomeScreen

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex = widget.initialIndex;
  Stage? _activeGameStage;

  void _startGame(Stage stage) {
    setState(() {
      _activeGameStage = stage;
    });
    context.read<AppDataProvider>().enterGameBgm(); // 게임 BGM 시작
  }

  void _exitGame() {
    setState(() {
      _activeGameStage = null;
    });
    context.read<AppDataProvider>().exitGameBgm(); // 메인 BGM 복귀
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
      const HelpScreen(),
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
              'assets/images/app_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              double maxWidth = constraints.maxWidth;
              double maxHeight = constraints.maxHeight;
              double headerHeight = maxHeight * 0.13;

              if (maxWidth < 600) {
                // 모바일
                return SafeArea(
                  child: Column(
                    children: [
                      SizedBox(
                        height: headerHeight,
                        child: const AppHeader(),
                      ),
                      Expanded(
                        child: _activeGameStage != null
                            ? GameScreen(
                                stage: _activeGameStage!,
                                onExit: _exitGame,
                                onRestart: () => _startGame(_activeGameStage!),
                              )
                            : _screens[_selectedIndex],
                      ),
                      if (_activeGameStage == null)
                        AppFooter(
                          currentIndex: _selectedIndex,
                          onTap: _onFooterTap,
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
                              ? GameScreen(
                                  stage: _activeGameStage!,
                                  onExit: _exitGame,
                                  onRestart: () => _startGame(_activeGameStage!),
                                )
                              : _screens[_selectedIndex],
                        ),
                        if (_activeGameStage == null)
                          AppFooter(
                            currentIndex: _selectedIndex,
                            onTap: _onFooterTap,
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