import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_data_provider.dart';
import '../screens/settings_screen.dart'; // ✅ SettingsScreen import
import 'dialogs/energy_dialog.dart';
import 'ad_banner.dart';
import 'dialogs/settings_dialog.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<AppDataProvider>();

    String formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      return '$minutes:$seconds';
    }

    String formatCurrency(int value) {
      if (value >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(1)}M';
      } else if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}k';
      } else {
        return value.toString();
      }
    }

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ===== 리소스 표시 =====
              Row(
                children: [
                  _buildResource(Image.asset("assets/icons/gem.png", width: 20, height: 20), currency.gems, Colors.blue),
                  const SizedBox(width: 6),
                  _buildResource(Image.asset("assets/icons/coin.png", width: 20, height: 20), currency.gold, Colors.amber),
                  const SizedBox(width: 6),
                  _buildResource(
                    const Icon(Icons.flash_on, color: Colors.orange),
                    currency.energy,
                    Colors.orange,
                    extra: formatDuration(currency.timeUntilNextEnergy),
                    showPlus: true,
                    context: context,
                  ),
                ],
              ),

              // ===== 설정 버튼 =====
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.black87),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const SettingsDialog(), // ✅ 새 다이얼로그 띄우기
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          const SizedBox(height: 50, child: AdBanner()),
        ],
      ),
    );
  }

  Widget _buildResource(
    Widget icon,
    int value,
    Color color, {
    String? extra,
    bool showPlus = false,
    BuildContext? context,
  }) {
    String formatCurrency(int value) {
      if (value >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(1)}M';
      } else if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}k';
      } else {
        return value.toString();
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 4),
          Text(
            extra != null ? "${formatCurrency(value)} ($extra)" : formatCurrency(value),
          ),
          if (showPlus && context != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const EnergyDialog(),
                );
              },
              child: const Icon(Icons.add_circle, color: Colors.green, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}