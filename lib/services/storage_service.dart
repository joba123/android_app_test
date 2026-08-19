import 'dart:convert';

import 'package:einstellungstest_trainer/models/exam_date.dart';
import 'package:einstellungstest_trainer/models/exam_plan.dart';
import 'package:einstellungstest_trainer/models/ad_frequency.dart';
import 'package:einstellungstest_trainer/models/module_stats.dart';
import 'package:einstellungstest_trainer/models/pro_entitlement.dart';
import 'package:einstellungstest_trainer/models/reminder_settings.dart';
import 'package:einstellungstest_trainer/models/review_book.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';
import 'package:einstellungstest_trainer/models/user_profile.dart';
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
  static const String _examDateKey = 'exam_date_v1';
  static const String _reminderSettingsKey = 'reminder_settings_v1';
  static const String _entitlementKey = 'pro_entitlement_v1';
  static const String _adFrequencyKey = 'ad_frequency_v1';
  static const String _reviewBookKey = 'review_book_v1';
  static const String _onboardingKey = 'onboarding_done_v1';
  static const String _profileKey = 'user_profile_v1';
  static const String _themeModeKey = 'theme_mode_v1';
  static const String _examPlansKey = 'exam_plans_v1';
  static const String _activePlanKey = 'active_exam_plan_v1';

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
  ///
  /// [limit] kommt von aussen, weil Pro einen laengeren Verlauf bekommt.
  Future<List<TrainingSession>> appendSession(
    TrainingSession session, {
    int limit = maxStoredSessions,
  }) async {
    final sessions = [session, ...loadSessions()];
    final trimmed =
        sessions.length > limit ? sessions.sublist(0, limit) : sessions;

    await _prefs.setString(
      _sessionsKey,
      jsonEncode([for (final entry in trimmed) entry.toJson()]),
    );
    return trimmed;
  }

  // --- Testtermin ---

  ExamDate? loadExamDate() {
    final raw = _prefs.getString(_examDateKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return ExamDate.fromJson(decoded);
    } on FormatException {
      return null;
    }
  }

  Future<void> saveExamDate(ExamDate? examDate) async {
    if (examDate == null) {
      await _prefs.remove(_examDateKey);
      return;
    }
    await _prefs.setString(_examDateKey, jsonEncode(examDate.toJson()));
  }

  // --- Erinnerungen ---

  ReminderSettings loadReminderSettings() {
    final raw = _prefs.getString(_reminderSettingsKey);
    if (raw == null || raw.isEmpty) return const ReminderSettings();

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return const ReminderSettings();
      return ReminderSettings.fromJson(decoded);
    } on FormatException {
      return const ReminderSettings();
    }
  }

  Future<void> saveReminderSettings(ReminderSettings settings) async {
    await _prefs.setString(
      _reminderSettingsKey,
      jsonEncode(settings.toJson()),
    );
  }

  // --- Pro-Berechtigung ---

  ProEntitlement? loadEntitlement() {
    final raw = _prefs.getString(_entitlementKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return ProEntitlement.fromJson(decoded);
    } on FormatException {
      return null;
    }
  }

  /// Die lokale Kopie ist nur ein Zwischenspeicher, damit die App offline
  /// und ohne Verzoegerung weiss, was freigeschaltet ist. Massgeblich bleibt
  /// der Store; ein Abgleich ueberschreibt diesen Wert.
  Future<void> saveEntitlement(ProEntitlement? entitlement) async {
    if (entitlement == null) {
      await _prefs.remove(_entitlementKey);
      return;
    }
    await _prefs.setString(_entitlementKey, jsonEncode(entitlement.toJson()));
  }

  // --- Anzeigen-Taktung ---

  AdFrequencyState loadAdFrequency() {
    final raw = _prefs.getString(_adFrequencyKey);
    if (raw == null || raw.isEmpty) return const AdFrequencyState();

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return const AdFrequencyState();
      return AdFrequencyState.fromJson(decoded);
    } on FormatException {
      return const AdFrequencyState();
    }
  }

  Future<void> saveAdFrequency(AdFrequencyState state) async {
    await _prefs.setString(_adFrequencyKey, jsonEncode(state.toJson()));
  }

  // --- Wiederholung ---

  ReviewBook loadReviewBook() {
    final raw = _prefs.getString(_reviewBookKey);
    if (raw == null || raw.isEmpty) return const ReviewBook.empty();

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return const ReviewBook.empty();
      return ReviewBook.fromJson(decoded);
    } on FormatException {
      return const ReviewBook.empty();
    }
  }

  Future<void> saveReviewBook(ReviewBook book) async {
    await _prefs.setString(_reviewBookKey, jsonEncode(book.toJson()));
  }

  // --- Profil ---

  UserProfile loadProfile() {
    final raw = _prefs.getString(_profileKey);
    if (raw == null) return UserProfile.empty;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return UserProfile.empty;
      return UserProfile.fromJson(decoded);
    } on FormatException {
      return UserProfile.empty;
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  // --- Pruefungen ---

  List<ExamPlan> loadExamPlans() {
    final raw = _prefs.getString(_examPlansKey);
    if (raw == null) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      return [
        for (final entry in decoded)
          if (entry is Map<String, dynamic>) ExamPlan.fromJson(entry),
      ];
    } on FormatException {
      return const [];
    }
  }

  Future<void> saveExamPlans(List<ExamPlan> plans) async {
    await _prefs.setString(
      _examPlansKey,
      jsonEncode([for (final plan in plans) plan.toJson()]),
    );
  }

  String? get activeExamPlanId => _prefs.getString(_activePlanKey);

  Future<void> saveActiveExamPlanId(String id) async {
    await _prefs.setString(_activePlanKey, id);
  }

  // --- Darstellung ---

  String get themeModeId => _prefs.getString(_themeModeKey) ?? 'system';

  Future<void> saveThemeModeId(String id) async {
    await _prefs.setString(_themeModeKey, id);
  }

  // --- Einfuehrung ---

  /// Ob die Einfuehrung schon durchlaufen wurde.
  bool get onboardingDone => _prefs.getBool(_onboardingKey) ?? false;

  Future<void> setOnboardingDone(bool done) async {
    await _prefs.setBool(_onboardingKey, done);
  }

  Future<void> resetStats() async {
    await _prefs.remove(_statsKey);
    await _prefs.remove(_sprintBestsKey);
    await _prefs.remove(_sessionsKey);
    await _prefs.remove(_reviewBookKey);
  }

  /// Räumt alles ab, was zu diesem Gerät gehört – auch den Testtermin.
  /// Wird beim Löschen des Kontos verwendet.
  Future<void> resetEverything() async {
    await resetStats();
    await _prefs.remove(_examDateKey);
    await _prefs.remove(_reminderSettingsKey);
    await _prefs.remove(_adFrequencyKey);
    await _prefs.remove(_profileKey);
    await _prefs.remove(_examPlansKey);
    await _prefs.remove(_activePlanKey);
    // Die Pro-Berechtigung bleibt bewusst stehen: Sie haengt am Store-Konto,
    // nicht an den Lerndaten. Wer sein Konto loescht, verliert nicht, wofuer
    // er bezahlt hat.
  }

  /// Ersetzt die gespeicherten Sitzungen vollständig – nach einem Abgleich
  /// mit der Cloud ist die zusammengeführte Liste maßgeblich.
  Future<void> replaceSessions(
    List<TrainingSession> sessions, {
    int limit = maxStoredSessions,
  }) async {
    final trimmed =
        sessions.length > limit ? sessions.sublist(0, limit) : sessions;

    await _prefs.setString(
      _sessionsKey,
      jsonEncode([for (final entry in trimmed) entry.toJson()]),
    );
  }
}
