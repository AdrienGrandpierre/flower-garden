import 'package:flutter/material.dart';

import '../models/plant.dart';
import 'watering_badge.dart';
import 'watering_drop.dart';

class PlantTile extends StatelessWidget {
  const PlantTile({
    super.key,
    required this.plant,
    required this.today,
    required this.onTap,
    required this.onWater,
  });

  final Plant plant;
  final DateTime today;
  final VoidCallback onTap;
  final VoidCallback onWater;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final lastWatered = localizations.formatShortDate(plant.lastWatered);

    return ListTile(
      onTap: onTap,
      titleAlignment: ListTileTitleAlignment.center,
      leading: CircleAvatar(
        backgroundColor: plant.color,
        child: const Icon(Icons.local_florist, color: Colors.white),
      ),
      title: Text(plant.name),
      subtitle: Text(
        [
          if (plant.species.isNotEmpty) plant.species,
          'Tous les ${plant.wateringIntervalDays} j · arrosée le $lastWatered',
        ].join('\n'),
      ),
      isThreeLine: plant.species.isNotEmpty,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          WateringBadge(days: plant.daysUntilWatering(today)),
          IconButton(
            tooltip: "Arrosée aujourd'hui",
            icon: WateringDrop(level: plant.waterLevel(today)),
            onPressed: onWater,
          ),
        ],
      ),
    );
  }
}
