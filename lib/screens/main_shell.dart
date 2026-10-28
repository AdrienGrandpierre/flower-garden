import 'package:flutter/material.dart';

import '../data/plant_repository.dart';
import '../models/plant.dart';
import 'calendar/calendar_page.dart';
import 'plants/plant_list_page.dart';

/// Racine : détient la liste des plantes et la partage entre les onglets.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _repository = const PlantRepository();
  List<Plant>? _plants;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final plants = await _repository.load();
    if (!mounted) return;
    setState(() => _plants = plants);
  }

  void _update(List<Plant> plants) {
    setState(() => _plants = plants);
    _repository.save(plants);
  }

  void _savePlant(Plant plant) {
    final plants = [..._plants!];
    final i = plants.indexWhere((p) => p.id == plant.id);
    if (i == -1) {
      plants.add(plant);
    } else {
      plants[i] = plant;
    }
    _update(plants);
  }

  void _deletePlant(Plant plant) =>
      _update(_plants!.where((p) => p.id != plant.id).toList());

  void _waterPlant(Plant plant) => _savePlant(plant.wateredOn(DateTime.now()));

  @override
  Widget build(BuildContext context) {
    final plants = _plants;
    return Scaffold(
      body: plants == null
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _index,
              children: [
                PlantListPage(
                  plants: plants,
                  onSave: _savePlant,
                  onDelete: _deletePlant,
                  onWater: _waterPlant,
                ),
                CalendarPage(plants: plants, onSave: _savePlant),
              ],
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.local_florist_outlined),
            selectedIcon: Icon(Icons.local_florist),
            label: 'Plantes',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendrier',
          ),
        ],
      ),
    );
  }
}
