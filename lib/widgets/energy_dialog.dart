import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_data_provider.dart';
import '../services/ad_service.dart';
import 'dialogs/game_dialog.dart';

class EnergyDialog extends StatelessWidget {
  const EnergyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = context.read<AppDataProvider>();

    return GameDialog(
      title: "에너지 충전",
      content: "보석 20개로 충전하거나, 광고를 시청하세요.",
      icon: Icons.flash_on,
      confirmText: "보석 20개 사용",
      onConfirm: () async {
        if (currency.gems >= 20) {
          await currency.spendGems(20);
          await currency.addEnergy(7);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("보석 20개 사용 → 에너지 7개 충전!")),
          );
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("보석이 부족합니다.")),
          );
        }
      },
      cancelText: "광고 시청",
      onCancel: () {
        Navigator.pop(context);
        AdService.showRewardedAd(
          onReward: () async {
            await currency.addEnergy(7);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("광고 보상 → 에너지 7개 충전!")),
            );
          },
        );
      },
    );
  }
}