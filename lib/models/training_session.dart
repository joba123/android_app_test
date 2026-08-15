import 'package:einstellungstest_trainer/models/answer_record.dart';
import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';

/// Ergebnis einer einzelnen Aufgabe innerhalb einer abgeschlossenen Sitzung.
///
/// Bewusst ohne Referenz auf die [Question]: Der Verlauf soll auch dann noch
/// lesbar bleiben, wenn eine Aufgabe später aus dem Pool entfernt oder
/// umformuliert wird. Für die Anzeige direkt nach einer Runde wird stattdessen
/// [AnswerRecord] verwendet, das die Aufgabe noch vollständig kennt.
class QuestionResult {
  const QuestionResult({
    required this.questionId,
    required this.subCategory,
    required this.answered,
    required this.correct,
    required this.timeSpent,
  });

  final String questionId;
  final SubCategory subCategory;

  /// `false`, wenn übersprungen wurde oder die Zeit ablief.
  final bool answered;

  final bool correct;
  final Duration timeSpent;

  TrainingModule get module => subCategory.module;

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'subCategory': subCategory.id,
        'answered': answered,
        'correct': correct,
        'timeSpentMs': timeSpent.inMilliseconds,
      };

  static QuestionResult? fromJson(Map<String, dynamic> json) {
    final subCategory = SubCategory.tryFromId(json['subCategory'] as String? ?? '');
    final questionId = json['questionId'] as String?;
    if (subCategory == null || questionId == null) return null;

    return QuestionResult(
      questionId: questionId,
      subCategory: subCategory,
      answered: json['answered'] as bool? ?? false,
      correct: json['correct'] as bool? ?? false,
      timeSpent: Duration(milliseconds: json['timeSpentMs'] as int? ?? 0),
    );
  }
}

/// Eine abgeschlossene Übungssitzung.
///
/// Hält fest, welche Aufgaben bearbeitet wurden, ob sie richtig beantwortet
/// wurden, wie lange jede einzelne gedauert hat, in welchem Modus trainiert
/// wurde und wann das war.
class TrainingSession {
  const TrainingSession({
    required this.id,
    required this.mode,
    required this.module,
    required this.startedAt,
    required this.finishedAt,
    required this.results,
  });

  final String id;
  final SessionMode mode;

  /// `null` bei der modulübergreifenden Gesamtsimulation.
  final TrainingModule? module;

  final DateTime startedAt;
  final DateTime finishedAt;
  final List<QuestionResult> results;

  /// Baut die Sitzung aus den Protokollen einer gerade beendeten Runde.
  factory TrainingSession.fromAnswers({
    required SessionMode mode,
    required TrainingModule? module,
    required DateTime startedAt,
    required DateTime finishedAt,
    required List<AnswerRecord> answers,
    String? id,
  }) {
    return TrainingSession(
      id: id ?? 'session_${finishedAt.microsecondsSinceEpoch}',
      mode: mode,
      module: module,
      startedAt: startedAt,
      finishedAt: finishedAt,
      results: [for (final answer in answers) answer.toResult()],
    );
  }

  /// Gesamtzahl der gestellten Aufgaben, inklusive der nicht bearbeiteten.
  int get total => results.length;

  int get answeredCount => results.where((result) => result.answered).length;

  int get correctCount => results.where((result) => result.correct).length;

  int get wrongCount => answeredCount - correctCount;

  int get skippedCount => total - answeredCount;

  /// Trefferquote bezogen auf alle gestellten Aufgaben. Übersprungene zählen
  /// dabei als nicht richtig – so bleibt eine abgebrochene Simulation
  /// vergleichbar mit einer vollständig bearbeiteten.
  double get accuracy => total == 0 ? 0 : correctCount / total;

  /// Wie lange die Sitzung insgesamt gedauert hat, inklusive Briefings und
  /// Pausen zwischen den Testteilen.
  Duration get duration => finishedAt.difference(startedAt);

  /// Reine Bearbeitungszeit, aufsummiert über die einzelnen Aufgaben.
  Duration get timeOnQuestions {
    return results.fold(
      Duration.zero,
      (sum, result) => sum + result.timeSpent,
    );
  }

  /// Durchschnittliche Bearbeitungszeit je tatsächlich bearbeiteter Aufgabe.
  Duration get averageTimePerQuestion {
    final answered = results.where((result) => result.answered).toList();
    if (answered.isEmpty) return Duration.zero;

    final totalMs = answered.fold<int>(
      0,
      (sum, result) => sum + result.timeSpent.inMilliseconds,
    );
    return Duration(milliseconds: totalMs ~/ answered.length);
  }

  /// Ergebnisse gruppiert nach Unterkategorie – zeigt, wo es hakt.
  Map<SubCategory, List<QuestionResult>> get resultsBySubCategory {
    final grouped = <SubCategory, List<QuestionResult>>{};
    for (final result in results) {
      grouped.putIfAbsent(result.subCategory, () => []).add(result);
    }
    return grouped;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'mode': mode.id,
        'module': module?.id,
        'startedAt': startedAt.toIso8601String(),
        'finishedAt': finishedAt.toIso8601String(),
        'results': [for (final result in results) result.toJson()],
      };

  /// Liest eine Sitzung aus JSON. Gibt `null` zurück, wenn der Datensatz
  /// unbrauchbar ist – ein defekter Eintrag soll nicht den ganzen Verlauf
  /// unlesbar machen.
  static TrainingSession? fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final startedAt = DateTime.tryParse(json['startedAt'] as String? ?? '');
    final finishedAt = DateTime.tryParse(json['finishedAt'] as String? ?? '');
    if (id == null || startedAt == null || finishedAt == null) return null;

    final rawResults = json['results'];
    final results = <QuestionResult>[];
    if (rawResults is List) {
      for (final entry in rawResults) {
        if (entry is Map<String, dynamic>) {
          final result = QuestionResult.fromJson(entry);
          if (result != null) results.add(result);
        }
      }
    }

    final moduleId = json['module'] as String?;

    return TrainingSession(
      id: id,
      mode: SessionMode.fromId(json['mode'] as String? ?? ''),
      module: moduleId == null ? null : TrainingModule.fromId(moduleId),
      startedAt: startedAt,
      finishedAt: finishedAt,
      results: results,
    );
  }
}
