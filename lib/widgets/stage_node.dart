import 'package:flutter/material.dart';
import '../models/stage.dart';

class StageNode extends StatelessWidget {
  final Stage stage;
  final VoidCallback onTap;

  const StageNode({super.key, required this.stage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: stage.locked ? null : onTap,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                stage.image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              if (stage.locked)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.lock, color: Colors.white, size: 40),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            stage.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}