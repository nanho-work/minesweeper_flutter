// lib/main.dart
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
import 'core/navigation_service.dart';
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

  // ✅ AppDataProvider 초기화
  final appDataProvider = AppDataProvider();
  await appDataProvider.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appDataProvider), // ✅ 기존 로드된 인스턴스 사용
        ChangeNotifierProvider(create: (_) => ProductProvider()..loadProducts()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()..load()),
        ChangeNotifierProxyProvider2<InventoryProvider, ProductProvider, ThemeProvider>(
          create: (_) => ThemeProvider(InventoryProvider(), []),
          update: (_, inventory, productProvider, __) =>
              ThemeProvider(inventory, productProvider.products),
        ),
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

    // ✅ 앱 시작 시 BGM 재생 여부는 AppDataProvider API 사용
    final appData = context.read<AppDataProvider>();
    if (appData.bgmEnabled) {
      appData.exitGameBgm(); // 기본 메인 BGM 실행
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    context.read<AppDataProvider>().exitGameBgm(); // 종료 시 BGM 정리
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final appData = context.read<AppDataProvider>();

    if (state == AppLifecycleState.paused) {
      SoundService.stopBgm(); // 백그라운드 → BGM 중지
    } else if (state == AppLifecycleState.resumed) {
      if (appData.bgmEnabled) {
        SoundService.playBgm(appData.currentBgm, force: true); // 복귀 시 현재 BGM 재개
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}