import 'package:flutter/material.dart';

class CategoryBadge extends StatelessWidget {
  final String categoryId;
  final double fontSize;

  const CategoryBadge({
    super.key,
    required this.categoryId,
    this.fontSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    // Normalise name to lookup
    final catLower = categoryId.trim().toLowerCase();

    Color baseColor;
    IconData icon;
    String label = categoryId;

    if (catLower.contains('grocer')) {
      baseColor = const Color(0xFF10B981); // Emerald
      icon = Icons.shopping_basket_rounded;
      label = 'Groceries';
    } else if (catLower.contains('bill')) {
      baseColor = const Color(0xFF8B5CF6); // Purple
      icon = Icons.receipt_rounded;
      label = 'Bills';
    } else if (catLower.contains('entertainment') || catLower.contains('dining') || catLower.contains('food')) {
      baseColor = const Color(0xFFF59E0B); // Amber/Orange
      icon = Icons.sports_esports_rounded;
      label = 'Entertainment';
    } else if (catLower.contains('transport') || catLower.contains('car') || catLower.contains('travel')) {
      baseColor = const Color(0xFF06B6D4); // Cyan
      icon = Icons.directions_car_rounded;
      label = 'Transport';
    } else {
      baseColor = const Color(0xFF64748B); // Slate
      icon = Icons.help_center_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: baseColor.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: fontSize + 2,
            color: baseColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: baseColor,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
