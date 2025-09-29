import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stage_result.dart';
import '../services/sound_service.dart';
import '../models/game_stage.dart';

/// ✅ 앱 데이터 기본값 모음 (추후 변경/확장 용이)
class AppDefaults {
  static const int maxEnergy = 7;
  static const int rechargeMinutes = 4;
  static const int maxStages = 30;

  static const int defaultGold = 0;
  static const int defaultGems = 0;
  static const int defaultEnergy = maxEnergy;
}

class AppDataProvider extends ChangeNotifier {
  late final SharedPreferences _prefs;

  int _gold = AppDefaults.defaultGold;
  int get gold => _gold;

  int _gems = AppDefaults.defaultGems;
  int get gems => _gems;

  int _energy = AppDefaults.defaultEnergy;
  int get energy => _energy;

  DateTime? _lastEnergyUsed;
  DateTime? get lastEnergyUsed => _lastEnergyUsed;

  Duration _timeUntilNextEnergy = Duration.zero;
  Duration get timeUntilNextEnergy => _timeUntilNextEnergy;

  bool _bgmEnabled = true;
  bool get bgmEnabled => _bgmEnabled;

  bool _effectEnabled = true;
  bool get effectEnabled => _effectEnabled;

  String _currentBgm = "main_sound.mp3"; // ✅ 현재 재생 중인 BGM
  String get currentBgm => _currentBgm;

  String? _lastAttendanceDate;
  String? get lastAttendanceDate => _lastAttendanceDate;

  final Map<int, StageResult> _stageResults = {};
  Map<int, StageResult> get stageResults => Map.unmodifiable(_stageResults);

  Timer? _energyTimer;

  bool _disposed = false;

  // -------------------- 스테이지 관련 --------------------

  /// ✅ 전체 스테이지 결과 한번에 로드 (추후 성능 개선)
  Future<void> loadAllStageResults() async {
    for (int i = 1; i <= AppDefaults.maxStages; i++) {
      final jsonStr = _prefs.getString("stage_$i");
      if (jsonStr != null) {
        try {
          final data = jsonDecode(jsonStr);
          _stageResults[i] = StageResult.fromJson(i, data);
        } catch (_) {
          _stageResults[i] = StageResult.initial(i);
        }
      } else {
        _stageResults[i] = StageResult.initial(i);
      }
    }
  }

  /// ✅ 스테이지 결과 로드
  Future<StageResult?> loadStageResult(int stageId, {bool forceReload = false}) async {
    if (!forceReload && _stageResults.containsKey(stageId)) {
      return _stageResults[stageId];
    }
    final jsonStr = _prefs.getString("stage_$stageId");
    if (jsonStr == null) return null;
    try {
      final data = jsonDecode(jsonStr);
      final result = StageResult.fromJson(stageId, data);
      _stageResults[stageId] = result;
      return result;
    } catch (_) {
      return StageResult.initial(stageId);
    }
  }

  /// ✅ 스테이지 결과 저장 (자동 병합)
  Future<void> saveStageResult({
    required int stageId,
    required List<bool> conditions,
    required int elapsed,
    required int mistakes,
  }) async {
    final oldResult = await loadStageResult(stageId);

    // 조건 병합
    List<bool> mergedConditions = List.from(conditions);
    if (oldResult != null) {
      for (int i = 0; i < mergedConditions.length; i++) {
        if (i < oldResult.conditions.length && oldResult.conditions[i]) {
          mergedConditions[i] = true;
        }
      }
    }

    // 시도 횟수 / 최고 기록 업데이트
    int attempts = (oldResult?.attempts ?? 0) + 1;
    int bestElapsed = (oldResult == null || oldResult.bestElapsed == 0 || elapsed < oldResult.bestElapsed)
        ? elapsed
        : oldResult.bestElapsed;
    int bestMistakes = (oldResult == null || oldResult.bestMistakes == 0 || mistakes < oldResult.bestMistakes)
        ? mistakes
        : oldResult.bestMistakes;

    final newResult = StageResult(
      stageId: stageId,
      conditions: mergedConditions,
      stars: mergedConditions.where((c) => c).length,
      cleared: true,
      locked: false,
      elapsed: elapsed,
      mistakes: mistakes,
      playedAt: DateTime.now(),
      rewardsClaimed: oldResult?.rewardsClaimed ?? [false, false, false],
      attempts: attempts,
      bestElapsed: bestElapsed,
      bestMistakes: bestMistakes,
    );

    await _saveStageResult(newResult);

    // 다음 스테이지 자동 언락
    final nextId = stageId + 1;
    if (nextId <= AppDefaults.maxStages) {
      await _unlockStage(nextId);
    }
  }

