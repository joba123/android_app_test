import 'package:einstellungstest_trainer/models/module_stats.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';
import 'package:einstellungstest_trainer/services/sync/cloud_models.dart';

/// Der lokale Stand, wie er in den Abgleich geht.
class LocalSnapshot {
  const LocalSnapshot({
    required this.stats,
    required this.sessions,
    this.examDate,
    this.examLabel,
    this.examUpdatedAt,
  });

  final TrainingStats stats;
  final List<TrainingSession> sessions;
  final DateTime? examDate;
  final String? examLabel;
  final DateTime? examUpdatedAt;
}

/// Was nach dem Zusammenführen gilt.
class SyncOutcome {
  const SyncOutcome({
    required this.stats,
    required this.sessions,
    required this.toUpload,
    required this.profile,
    required this.examDate,
    required this.examLabel,
    required this.examUpdatedAt,
    required this.downloadedCount,
  });

  /// Der zusammengeführte Fortschritt.
  final TrainingStats stats;

  /// Die zusammengeführte Historie, gekappt auf die lokale Obergrenze.
  final List<TrainingSession> sessions;

  /// Sitzungen, die der Cloud fehlen und hochgeladen werden müssen.
  final List<CloudSession> toUpload;

  /// Das Profil, das in die Cloud geschrieben wird.
  final CloudProfile profile;

  final DateTime? examDate;
  final String? examLabel;
  final DateTime? examUpdatedAt;

  /// Wie viele Sitzungen aus der Cloud dazugekommen sind.
  final int downloadedCount;

  int get uploadedCount => toUpload.length;

  bool get hasChanges => uploadedCount > 0 || downloadedCount > 0;
}

/// Führt lokalen Stand und Cloud-Stand zusammen.
///
/// Leitgedanke: **Die Sitzungen sind die Quelle der Wahrheit, die Zähler sind
/// abgeleitet.** Jede Sitzung trägt eine stabile Kennung. Hochgeladen wird nur,
/// was der Cloud fehlt, und die Zähler wachsen nur um genau diese Sitzungen.
/// Ein zweiter Abgleich findet nichts Neues und ändert deshalb auch nichts –
/// mehrfaches Anmelden kann den Fortschritt nicht verdoppeln.
///
/// Beim **ersten** Abgleich (noch kein Profil in der Cloud) werden die lokalen
/// Zähler unverändert übernommen. Sie sind dort die einzige verlässliche
/// Quelle: Die Historie ist auf [historyLimit] Einträge begrenzt, die Zähler
/// laufen dagegen über die gesamte Nutzungsdauer.
SyncOutcome mergeForSync({
  required LocalSnapshot local,
  required CloudProfile? cloudProfile,
  required List<CloudSession> cloudSessions,
  required Set<String> cloudSessionIds,
  int historyLimit = 50,
}) {
  // --- Sitzungen: Vereinigung über die Kennung ---
  final missingInCloud = local.sessions
      .where((session) => !cloudSessionIds.contains(session.id))
      .toList();

  final merged = <String, TrainingSession>{
    // Cloud zuerst, damit lokale Einträge mit voller Detailtiefe gewinnen.
    for (final session in cloudSessions) session.id: session.toSession(),
    for (final session in local.sessions) session.id: session,
  };

  final localIds = local.sessions.map((session) => session.id).toSet();
  final downloadedCount =
      cloudSessions.where((session) => !localIds.contains(session.id)).length;

  final history = merged.values.toList()
    ..sort((a, b) => b.finishedAt.compareTo(a.finishedAt));
  final cappedHistory =
      history.length > historyLimit ? history.sublist(0, historyLimit) : history;

  // --- Zähler ---
  final stats = cloudProfile == null
      ? local.stats
      : _addSessions(cloudProfile.toStats(), missingInCloud);

  // --- Bestwerte: der höhere gewinnt ---
  final bests = <String, int>{...?cloudProfile?.sprintBests};
  local.stats.sprintBests.forEach((key, score) {
    if (score > (bests[key] ?? 0)) bests[key] = score;
  });

  final withBests = TrainingStats(
    perModule: stats.perModule,
    sprintBests: bests,
  );

  // --- Testtermin: die jüngere Änderung gewinnt ---
  final (examDate, examLabel, examUpdatedAt) = _mergeExamDate(
    local: local,
    cloudProfile: cloudProfile,
  );

  return SyncOutcome(
    stats: withBests,
    sessions: cappedHistory,
    toUpload: [
      for (final session in missingInCloud) CloudSession.fromSession(session),
    ],
    profile: CloudProfile.fromLocal(
      stats: withBests,
      examDate: examDate,
      examLabel: examLabel,
      examUpdatedAt: examUpdatedAt,
    ),
    examDate: examDate,
    examLabel: examLabel,
    examUpdatedAt: examUpdatedAt,
    downloadedCount: downloadedCount,
  );
}

/// Rechnet die Zähler der übergebenen Sitzungen auf den Stand auf.
TrainingStats _addSessions(
  TrainingStats base,
  List<TrainingSession> sessions,
) {
  var stats = base;

  for (final session in sessions) {
    final grouped = <TrainingModule, List<QuestionResult>>{};
    for (final result in session.results) {
      grouped.putIfAbsent(result.module, () => []).add(result);
    }

    for (final entry in grouped.entries) {
      stats = stats.withModule(
        stats.forModule(entry.key).merge(
              addedAnswered: entry.value.where((r) => r.answered).length,
              addedCorrect: entry.value.where((r) => r.correct).length,
              completedSession: true,
            ),
      );
    }
  }

  return stats;
}

(DateTime?, String?, DateTime?) _mergeExamDate({
  required LocalSnapshot local,
  required CloudProfile? cloudProfile,
}) {
  final cloudDate = cloudProfile?.examDate;
  final localDate = local.examDate;

  if (localDate == null && cloudDate == null) return (null, null, null);
  if (localDate == null) {
    return (cloudDate, cloudProfile?.examLabel, cloudProfile?.examUpdatedAt);
  }
  if (cloudDate == null) {
    return (localDate, local.examLabel, local.examUpdatedAt);
  }

  // Beide gesetzt: die zuletzt vorgenommene Änderung gilt.
  final localStamp = local.examUpdatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  final cloudStamp =
      cloudProfile?.examUpdatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  return cloudStamp.isAfter(localStamp)
      ? (cloudDate, cloudProfile?.examLabel, cloudProfile?.examUpdatedAt)
      : (localDate, local.examLabel, local.examUpdatedAt);
}
