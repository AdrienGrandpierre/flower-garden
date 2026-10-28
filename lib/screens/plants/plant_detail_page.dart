import 'package:flutter/material.dart';

import '../../models/plant.dart';
import '../../widgets/watering_badge.dart';
import '../../widgets/watering_drop.dart';
import 'plant_form_page.dart';

/// Page perso d'une plante : infos, historique d'arrosage, accès à l'édition.
class PlantDetailPage extends StatefulWidget {
  const PlantDetailPage({super.key, required this.plant, required this.onSave});

  final Plant plant;
  final ValueChanged<Plant> onSave;

  @override
  State<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  late Plant _plant = widget.plant;

  void _save(Plant plant) {
    setState(() => _plant = plant);
    widget.onSave(plant);
  }

  Future<void> _edit() async {
    final result = await Navigator.of(context).push<Plant>(
      MaterialPageRoute(
        builder: (_) =>
            PlantFormPage(plant: _plant, defaultColor: _plant.color),
      ),
    );
    if (result != null) _save(result);
  }

  void _deleteWatering(DateTime day) => _save(
    _plant.copyWith(
      wateringHistory: _plant.wateringHistory.where((d) => d != day),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final today = DateUtils.dateOnly(DateTime.now());
    final history = _plant.wateringHistory;
    final interval = _plant.wateringIntervalDays;

    return Scaffold(
      appBar: AppBar(
        title: Text(_plant.name),
        actions: [
          IconButton(
            tooltip: 'Modifier',
            icon: const Icon(Icons.edit),
            onPressed: _edit,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: _plant.color,
              child: const Icon(
                Icons.local_florist,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _plant.name,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall,
          ),
          if (_plant.species.isNotEmpty)
            Text(
              _plant.species,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: const Text("Fréquence d'arrosage"),
            subtitle: Text(
              interval == 1 ? 'Tous les jours' : 'Tous les $interval jours',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Prochain arrosage'),
            subtitle: Text(localizations.formatFullDate(_plant.nextWatering)),
            trailing: WateringBadge(days: _plant.daysUntilWatering(today)),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Historique des arrosages',
              style: textTheme.titleSmall,
            ),
          ),
          for (final day in history)
            ListTile(
              leading: const Icon(Icons.water_drop_outlined, color: rainBlue),
              title: Text(localizations.formatFullDate(day)),
              // Le dernier arrosage restant est obligatoire.
              trailing: IconButton(
                tooltip: 'Supprimer',
                icon: const Icon(Icons.delete_outline),
                onPressed: history.length > 1
                    ? () => _deleteWatering(day)
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
