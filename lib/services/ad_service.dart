import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'sound_service.dart';

class AdService {
  static RewardedAd? _rewardedAd;

  /// ✅ 보상형 광고 로드
  static Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: 'ca-app-pub-5773331970563455/7114095570', // ✅ 테스트용
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              SoundService.stopBgm(); // 광고 시작 시 BGM 멈춤
            },
            onAdDismissedFullScreenContent: (ad) {
              SoundService.playBgm("main_sound.mp3"); // 광고 끝나면 BGM 재생
            },
          );
          _rewardedAd = ad;
          debugPrint("Rewarded Ad Loaded");
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          debugPrint("Rewarded Ad Failed: $error");
        },
      ),
    );
  }

  /// ✅ 보상형 광고 실행
    static void showRewardedAd({
        required Function onReward,
        Function? onFail,
    }) {
        if (_rewardedAd == null) {
            debugPrint("No RewardedAd loaded");
            if (onFail != null) onFail(); // 🔥 실패 시 콜백
            return;
        }

        _rewardedAd!.show(
            onUserEarnedReward: (ad, reward) {
            onReward(); // 보상 실행
            },
        );

        _rewardedAd = null; // 한 번 쓰고 폐기
        loadRewardedAd();   // 다음 광고 미리 로드
    }
}