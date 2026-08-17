import 'dart:convert';

import 'package:einstellungstest_trainer/models/module_stats.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistiert Lernfortschritt und Sitzungsverlauf lokal auf dem Gerät.
///
/// Bewusst schlank gehalten: Solange nur Zählerstände und eine begrenzte
/// Historie gespeichert werden, reichen SharedPreferences. Wächst der Verlauf
/// oder kommen Auswertungen über Zeiträume dazu, wird hier auf eine lokale
/// Datenbank (z. B. Drift/sqflite) umgestellt, ohne dass Screens oder
/// Controller sich ändern.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const String _statsKey = 'training_stats_v1';
  static const String _sprintBestsKey = 'sprint_bests_v1';
  static const String _sessionsKey = 'training_sessions_v1';

  /// Obergrenze für den gespeicherten Verlauf. Ältere Sitzungen fallen hinten
  /// heraus, damit die Preferences nicht unbegrenzt wachsen.
  static const int maxStoredSessions = 50;

  // --- Aggregierter Fortschritt ---

  TrainingStats loadStats() {
    var stats = TrainingStats(
      perModule: TrainingStats.empty().perModule,
      sprintBests: _loadSprintBests(),
    );

    final raw = _prefs.getString(_statsKey);
    if (raw == null || raw.isEmpty) return stats;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return stats;

      for (final entry in decoded) {
        if (entry is Map<String, dynamic>) {
          stats = stats.withModule(ModuleStats.fromJson(entry));
        }
      }
      return stats;
    } on FormatException {
      // Beschädigte Daten sollen die App nicht blockieren.
      return stats;
    }
  }

  Map<String, int> _loadSprintBests() {
    final raw = _prefs.getString(_sprintBestsKey);
    if (raw == null || raw.isEmpty) return const {};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const {};

      return {
        for (final entry in decoded.entries)
          if (entry.key is String && entry.value is int)
            entry.key as String: entry.value as int,
      };
    } on FormatException {
      return const {};
    }
  }

  Future<void> saveStats(TrainingStats stats) async {
    await _prefs.setString(
      _statsKey,
      jsonEncode([for (final entry in stats.perModule.values) entry.toJson()]),
    );
    await _prefs.setString(_sprintBestsKey, jsonEncode(stats.sprintBests));
  }

  // --- Sitzungsverlauf ---

  /// Lädt den Verlauf, neueste Sitzung zuerst. Defekte Einzeleinträge werden
  /// übersprungen, statt den gesamten Verlauf zu verwerfen.
  List<TrainingSession> loadSessions() {
    final raw = _prefs.getString(_sessionsKey);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      final sessions = <TrainingSession>[];
      for (final entry in decoded) {
        if (entry is Map<String, dynamic>) {
          final session = TrainingSession.fromJson(entry);
          if (session != null) sessions.add(session);
        }
      }
      return sessions;
    } on FormatException {
      return const [];
    }
  }

  /// Stellt eine abgeschlossene Sitzung an den Anfang des Verlaufs.
  Future<List<TrainingSession>> appendSession(TrainingSession session) async {
    final sessions = [session, ...loadSessions()];
    final trimmed = sessions.length > maxStoredSessions
        ? sessions.sublist(0, maxStoredSessions)
        : sessions;

    await _prefs.setString(
      _sessionsKey,
      jsonEncode([for (final entry in trimmed) entry.toJson()]),
    );
    return trimmed;
  }

  Future<void> resetStats() async {
    await _prefs.remove(_statsKey);
    await _prefs.remove(_sprintBestsKey);
    await _prefs.remove(_sessionsKey);
  }
}
