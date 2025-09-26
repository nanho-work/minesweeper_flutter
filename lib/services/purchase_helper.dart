import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/app_data_provider.dart';
import '../providers/inventory_provider.dart';
import 'ad_service.dart';
import 'ad_limit_service.dart'; // ✅ 광고 제한 서비스 추가

class PurchaseHelper {
  /// 광고 리워드 처리
  static void handleRewardedAd(BuildContext context, Product product) async {
    // ✅ 하루 제한 체크
    if (!await AdLimitService.canWatchAd()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("오늘은 더 이상 광고를 볼 수 없습니다. 내일 다시 시도하세요!")),
      );
      return;
    }

    AdService.showRewardedAd(
      onReward: () async {
        await AdLimitService.incrementCount(); // ✅ 성공 시 카운트 증가
        final rewardAmount =
            int.tryParse(product.name.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

        if (product.type == ProductType.gold) {
          context.read<AppDataProvider>().addGold(rewardAmount);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("광고 보상으로 골드 $rewardAmount 획득!")),
          );
        } else if (product.type == ProductType.gem) {
          context.read<AppDataProvider>().addGems(rewardAmount);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("광고 보상으로 보석 $rewardAmount 획득!")),
          );
        }
      },
      onFail: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("광고가 아직 준비되지 않았습니다.")),
        );
      },
    );
  }

  /// 일반 상품 구매 처리
  static Future<void> purchaseProduct(
      BuildContext context, Product product) async {
    final currencyProvider = context.read<AppDataProvider>();
    final price = int.tryParse(product.price) ?? 0;
    final currency = product.currency ?? "gold";

    bool success = false;

    // ✅ 구매 비용 차감
    if (currency == "gem") {
      success = await currencyProvider.spendGems(price);
    } else {
      success = await currencyProvider.spendGold(price);
    }

    if (success) {
      final amount =
          int.tryParse(product.name.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

      if (product.type == ProductType.gold) {
        currencyProvider.addGold(amount);
      } else if (product.type == ProductType.gem) {
        currencyProvider.addGems(amount);
      } else {
        // ✅ 스킨/배경/버튼/기타 아이템은 구매 완료 상태로 기록
        if (product.id != null) {
          context.read<InventoryProvider>().addOwnedItem(product.id!);
        }
      }
    }

    final errorMsg = (currency == "gem") ? "보석이 부족합니다." : "골드가 부족합니다.";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "구매 완료!" : errorMsg)),
    );
  }
}