import 'package:flutter/material.dart';
import '../game_button.dart';

class GameDialog extends StatelessWidget {
  final String title;
  final dynamic content; // ✅ String 또는 Widget 지원
  final String confirmText;
  final VoidCallback onConfirm;
  final String? cancelText;
  final VoidCallback? onCancel;
  final IconData? icon;
  final Color? backgroundColor;

  const GameDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmText,
    required this.onConfirm,
    this.cancelText,
    this.onCancel,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget contentWidget;
    if (content is String) {
      contentWidget = Text(content as String, textAlign: TextAlign.center);
    } else if (content is Widget) {
      contentWidget = content as Widget;
    } else {
      contentWidget = const SizedBox.shrink();
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: backgroundColor ?? Colors.yellow[100],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, size: 48, color: Colors.orange),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            contentWidget,
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (cancelText != null) ...[
                  GameButton(
                    text: cancelText!,
                    onPressed: onCancel ?? () => Navigator.pop(context),
                    width: 80,
                    height: 36,
                    color: Colors.grey.shade400,
                    textColor: Colors.black,
                  ),
                  const SizedBox(width: 12),
                ],
                GameButton(
                  text: confirmText,
                  onPressed: onConfirm,
                  width: 80,
                  height: 36,
                  color: Colors.orange,
                  textColor: Colors.white,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}