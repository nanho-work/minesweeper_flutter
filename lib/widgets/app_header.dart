import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import 'energy_dialog.dart'; // ✅ 추가

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildResource(Image.asset("assets/icons/gem.png", width: 20, height: 20), currency.gems, Colors.blue),
          _buildResource(Image.asset("assets/icons/coin.png", width: 20, height: 20), currency.gold, Colors.amber),
          _buildResource(
            const Icon(Icons.bolt, color: Colors.green),
            currency.energy,
            Colors.green,
            extra: formatDuration(currency.timeUntilNextEnergy),
            showPlus: true, // ✅ + 버튼 표시
            context: context,
          ),
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
            // Optionally, style: TextStyle(color: Colors.white),
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