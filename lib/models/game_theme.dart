// lib/models/game_theme.dart
import 'package:flutter/material.dart';

class GameTheme {
  final List<Color>? buttonGradient;
  final Color? buttonClosedColor;
  final Color? buttonOpenColor;
  final Color? buttonMineColor;   // ✅ 추가
  final Color? buttonFlagColor;   // ✅ 추가
  final String? mineImage;
  final String? flagImage;
  final String? backgroundImage;

  GameTheme({
    this.buttonGradient,
    this.buttonClosedColor,
    this.buttonOpenColor,
    this.buttonMineColor,   // ✅ 추가
    this.buttonFlagColor,   // ✅ 추가
    this.mineImage,
    this.flagImage,
    this.backgroundImage,
  });
}