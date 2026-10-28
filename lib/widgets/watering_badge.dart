import 'package:flutter/material.dart';

/// Badge J-x (J+x en retard).
class WateringBadge extends StatelessWidget {
  const WateringBadge({super.key, required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (label, background, foreground) = switch (days) {
      < 0 => ('J+${-days}', colors.errorContainer, colors.onErrorContainer),
      0 => ("Aujourd'hui", colors.primaryContainer, colors.onPrimaryContainer),
      _ => ('J-$days', colors.surfaceContainerHighest, colors.onSurfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: foreground),
      ),
    );
  }
}
