import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDataProvider extends ChangeNotifier {
  static const int maxEnergy = 7;
  static const int rechargeMinutes = 10;

  int gold = 0;
  int gems = 0;
  int energy = 0;

  DateTime? lastEnergyUsed;
  Duration timeUntilNextEnergy = Duration.zero;

  void _startEnergyTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (energy < maxEnergy && lastEnergyUsed != null) {
        final elapsed = DateTime.now().difference(lastEnergyUsed!);
        final gained = elapsed.inMinutes ~/ rechargeMinutes;
        if (gained > 0) {
          final add = (energy + gained > maxEnergy) ? maxEnergy - energy : gained;
          if (add > 0) {
            energy += add;
            lastEnergyUsed = DateTime.now();
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('energy', energy);
            await prefs.setString('lastEnergyUsed', lastEnergyUsed!.toIso8601String());
            notifyListeners();
          }
        }
        final remainder = rechargeMinutes - (elapsed.inMinutes % rechargeMinutes);
        timeUntilNextEnergy = Duration(
          minutes: remainder,
          seconds: 59 - elapsed.inSeconds % 60,
        );
      } else {
        timeUntilNextEnergy = Duration.zero;
      }
      notifyListeners();
      return true;
    });
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    gold = prefs.getInt('gold') ?? 0;
    gems = prefs.getInt('gems') ?? 0;
    energy = prefs.getInt('energy') ?? maxEnergy;
    final lastUsedString = prefs.getString('lastEnergyUsed');
    if (lastUsedString != null) {
      lastEnergyUsed = DateTime.tryParse(lastUsedString);
    } else {
      lastEnergyUsed = DateTime.now();
    }
    _startEnergyTimer();
    notifyListeners();
  }

  Future<void> addGold(int amount) async {
    gold += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gold', gold);
    notifyListeners();
  }

  Future<void> addGems(int amount) async {
    gems += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gems', gems);
    notifyListeners();
  }

  Future<void> addEnergy(int amount) async {
    energy = (energy + amount > maxEnergy) ? maxEnergy : energy + amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('energy', energy);
    notifyListeners();
  }

  Future<bool> spendEnergy(int amount) async {
    if (energy >= amount) {
      energy -= amount;
      lastEnergyUsed = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('energy', energy);
      await prefs.setString('lastEnergyUsed', lastEnergyUsed!.toIso8601String());
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> spendGems(int amount) async {
    if (gems >= amount) {
      gems -= amount;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('gems', gems);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> spendGold(int amount) async {
    if (gold >= amount) {
      gold -= amount;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('gold', gold);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// ✅ 스테이지 클리어 기록 불러오기
  Future<Map<String, dynamic>?> loadStageResult(int stageId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString("stage_$stageId");
    if (jsonStr == null) return null;
    final data = jsonDecode(jsonStr);
    if (data is Map<String, dynamic> && data['cleared'] == true) {
      data['locked'] = false;
    }
    return data;
  }

  Future<void> _unlockStage(int stageId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString("stage_$stageId");
    Map<String, dynamic> data;
    if (jsonStr != null) {
      data = jsonDecode(jsonStr);
      data["locked"] = false;
    } else {
      data = {
        "conditions": [false, false, false],
        "stars": 0,
        "cleared": false,
        "locked": false,
      };
    }
    await prefs.setString("stage_$stageId", jsonEncode(data));
  }

  /// ✅ 스테이지 클리어 기록 저장 (조건 병합)
  Future<void> saveStageResult(
    int stageId, {
    required List<bool> conditions,
    required int elapsed,
    required int mistakes,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // 기존 기록 병합
    final oldData = await loadStageResult(stageId);
    List<bool> mergedConditions = List.from(conditions);

    int totalElapsed = elapsed;
    int totalMistakes = mistakes;

    if (oldData != null && oldData['conditions'] != null) {
      final prev = (oldData['conditions'] as List).map((e) => e == true).toList();
      for (int i = 0; i < mergedConditions.length; i++) {
        mergedConditions[i] = mergedConditions[i] || prev[i];
      }

      // ✅ 누적 합산
      totalElapsed += (oldData['elapsed'] ?? 0) as int;
      totalMistakes += (oldData['mistakes'] ?? 0) as int;
    }

    // 새 데이터
    final data = {
      "conditions": mergedConditions,
      "stars": mergedConditions.where((c) => c).length,
      "cleared": true, // ✅ 클리어 여부 기록
      "locked": false, // ✅ 클리어한 스테이지는 항상 오픈 상태 유지
      "elapsed": totalElapsed,   // ✅ 추가
      "mistakes": totalMistakes, // ✅ 추가
      "playedAt": DateTime.now().toIso8601String(),
    };

    await prefs.setString("stage_$stageId", jsonEncode(data));

    // ✅ 다음 스테이지 자동 언락
    final nextId = stageId + 1;
    if (nextId <= 30) {
      await _unlockStage(nextId);
    }
  }
}