  Future<void> _saveStageResult(StageResult result) async {
    await _prefs.setString("stage_${result.stageId}", jsonEncode(result.toJson()));
    _stageResults[result.stageId] = result;
    notifyListeners();
  }

  Future<void> _unlockStage(int stageId) async {
    StageResult updated = (await loadStageResult(stageId)) ?? StageResult.initial(stageId);
    updated = updated.copyWith(locked: false);
    await _saveStageResult(updated);
  }

  /// 마지막으로 클리어한 스테이지 ID
  Future<int> getLastClearedStage() async {
    int lastCleared = 0;
    if (_stageResults.isEmpty) {
      await loadAllStageResults();
    }
    for (var entry in _stageResults.entries) {
      if (entry.value.cleared && entry.key > lastCleared) {
        lastCleared = entry.key;
      }
    }
    return lastCleared;
  }

  /// 도전해야 할 스테이지 index
  Future<int> getNextStageToPlayIndex([List<Stage>? stages]) async {
    stages ??= sampleStages;
    final lastCleared = await getLastClearedStage();
    final nextStageId = lastCleared + 1;
    for (int i = 0; i < stages.length; i++) {
      if (stages[i].id == nextStageId) return i;
    }
    if (nextStageId > AppDefaults.maxStages) return stages.length - 1;
    return 0;
  }

  // -------------------- 보상 관련 --------------------

  Future<bool> claimStarReward(int stageId, int starIndex) async {
    final stageResult = await loadStageResult(stageId);
    if (stageResult == null) return false;
    if (stageResult.rewardsClaimed.length <= starIndex) return false;
    if (stageResult.rewardsClaimed[starIndex]) return false;

    await _giveReward(starIndex);

    List<bool> updatedRewards = List.from(stageResult.rewardsClaimed);
    updatedRewards[starIndex] = true;

    final updatedResult = stageResult.copyWith(rewardsClaimed: updatedRewards);
    await _saveStageResult(updatedResult);
    return true;
  }

  /// ✅ 보상 지급 로직 단일화
  Future<void> _giveReward(int starIndex) async {
    switch (starIndex) {
      case 0:
        await addGold(100);
        break;
      case 1:
        await addEnergy(1);
        break;
      case 2:
        await addGems(20);
        break;
    }
  }

  // -------------------- 에너지 / 재화 --------------------

