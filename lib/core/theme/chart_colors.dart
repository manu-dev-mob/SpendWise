import 'package:flutter/material.dart';

class ChartColors {
  static const List<Color> palette = [
    Color(0xFF4F46E5), // Indigo
    Color(0xFF16A34A), // Green
    Color(0xFFDC2626), // Red
    Color(0xFFEA580C), // Orange
    Color(0xFF0891B2), // Cyan
    Color(0xFF9333EA), // Purple
    Color(0xFFCA8A04), // Amber
    Color(0xFF0F766E), // Teal
  ];

  static Color byIndex(int index) {
    return palette[index % palette.length];
  }
}