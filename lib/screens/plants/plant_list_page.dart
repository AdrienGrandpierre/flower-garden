import 'package:flutter/material.dart';

import '../../models/plant.dart';
import '../../widgets/plant_tile.dart';
import 'plant_detail_page.dart';
import 'plant_form_page.dart';

class PlantListPage extends StatelessWidget {
  const PlantListPage({
    super.key,
    required this.plants,
    required this.onSave,
    required this.onDelete,
    required this.onWater,
  });

  final List<Plant> plants;
  final ValueChanged<Plant> onSave;
  final ValueChanged<Plant> onDelete;
  final ValueChanged<Plant> onWater;

  Future<void> _openForm(BuildContext context) async {
    final result = await Navigator.of(context).push<Plant>(
      MaterialPageRoute(
        builder: (_) => PlantFormPage(
          defaultColor: plantColors[plants.length % plantColors.length],
        ),
      ),
    );
    if (result != null) onSave(result);
  }

  void _openDetail(BuildContext context, Plant plant) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlantDetailPage(plant: plant, onSave: onSave),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, Plant plant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la plante ?'),
        content: Text('« ${plant.name} » sera supprimée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final sorted = [...plants]
      ..sort((a, b) => a.nextWatering.compareTo(b.nextWatering));

    return Scaffold(
      appBar: AppBar(title: const Text('Mes plantes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
      body: sorted.isEmpty
          ? const Center(
              child: Text(
                "Aucune plante pour l'instant.\nAjoute ta première plante !",
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: sorted.length,
              itemBuilder: (context, i) {
                final plant = sorted[i];
                return Dismissible(
                  key: ValueKey(plant.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Theme.of(context).colorScheme.errorContainer,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: const Icon(Icons.delete),
                  ),
                  confirmDismiss: (_) => _confirmDelete(context, plant),
                  onDismissed: (_) => onDelete(plant),
                  child: PlantTile(
                    plant: plant,
                    today: today,
                    onTap: () => _openDetail(context, plant),
                    onWater: () => onWater(plant),
                  ),
                );
              },
            ),
    );
  }
}
