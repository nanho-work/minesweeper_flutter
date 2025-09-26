// lib/main.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';

import 'providers/app_data_provider.dart';
import 'providers/product_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'services/ad_service.dart';
import 'services/sound_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 광고 초기화 (웹 제외)
  if (!kIsWeb) {
    try {
      await MobileAds.instance.initialize();
      debugPrint("AdMob 초기화 성공");

      // ✅ 보상형 광고 미리 로드
      await AdService.loadRewardedAd();
    } catch (e, stack) {
      debugPrint("AdMob 초기화 실패: $e");
    }
  }

  // ✅ 세로모드 고정
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // ✅ CurrencyProvider 초기화
  final currencyProvider = AppDataProvider();
  await currencyProvider.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppDataProvider()), // 골드/보석
        ChangeNotifierProvider(create: (_) => ProductProvider()..loadProducts()), // 상품
        ChangeNotifierProvider(create: (_) => InventoryProvider()..load()), // 인벤토리

        // ✅ ThemeProvider: Inventory + ProductProvider 동시 연결
        ChangeNotifierProxyProvider2<InventoryProvider, ProductProvider, ThemeProvider>(
          create: (_) => ThemeProvider(InventoryProvider(), []),
          update: (_, inventory, productProvider, __) =>
              ThemeProvider(inventory, productProvider.products),
        ),
        // GameSessionProvider는 GameScreen에서 생성
      ],
      child: const MinesweeperApp(),
    ),
  );
}

class MinesweeperApp extends StatefulWidget {
  const MinesweeperApp({super.key});

  @override
  State<MinesweeperApp> createState() => _MinesweeperAppState();
}

class _MinesweeperAppState extends State<MinesweeperApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SoundService.playBgm("main_sound.mp3");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SoundService.stopBgm();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      SoundService.stopBgm();
    } else if (state == AppLifecycleState.resumed) {
      SoundService.playBgm("main_sound.mp3");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}