import 'package:flutter/material.dart';

class HoverCard extends StatefulWidget {
  final Widget child;
  final double hoverOffset;
  final double borderRadius;
  final Color? borderColor;
  final Color? hoverBorderColor;

  const HoverCard({
    super.key,
    required this.child,
    this.hoverOffset = -6.0,
    this.borderRadius = 16.0,
    this.borderColor,
    this.hoverBorderColor,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Smooth transitions
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? widget.hoverOffset : 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? (isDark
                      ? Colors.black.withOpacity(0.4)
                      : const Color(0xFF6366F1).withOpacity(0.08))
                  : (isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.03)),
              blurRadius: _isHovered ? 20 : 10,
              spreadRadius: _isHovered ? 2 : 0,
              offset: Offset(0, _isHovered ? 10 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: widget.child,
        ),
      ),
    );
  }
}
