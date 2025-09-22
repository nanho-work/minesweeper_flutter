// lib/providers/currency_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider extends ChangeNotifier {
  static const int maxEnergy = 15;
  static const int rechargeMinutes = 20;

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
        timeUntilNextEnergy = Duration(minutes: remainder, seconds: 59 - elapsed.inSeconds % 60);
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
    energy = prefs.getInt('energy') ?? maxEnergy; // ✅ 처음엔 15개 기본값
    final lastUsedString = prefs.getString('lastEnergyUsed');
    if (lastUsedString != null) {
      lastEnergyUsed = DateTime.tryParse(lastUsedString);
    } else {
      lastEnergyUsed = DateTime.now(); // ✅ 없으면 현재 시간으로 초기화
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

  // ✅ 신규: 골드 차감
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
}