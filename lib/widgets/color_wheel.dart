import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Luminosité HSV fixe des couleurs de la roue (un peu adoucie).
const wheelBrightness = 0.85;

/// Roue chromatique : teinte selon l'angle, saturation selon la distance au centre.
class ColorWheel extends StatelessWidget {
  const ColorWheel({
    super.key,
    required this.color,
    required this.onChanged,
    this.size = 220,
  });

  final HSVColor color;
  final ValueChanged<HSVColor> onChanged;
  final double size;

  void _pick(Offset position) {
    final radius = size / 2;
    final offset = position - Offset(radius, radius);
    final hue = (math.atan2(offset.dy, offset.dx) * 180 / math.pi + 360) % 360;
    final saturation = (offset.distance / radius).clamp(0.0, 1.0);
    onChanged(HSVColor.fromAHSV(1, hue, saturation, wheelBrightness));
  }

  @override
  Widget build(BuildContext context) {
    final radius = size / 2;
    final angle = color.hue * math.pi / 180;
    final distance = color.saturation * radius;

    // Drags vertical + horizontal (pas pan) pour gagner contre le défilement de la page.
    return GestureDetector(
      onTapDown: (details) => _pick(details.localPosition),
      onVerticalDragUpdate: (details) => _pick(details.localPosition),
      onHorizontalDragUpdate: (details) => _pick(details.localPosition),
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: Size.square(size),
              painter: const _WheelPainter(),
            ),
            Positioned(
              left: radius + math.cos(angle) * distance - 12,
              top: radius + math.sin(angle) * distance - 12,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color.toColor(),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  const _WheelPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const SweepGradient(
          colors: [
            Color(0xFFFF0000),
            Color(0xFFFFFF00),
            Color(0xFF00FF00),
            Color(0xFF00FFFF),
            Color(0xFF0000FF),
            Color(0xFFFF00FF),
            Color(0xFFFF0000),
          ],
        ).createShader(rect),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          colors: [Colors.white, Color(0x00FFFFFF)],
        ).createShader(rect),
    );
    // Mélanger avec du noir revient à baisser la luminosité HSV.
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = Colors.black.withValues(alpha: 1 - wheelBrightness),
    );
  }

  @override
  bool shouldRepaint(_WheelPainter oldDelegate) => false;
}
