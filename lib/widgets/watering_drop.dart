import 'package:flutter/material.dart';

const rainBlue = Color(0xFF3A8FD9);

/// Goutte remplie selon [level] : 1 = pleine, 0 = vide.
class WateringDrop extends StatelessWidget {
  const WateringDrop({super.key, required this.level, this.size = 24});

  final double level;
  final double size;

  @override
  Widget build(BuildContext context) {
    const color = rainBlue;
    // Le dessin de la goutte occupe la hauteur 2 → 22 de l'icône (sur 24).
    final heightFactor = (2 + 20 * level.clamp(0.0, 1.0)) / 24;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Icon(Icons.water_drop_outlined, color: color, size: size),
        ClipRect(
          child: Align(
            alignment: Alignment.bottomCenter,
            heightFactor: heightFactor,
            child: Icon(Icons.water_drop, color: color, size: size),
          ),
        ),
      ],
    );
  }
}
