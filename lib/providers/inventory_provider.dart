// lib/providers/inventory_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ✅ 인벤토리 및 스킨 착용/해제 관리 Provider
class InventoryProvider extends ChangeNotifier {
  /// 보유한 아이템 ID 리스트
  List<String> ownedItems = [];

  /// 현재 착용 중인 아이템 (type → itemId 매핑)
  /// 예: { "button": "button_skin_1", "flag": "flag_skin_1" }
  Map<String, String> equippedItems = {};

  /// ✅ 데이터 불러오기 (앱 시작 시 호출)
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    ownedItems = prefs.getStringList('ownedItems') ?? [];
    final equippedStr = prefs.getString('equippedItems');
    if (equippedStr != null && equippedStr.isNotEmpty) {
      equippedItems = Map<String, String>.from(jsonDecode(equippedStr));
    }
    _ensureDefaultItems();
    notifyListeners();
  }

  /// ✅ 아이템 보유 여부 확인
  bool isOwned(String itemId) {
    return ownedItems.contains(itemId);
  }

  /// ✅ 아이템 구매/보유 등록
  Future<void> addOwnedItem(String itemId) async {
    if (!ownedItems.contains(itemId)) {
      ownedItems.add(itemId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('ownedItems', ownedItems);
      notifyListeners();
    }
  }

  /// ✅ 아이템 착용
  /// (같은 타입의 다른 아이템은 자동으로 해제 후 새 아이템 착용)
  Future<void> equipItem(String type, String itemId) async {
    if (!ownedItems.contains(itemId)) return; // 보유하지 않은 아이템은 착용 불가
    equippedItems[type] = itemId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('equippedItems', jsonEncode(equippedItems));
    notifyListeners();
  }

  /// ✅ 아이템 해제
  Future<void> unequipItem(String type) async {
    if (equippedItems.containsKey(type)) {
      equippedItems.remove(type);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('equippedItems', jsonEncode(equippedItems));
      notifyListeners();
    }
  }

  /// ✅ 현재 아이템 착용 여부 확인
  bool isEquipped(String type, String itemId) {
    return equippedItems[type] == itemId;
  }

  /// ✅ 특정 타입의 착용 아이템 ID 가져오기
  String? getEquippedItem(String type) {
    return equippedItems[type];
  }

  /// ✅ 전체 착용 아이템 현황 가져오기
  Map<String, String> getAllEquippedItems() {
    return equippedItems;
  }

  /// ✅ 보유 아이템 전체 삭제 (테스트/디버그용)
  Future<void> clearInventory() async {
    ownedItems.clear();
    equippedItems.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ownedItems');
    await prefs.remove('equippedItems');
    notifyListeners();
  }

  /// ✅ 항상 기본 아이템을 보유 및 착용하도록 보장
  void _ensureDefaultItems() {
    final defaultItems = <String, String>{
      "button": "default_button",
      "mine": "default_mine",
      "flag": "default_flag",
      "background": "default_bg",
      "character": "character_base_male",
    };
    for (final entry in defaultItems.entries) {
      final type = entry.key;
      final itemId = entry.value;
      if (!ownedItems.contains(itemId)) {
        ownedItems.add(itemId);
      }
      if (equippedItems[type] != itemId) {
        equippedItems[type] = itemId;
      }
    }
  }
}