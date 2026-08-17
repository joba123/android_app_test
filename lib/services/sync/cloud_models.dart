import 'package:einstellungstest_trainer/models/module_stats.dart';
import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';

/// Ergebnis eines Themas innerhalb einer Sitzung – nur Summen.
///
/// Bewusst ohne Aufgaben-Kennungen: In der Cloud liegt kein feinkörniges
/// Leistungsprofil, sondern genau so viel, wie die Auswertung anzeigt.
class CloudTopicResult {
  const CloudTopicResult({
    required this.total,
    required this.answered,
    required this.correct,
    required this.timeMs,
  });

  final int total;
  final int answered;
  final int correct;
  final int timeMs;

  Map<String, dynamic> toJson() => {
        't': total,
        'a': answered,
        'c': correct,
        'ms': timeMs,
      };

  factory CloudTopicResult.fromJson(Map<String, dynamic> json) {
    return CloudTopicResult(
      total: json['t'] as int? ?? 0,
      answered: json['a'] as int? ?? 0,
      correct: json['c'] as int? ?? 0,
      timeMs: json['ms'] as int? ?? 0,
    );
  }
}

/// Eine abgeschlossene Sitzung in der Cloud-Darstellung.
///
/// Die Umwandlung von und nach [TrainingSession] ist auf Aggregatebene
/// verlustfrei: Gesamtzahlen, Trefferquote, Zeiten und die Aufschlüsselung
/// nach Thema kommen exakt zurück. Was bewusst verloren geht, ist die
/// Zuordnung zu einzelnen Aufgaben.
class CloudSession {
  const CloudSession({
    required this.id,
    required this.mode,
    required this.module,
    required this.startedAt,
    required this.finishedAt,
    required this.total,
    required this.answered,
    required this.correct,
    required this.byTopic,
  });

  final String id;
  final SessionMode mode;
  final TrainingModule? module;
  final DateTime startedAt;
  final DateTime finishedAt;
  final int total;
  final int answered;
  final int correct;
  final Map<SubCategory, CloudTopicResult> byTopic;

  factory CloudSession.fromSession(TrainingSession session) {
    final byTopic = <SubCategory, CloudTopicResult>{};

    session.resultsBySubCategory.forEach((subCategory, results) {
      final answered = results.where((result) => result.answered).toList();
      byTopic[subCategory] = CloudTopicResult(
        total: results.length,
        answered: answered.length,
        correct: results.where((result) => result.correct).length,
        timeMs: answered.fold<int>(
          0,
          (sum, result) => sum + result.timeSpent.inMilliseconds,
        ),
      );
    });

    return CloudSession(
      id: session.id,
      mode: session.mode,
      module: session.module,
      startedAt: session.startedAt,
      finishedAt: session.finishedAt,
      total: session.total,
      answered: session.answeredCount,
      correct: session.correctCount,
      byTopic: byTopic,
    );
  }

  /// Baut aus den Summen wieder eine [TrainingSession].
  ///
  /// Je Thema entstehen so viele Ergebnisse, wie gestellt wurden; die
  /// bearbeiteten tragen den anteiligen Zeitdurchschnitt. Alle Kennzahlen der
  /// Auswertung stimmen damit wieder, die Aufgaben-Kennung bleibt leer.
  TrainingSession toSession() {
    final results = <QuestionResult>[];

    byTopic.forEach((subCategory, topic) {
      final perQuestionMs =
          topic.answered == 0 ? 0 : topic.timeMs ~/ topic.answered;

      for (var index = 0; index < topic.total; index++) {
        final wasAnswered = index < topic.answered;
        results.add(
          QuestionResult(
            questionId: '',
            subCategory: subCategory,
            answered: wasAnswered,
            correct: index < topic.correct,
            timeSpent:
                Duration(milliseconds: wasAnswered ? perQuestionMs : 0),
          ),
        );
      }
    });

    return TrainingSession(
      id: id,
      mode: mode,
      module: module,
      startedAt: startedAt,
      finishedAt: finishedAt,
      results: results,
    );
  }

  Map<String, dynamic> toJson() => {
        'mode': mode.id,
        'moduleId': module?.id,
        'startedAt': startedAt.toUtc().toIso8601String(),
        'finishedAt': finishedAt.toUtc().toIso8601String(),
        'total': total,
        'answered': answered,
        'correct': correct,
        'durationMs': finishedAt.difference(startedAt).inMilliseconds,
        'bySubCategory': {
          for (final entry in byTopic.entries)
            entry.key.id: entry.value.toJson(),
        },
      };

