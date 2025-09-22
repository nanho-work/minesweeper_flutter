import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../services/ad_service.dart';

class EnergyDialog extends StatelessWidget {
  const EnergyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = context.read<CurrencyProvider>();

    return AlertDialog(
      title: const Text("에너지 충전"),
      content: const Text("아래 방법 중 하나를 선택해 에너지를 충전하세요."),
      actions: [
        // ✅ 구매 버튼
        TextButton(
          onPressed: () async {
            if (currency.gems >= 10) {
              await currency.spendGems(10);
              await currency.addEnergy(15);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("보석 10개 사용 → 에너지 5개 충전!")),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("보석이 부족합니다.")),
              );
            }
          },
          child: const Text("보석 10개로 충전"),
        ),

        // ✅ 광고 버튼
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            AdService.showRewardedAd(
              onReward: () async {
                await currency.addEnergy(15);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("광고 보상 → 에너지 5개 충전!")),
                );
              },
            );
          },
          child: const Text("광고 시청으로 충전"),
        ),

        // 닫기 버튼
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("닫기"),
        ),
      ],
    );
  }
}