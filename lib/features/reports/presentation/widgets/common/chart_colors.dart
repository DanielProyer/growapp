import 'package:flutter/material.dart';

/// Farbpalette für Charts
class ChartColors {
  ChartColors._();

  // Serien-Farben für mehrere Datensätze
  static const List<Color> series = [
    Color(0xFF4CAF50), // Green
    Color(0xFF2196F3), // Blue
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFFF44336), // Red
    Color(0xFF00BCD4), // Cyan
    Color(0xFF795548), // Brown
    Color(0xFFFFEB3B), // Yellow
  ];

  // Temperatur
  static const Color tempTag = Color(0xFFFF9800); // warm orange
  static const Color tempNacht = Color(0xFF2196F3); // cool blue

  // Luftfeuchtigkeit
  static const Color rlfTag = Color(0xFF4CAF50); // green
  static const Color rlfNacht = Color(0xFF009688); // teal

  // pH / EC
  static const Color ph = Color(0xFFFF9800); // orange
  static const Color ec = Color(0xFF2196F3); // blue

  // Keeper-Status
  static const Color keeper = Color(0xFF4CAF50); // green
  static const Color nichtKeeper = Color(0xFFF44336); // red
  static const Color vielleicht = Color(0xFFFF9800); // orange

  // Grow-Phasen
  static const Color vegiPhase = Color(0xFF4CAF50); // green
  static const Color bluetePhase = Color(0xFFFF9800); // orange
  static const Color curingPhase = Color(0xFF795548); // brown

  // Pflanzenhöhe
  static const Color pflanzenHoehe = Color(0xFF66BB6A); // light green

  /// Farbe für Index aus Serien-Palette
  static Color seriesColor(int index) => series[index % series.length];
}
