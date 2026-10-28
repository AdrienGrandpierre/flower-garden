import 'package:flutter/material.dart';

/// Palette proposée pour distinguer les plantes dans le calendrier.
const plantColors = <Color>[
  Color(0xFF4CAF50),
  Color(0xFF009688),
  Color(0xFF2196F3),
  Color(0xFF3F51B5),
  Color(0xFF9C27B0),
  Color(0xFFE91E63),
  Color(0xFFF44336),
  Color(0xFFFF9800),
  Color(0xFFFFC107),
  Color(0xFF795548),
];

class Plant {
  Plant({
    required this.id,
    required this.name,
    this.species = '',
    required this.wateringIntervalDays,
    required Iterable<DateTime> wateringHistory,
    required this.color,
  }) : assert(wateringHistory.isNotEmpty),
       wateringHistory = List.unmodifiable(
         wateringHistory.map(DateUtils.dateOnly).toSet().toList()
           ..sort((a, b) => b.compareTo(a)),
       );

  final String id;
  final String name;
  final String species;
  final int wateringIntervalDays;

  /// Dates seules (sans heure), sans doublon, la plus récente en premier.
  final List<DateTime> wateringHistory;
  final Color color;

  DateTime get lastWatered => wateringHistory.first;

  DateTime get nextWatering =>
      DateUtils.addDaysToDate(lastWatered, wateringIntervalDays);

  /// Négatif si l'arrosage est en retard.
  int daysUntilWatering(DateTime today) => daysBetween(today, nextWatering);

  /// 1 juste après l'arrosage, 0 le jour où il faut arroser (ou en retard).
  double waterLevel(DateTime today) =>
      (daysUntilWatering(today) / wateringIntervalDays).clamp(0.0, 1.0);

  /// Suppose que les arrosages suivants seront faits à l'heure.
  bool needsWateringOn(DateTime day) {
    final diff = daysBetween(nextWatering, day);
    return diff >= 0 && diff % wateringIntervalDays == 0;
  }

  Plant copyWith({
    String? name,
    String? species,
    int? wateringIntervalDays,
    Iterable<DateTime>? wateringHistory,
    Color? color,
  }) => Plant(
    id: id,
    name: name ?? this.name,
    species: species ?? this.species,
    wateringIntervalDays: wateringIntervalDays ?? this.wateringIntervalDays,
    wateringHistory: wateringHistory ?? this.wateringHistory,
    color: color ?? this.color,
  );

  Plant wateredOn(DateTime day) =>
      copyWith(wateringHistory: [day, ...wateringHistory]);

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'species': species,
    'wateringIntervalDays': wateringIntervalDays,
    'wateringHistory': [for (final d in wateringHistory) d.toIso8601String()],
    'color': color.toARGB32(),
  };

  factory Plant.fromJson(Map<String, dynamic> json) => Plant(
    id: json['id'] as String,
    name: json['name'] as String,
    species: json['species'] as String? ?? '',
    wateringIntervalDays: json['wateringIntervalDays'] as int,
    // 'lastWatered' : ancien format, avant l'historique.
    wateringHistory:
        (json['wateringHistory'] as List<dynamic>?)?.map(
          (e) => DateTime.parse(e as String),
        ) ??
        [DateTime.parse(json['lastWatered'] as String)],
    color: Color(json['color'] as int),
  );
}

/// Calcul en UTC pour ne pas être faussé par les changements d'heure.
int daysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
