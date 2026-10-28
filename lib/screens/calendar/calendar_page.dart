import 'package:flutter/material.dart';

import '../../models/plant.dart';
import '../plants/plant_detail_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key, required this.plants, required this.onSave});

  final List<Plant> plants;
  final ValueChanged<Plant> onSave;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _month;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _goToToday();
  }

  void _goToToday() {
    final today = DateUtils.dateOnly(DateTime.now());
    _month = DateTime(today.year, today.month);
    _selectedDay = today;
  }

  void _changeMonth(int delta) =>
      setState(() => _month = DateUtils.addMonthsToMonthDate(_month, delta));

  List<Plant> _plantsOn(DateTime day) =>
      widget.plants.where((p) => p.needsWateringOn(day)).toList();

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final selectedPlants = _plantsOn(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier'),
        actions: [
          IconButton(
            tooltip: "Aujourd'hui",
            icon: const Icon(Icons.today),
            onPressed: () => setState(_goToToday),
          ),
        ],
      ),
      body: ListView(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Mois précédent',
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeMonth(-1),
              ),
              Expanded(
                child: Text(
                  localizations.formatMonthYear(_month),
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Mois suivant',
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity.abs() < 200) return;
              _changeMonth(velocity < 0 ? 1 : -1);
            },
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildMonthGrid(localizations),
                ),
              ),
            ),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              localizations.formatFullDate(_selectedDay),
              style: textTheme.titleSmall,
            ),
          ),
          if (selectedPlants.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Aucun arrosage prévu'),
            )
          else
            for (final plant in selectedPlants)
              ListTile(
                leading: CircleAvatar(radius: 8, backgroundColor: plant.color),
                title: Text(plant.name),
                subtitle: plant.species.isEmpty ? null : Text(plant.species),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        PlantDetailPage(plant: plant, onSave: widget.onSave),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildMonthGrid(MaterialLocalizations localizations) {
    final today = DateUtils.dateOnly(DateTime.now());
    final firstWeekday = localizations.firstDayOfWeekIndex;
    final offset = DateUtils.firstDayOffset(
      _month.year,
      _month.month,
      localizations,
    );
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var i = 0; i < 7; i++)
          Center(
            child: Text(
              localizations.narrowWeekdays[(firstWeekday + i) % 7],
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        for (var i = 0; i < offset; i++) const SizedBox.shrink(),
        for (var d = 1; d <= daysInMonth; d++)
          _buildDayCell(DateTime(_month.year, _month.month, d), today),
      ],
    );
  }

  Widget _buildDayCell(DateTime day, DateTime today) {
    final colors = Theme.of(context).colorScheme;
    final isSelected = DateUtils.isSameDay(day, _selectedDay);
    final isToday = DateUtils.isSameDay(day, today);
    final plants = _plantsOn(day);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => setState(() => _selectedDay = day),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryContainer : null,
          border: isToday ? Border.all(color: colors.primary) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${day.day}'),
            const SizedBox(height: 4),
            // Limité à 4 pastilles pour tenir dans la case.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final plant in plants.take(4))
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: plant.color,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
