import 'package:shared_preferences/shared_preferences.dart';

class AdLimitService {
  static const String _key = "rewarded_ad_count";
  static const String _dateKey = "rewarded_ad_date";
  static const int maxAdsPerDay = 5; // ✅ 하루 최대 광고 횟수

  /// 오늘의 광고 시청 횟수 가져오기
  static Future<int> _getTodayCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10); // yyyy-MM-dd
    final savedDate = prefs.getString(_dateKey);

    if (savedDate != today) {
      // 날짜가 바뀌면 카운트 초기화
      await prefs.setString(_dateKey, today);
      await prefs.setInt(_key, 0);
      return 0;
    }
    return prefs.getInt(_key) ?? 0;
  }

  /// 오늘 광고를 더 볼 수 있는지 여부
  static Future<bool> canWatchAd() async {
    final count = await _getTodayCount();
    return count < maxAdsPerDay;
  }

  /// 광고 시청 후 카운트 증가
  static Future<void> incrementCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = await _getTodayCount();
    await prefs.setInt(_key, count + 1);
  }

  static Future<int> getTodayCount() async {
    return await _getTodayCount();
    }
}