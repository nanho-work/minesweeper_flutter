import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 광고 초기화 (웹 제외)
  if (!kIsWeb) {
    try {
      await MobileAds.instance.initialize();
      debugPrint("AdMob 초기화 성공");
    } catch (e, stack) {
      debugPrint("AdMob 초기화 실패: $e");
    }
  }

  // 세로모드 고정 유지
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MinesweeperApp());
}

class MinesweeperApp extends StatelessWidget {
  const MinesweeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // 첫 화면 = 스플래쉬
    );
  }
}