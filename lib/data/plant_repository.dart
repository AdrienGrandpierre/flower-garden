import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/plant.dart';

class PlantRepository {
  const PlantRepository();

  static const _key = 'plants';

  Future<List<Plant>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Plant.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> save(List<Plant> plants) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(plants.map((p) => p.toJson()).toList()),
    );
  }
}
