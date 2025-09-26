// lib/models/game_theme.dart
import 'package:flutter/material.dart';

class GameTheme {
  final List<Color>? buttonGradient;
  final Color? buttonClosedColor;
  final Color? buttonOpenColor;
  final String? mineImage;
  final String? flagImage;
  final String? backgroundImage;

  const GameTheme({
    this.buttonGradient,
    this.buttonClosedColor,
    this.buttonOpenColor,
    this.mineImage,
    this.flagImage,
    this.backgroundImage,
  });
}