import 'dart:convert';

import 'package:einstellungstest_trainer/models/module_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistiert den Lernfortschritt lokal auf dem Geraet.
///
/// Bewusst schlank gehalten: Solange nur Zaehlerstaende gespeichert werden,
/// reichen SharedPreferences. Sobald Verlaufsdaten pro Sitzung dazukommen,
/// wird hier auf eine lokale Datenbank (z. B. Drift/sqflite) umgestellt,
/// ohne dass Screens oder Controller sich aendern.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const String _statsKey = 'training_stats_v1';

  TrainingStats loadStats() {
    final raw = _prefs.getString(_statsKey);
    if (raw == null || raw.isEmpty) return TrainingStats.empty();

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return TrainingStats.empty();

      var stats = TrainingStats.empty();
      for (final entry in decoded) {
        if (entry is Map<String, dynamic>) {
          stats = stats.withModule(ModuleStats.fromJson(entry));
        }
      }
      return stats;
    } on FormatException {
      // Beschaedigte Daten sollen die App nicht blockieren.
      return TrainingStats.empty();
    }
  }

  Future<void> saveStats(TrainingStats stats) async {
    final payload = jsonEncode(
      [for (final entry in stats.perModule.values) entry.toJson()],
    );
    await _prefs.setString(_statsKey, payload);
  }

  Future<void> resetStats() async {
    await _prefs.remove(_statsKey);
  }
}
