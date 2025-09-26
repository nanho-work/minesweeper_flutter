// lib/widgets/game_cell.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_engine.dart';
import '../providers/theme_provider.dart';

class GameCell extends StatelessWidget {
  final int row;
  final int col;
  final Cell cell;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const GameCell({
    super.key,
    required this.row,
    required this.col,
    required this.cell,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 1),
          gradient: !cell.isRevealed && theme.buttonGradient != null
              ? LinearGradient(
                  colors: theme.buttonGradient!,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: cell.isRevealed
              ? (cell.isMine
                  ? (theme.buttonMineColor ?? Colors.red)
                  : theme.buttonOpenColor ?? Colors.grey[300])
              : theme.buttonClosedColor ?? Colors.grey[200],
        ),
        child: Center(
          child: cell.isRevealed
              ? (cell.isMine
                  ? (theme.mineImage != null
                      ? Image.asset(theme.mineImage!,
                          width: 28, height: 28)
                      : const Icon(Icons.circle,
                          color: Colors.black, size: 28))
                  : (cell.neighborMines > 0
                      ? Text(
                          '${cell.neighborMines}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        )
                      : const SizedBox.shrink()))
              : (cell.isFlagged
                  ? (theme.flagImage != null
                      ? Image.asset(theme.flagImage!,
                          width: 28, height: 28)
                      : Icon(Icons.flag,
                          color: theme.buttonFlagColor ?? Colors.red, size: 28))
                  : const SizedBox.shrink()),
        ),
      ),
    );
  }
}