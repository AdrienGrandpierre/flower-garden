import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/plant.dart';
import '../../widgets/color_wheel.dart';

/// Ajout ou modification d'une plante ; renvoie la plante via `Navigator.pop`.
class PlantFormPage extends StatefulWidget {
  const PlantFormPage({super.key, this.plant, required this.defaultColor});

  final Plant? plant;
  final Color defaultColor;

  @override
  State<PlantFormPage> createState() => _PlantFormPageState();
}

class _PlantFormPageState extends State<PlantFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.plant?.name);
  late final _species = TextEditingController(text: widget.plant?.species);
  late final _interval = TextEditingController(
    text: widget.plant?.wateringIntervalDays.toString(),
  );
  late DateTime _lastWatered =
      widget.plant?.lastWatered ?? DateUtils.dateOnly(DateTime.now());
  late Color _color = widget.plant?.color ?? widget.defaultColor;
  final _random = math.Random();

  @override
  void dispose() {
    _name.dispose();
    _species.dispose();
    _interval.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastWatered,
      firstDate: DateTime(2000),
      lastDate: DateUtils.dateOnly(DateTime.now()),
    );
    if (picked != null) setState(() => _lastWatered = picked);
  }

  Future<void> _pickColor() async {
    var picked = HSVColor.fromColor(_color);
    final result = await showDialog<Color>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Couleur'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 220,
                height: 48,
                decoration: BoxDecoration(
                  color: picked.toColor(),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ColorWheel(
                color: picked,
                onChanged: (color) => setDialogState(() => picked = color),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, picked.toColor()),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
    if (result != null) setState(() => _color = result);
  }

  // Saturation ≥ 0,5 pour éviter les couleurs trop pâles.
  void _randomColor() => setState(
    () => _color = HSVColor.fromAHSV(
      1,
      _random.nextDouble() * 360,
      0.5 + _random.nextDouble() * 0.5,
      wheelBrightness,
    ).toColor(),
  );

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final plant = widget.plant;
    final name = _name.text.trim();
    final species = _species.text.trim();
    final interval = int.parse(_interval.text);
    Navigator.pop(
      context,
      plant == null
          ? Plant(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              name: name,
              species: species,
              wateringIntervalDays: interval,
              wateringHistory: [_lastWatered],
              color: _color,
            )
          // La date saisie remplace le dernier arrosage de l'historique.
          : plant.copyWith(
              name: name,
              species: species,
              wateringIntervalDays: interval,
              wateringHistory: [_lastWatered, ...plant.wateringHistory.skip(1)],
              color: _color,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.plant == null ? 'Nouvelle plante' : 'Modifier la plante',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Indique un nom'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _species,
              decoration: const InputDecoration(
                labelText: 'Espèce (optionnel)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _interval,
              decoration: const InputDecoration(
                labelText: "Fréquence d'arrosage",
                suffixText: 'jours',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                final days = int.tryParse(value ?? '');
                return days == null || days < 1 ? 'Au moins 1 jour' : null;
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.water_drop_outlined),
              title: const Text('Dernier arrosage'),
              subtitle: Text(localizations.formatFullDate(_lastWatered)),
              trailing: const Icon(Icons.edit_calendar),
              onTap: _pickDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              title: const Text('Couleur'),
              onTap: _pickColor,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Choisir sur la roue',
                    icon: const Icon(Icons.palette_outlined),
                    onPressed: _pickColor,
                  ),
                  IconButton(
                    tooltip: 'Couleur aléatoire',
                    icon: const Icon(Icons.shuffle),
                    onPressed: _randomColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _submit,
            child: const Text('Enregistrer'),
          ),
        ),
      ),
    );
  }
}
