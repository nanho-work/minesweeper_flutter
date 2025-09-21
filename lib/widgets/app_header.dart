import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final int gems;
  final int gold;
  final int energy;
  final bool showBackButton;

  const AppHeader({
    super.key,
    required this.gems,
    required this.gold,
    required this.energy,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey[50],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // horizontal: 좌우 여백, vertical: 상하 여백(높이). 높이를 줄이고 싶으면 vertical 값을 줄이면 됨
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (showBackButton)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          _buildResource(Icons.diamond, "보석", gems, Colors.blue),
          _buildResource(Icons.attach_money, "골드", gold, Colors.amber),
          _buildResource(Icons.bolt, "에너지", energy, Colors.green),
        ],
      ),
    );
  }

  Widget _buildResource(IconData icon, String label, int value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 4),
        Text("$label: $value"),
      ],
    );
  }
}