  static CloudSession? fromJson(String id, Map<String, dynamic> json) {
    final startedAt = DateTime.tryParse(json['startedAt'] as String? ?? '');
    final finishedAt = DateTime.tryParse(json['finishedAt'] as String? ?? '');
    if (startedAt == null || finishedAt == null) return null;

    final byTopic = <SubCategory, CloudTopicResult>{};
    final raw = json['bySubCategory'];
    if (raw is Map) {
      for (final entry in raw.entries) {
        final subCategory = SubCategory.tryFromId(entry.key.toString());
        final value = entry.value;
        if (subCategory != null && value is Map<String, dynamic>) {
          byTopic[subCategory] = CloudTopicResult.fromJson(value);
        }
      }
    }

    final moduleId = json['moduleId'] as String?;

    return CloudSession(
      id: id,
      mode: SessionMode.fromId(json['mode'] as String? ?? ''),
      module: moduleId == null ? null : TrainingModule.fromId(moduleId),
      startedAt: startedAt,
      finishedAt: finishedAt,
      total: json['total'] as int? ?? 0,
      answered: json['answered'] as int? ?? 0,
      correct: json['correct'] as int? ?? 0,
      byTopic: byTopic,
    );
  }
}

/// Fortschritt eines Moduls in der Cloud.
class CloudProgress {
  const CloudProgress({
    required this.answered,
    required this.correct,
    required this.sessions,
  });

  final int answered;
  final int correct;
  final int sessions;

  Map<String, dynamic> toJson() => {
        'answered': answered,
        'correct': correct,
        'sessions': sessions,
      };

  factory CloudProgress.fromJson(Map<String, dynamic> json) {
    return CloudProgress(
      answered: json['answered'] as int? ?? 0,
      correct: json['correct'] as int? ?? 0,
      sessions: json['sessions'] as int? ?? 0,
    );
  }
}

/// Das Nutzerdokument.
///
/// Enthält keine E-Mail-Adresse und keinen Namen – beides liegt bereits bei
/// Firebase Auth, eine zweite Kopie wäre unnötige Datenhaltung.
class CloudProfile {
  const CloudProfile({
    this.examDate,
    this.examLabel,
    this.examUpdatedAt,
    this.progress = const {},
    this.sprintBests = const {},
    this.updatedAt,
  });

  final DateTime? examDate;
  final String? examLabel;

  /// Wann der Testtermin zuletzt geändert wurde – entscheidet beim
  /// Zusammenführen, welche Angabe gewinnt.
  final DateTime? examUpdatedAt;

  final Map<TrainingModule, CloudProgress> progress;
  final Map<String, int> sprintBests;
  final DateTime? updatedAt;

  static const int schemaVersion = 1;

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
        'examDate': examDate?.toUtc().toIso8601String(),
        'examLabel': examLabel,
        'examUpdatedAt': examUpdatedAt?.toUtc().toIso8601String(),
        'progress': {
          for (final entry in progress.entries)
            entry.key.id: entry.value.toJson(),
        },
        'sprintBests': sprintBests,
      };

  factory CloudProfile.fromJson(Map<String, dynamic> json) {
    final progress = <TrainingModule, CloudProgress>{};
    final rawProgress = json['progress'];
    if (rawProgress is Map) {
      for (final entry in rawProgress.entries) {
        final value = entry.value;
        if (value is Map<String, dynamic>) {
          progress[TrainingModule.fromId(entry.key.toString())] =
              CloudProgress.fromJson(value);
        }
      }
    }

    final bests = <String, int>{};
    final rawBests = json['sprintBests'];
    if (rawBests is Map) {
      for (final entry in rawBests.entries) {
        final value = entry.value;
        if (value is int) bests[entry.key.toString()] = value;
      }
    }

    return CloudProfile(
      examDate: DateTime.tryParse(json['examDate'] as String? ?? ''),
      examLabel: json['examLabel'] as String?,
      examUpdatedAt: DateTime.tryParse(json['examUpdatedAt'] as String? ?? ''),
      progress: progress,
      sprintBests: bests,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }

  /// Baut das Profil aus dem lokalen Stand.
  factory CloudProfile.fromLocal({
    required TrainingStats stats,
    required DateTime? examDate,
    required String? examLabel,
    required DateTime? examUpdatedAt,
  }) {
    return CloudProfile(
      examDate: examDate,
      examLabel: examLabel,
      examUpdatedAt: examUpdatedAt,
      progress: {
        for (final entry in stats.perModule.entries)
          entry.key: CloudProgress(
            answered: entry.value.answered,
            correct: entry.value.correct,
            sessions: entry.value.sessionsCompleted,
          ),
      },
      sprintBests: stats.sprintBests,
    );
  }

  /// Überträgt das Profil in den lokalen Statistik-Stand.
  TrainingStats toStats() {
    var stats = TrainingStats.empty();
    progress.forEach((module, entry) {
      stats = stats.withModule(
        ModuleStats(
          module: module,
          answered: entry.answered,
          correct: entry.correct,
          sessionsCompleted: entry.sessions,
        ),
      );
    });

    return TrainingStats(
      perModule: stats.perModule,
      sprintBests: sprintBests,
    );
  }
}