  void _startEnergyTimer() {
    _energyTimer?.cancel();
    _energyTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed) return;
      _updateEnergyState();
    });
  }

  void _updateEnergyState() {
    bool changed = false;
    if (_energy < AppDefaults.maxEnergy && _lastEnergyUsed != null) {
      final elapsed = DateTime.now().difference(_lastEnergyUsed!);
      final gained = elapsed.inMinutes ~/ AppDefaults.rechargeMinutes;
      if (gained > 0) {
        final add = (_energy + gained > AppDefaults.maxEnergy) ? AppDefaults.maxEnergy - _energy : gained;
        if (add > 0) {
          _energy += add;
          _lastEnergyUsed = _lastEnergyUsed!.add(Duration(minutes: gained * AppDefaults.rechargeMinutes));
          _prefs.setInt('energy', _energy);
          _prefs.setString('lastEnergyUsed', _lastEnergyUsed!.toIso8601String());
          changed = true;
        }
      }
      final remainder = AppDefaults.rechargeMinutes * 60 - (elapsed.inSeconds % (AppDefaults.rechargeMinutes * 60));
      if (_timeUntilNextEnergy.inSeconds != remainder) {
        _timeUntilNextEnergy = Duration(seconds: remainder);
        changed = true;
      }
    } else {
      if (_timeUntilNextEnergy != Duration.zero) {
        _timeUntilNextEnergy = Duration.zero;
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  Future<void> addGold(int amount) async {
    _gold += amount;
    await _prefs.setInt('gold', _gold);
    notifyListeners();
  }

  Future<void> addGems(int amount) async {
    _gems += amount;
    await _prefs.setInt('gems', _gems);
    notifyListeners();
  }

  Future<void> addEnergy(int amount) async {
    _energy = (_energy + amount > AppDefaults.maxEnergy) ? AppDefaults.maxEnergy : _energy + amount;
    await _prefs.setInt('energy', _energy);
    notifyListeners();
  }

  Future<bool> spendEnergy(int amount) async {
    if (_energy >= amount) {
      _energy -= amount;
      _lastEnergyUsed = DateTime.now();
      await _prefs.setInt('energy', _energy);
      await _prefs.setString('lastEnergyUsed', _lastEnergyUsed!.toIso8601String());
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> spendGems(int amount) async {
    if (_gems >= amount) {
      _gems -= amount;
      await _prefs.setInt('gems', _gems);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> spendGold(int amount) async {
    if (_gold >= amount) {
      _gold -= amount;
      await _prefs.setInt('gold', _gold);
      notifyListeners();
      return true;
    }
    return false;
  }

  // -------------------- 사운드 --------------------

  Future<void> toggleBgm(bool enabled) async {
    _bgmEnabled = enabled;
    await _prefs.setBool('bgmEnabled', enabled);
    if (enabled) {
      SoundService.playBgm("main_sound.mp3", force: true);
    } else {
      SoundService.stopBgm();
    }
    notifyListeners();
  }

  void enterGameBgm() => setBgm("play.mp3", force: true);
  void exitGameBgm() => setBgm("main_sound.mp3", force: true);

  void setBgm(String file, {bool force = false}) {
    _currentBgm = file;
    if (_bgmEnabled) {
      SoundService.playBgm(file, force: force);
    }
    notifyListeners();
  }

  Future<void> toggleEffect(bool enabled) async {
    _effectEnabled = enabled;
    await _prefs.setBool('effectEnabled', enabled);
    notifyListeners();
  }

  // -------------------- 출석 --------------------

  Future<void> markAttendance() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = _prefs.getString('last_attendance_date');

    if (lastDate == today) return;

    List<String> raw = _prefs.getStringList('attendance_days') ?? List.filled(7, "false");
    List<bool> days = raw.map((e) => e == "true").toList();

    final index = days.indexOf(false);
    if (index != -1) {
      days[index] = true;
      await _prefs.setStringList('attendance_days', days.map((e) => e.toString()).toList());
      _lastAttendanceDate = today;
      await _prefs.setString('last_attendance_date', today);

      final dayNumber = index + 1;
      if (dayNumber == 1 || dayNumber == 3 || dayNumber == 5) {
        await addGold(100);
      } else if (dayNumber == 2 || dayNumber == 4 || dayNumber == 6) {
        await addGems(20);
      } else if (dayNumber == 7) {
        await addGold(200);
        await addGems(40);
        days = List.filled(7, false);
        await _prefs.setStringList('attendance_days', days.map((e) => e.toString()).toList());
      }
      notifyListeners();
    }
  }

  Future<List<bool>> getAttendance() async {
    List<String> raw = _prefs.getStringList('attendance_days') ?? List.filled(7, "false");
    return raw.map((e) => e == "true").toList();
  }

  // -------------------- 로드 --------------------

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    _gold = _prefs.getInt('gold') ?? AppDefaults.defaultGold;
    _gems = _prefs.getInt('gems') ?? AppDefaults.defaultGems;
    _energy = _prefs.getInt('energy') ?? AppDefaults.defaultEnergy;
    _bgmEnabled = _prefs.getBool('bgmEnabled') ?? true;
    _effectEnabled = _prefs.getBool('effectEnabled') ?? true;
    _lastAttendanceDate = _prefs.getString('last_attendance_date');
    final lastUsedString = _prefs.getString('lastEnergyUsed');
    _lastEnergyUsed = lastUsedString != null ? DateTime.tryParse(lastUsedString) : DateTime.now();
    _startEnergyTimer();
    await loadAllStageResults();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _energyTimer?.cancel();
    super.dispose();
  }
}