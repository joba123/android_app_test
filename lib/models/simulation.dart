import 'package:einstellungstest_trainer/models/answer_record.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';

/// Ein Testteil innerhalb einer Simulation, z. B. "Teil 2: Sprache".
///
/// Jeder Teil hat eine feste Bearbeitungszeit. Läuft sie ab, wird der Teil
/// automatisch abgeschlossen – offene Aufgaben zählen als nicht beantwortet.
/// Genau dieses Verhalten macht die Simulation realitätsnah.
///
/// Ein Teil kann mehrere Unterkategorien und damit auch mehrere Module
/// umfassen (etwa "Schlussfolgerungen & Wortschatz"). Das Modul wird deshalb
/// aus den Unterkategorien abgeleitet und nicht zusätzlich gespeichert – wie
/// schon bei [Question].
class SimulationPart {
  const SimulationPart({
    required this.title,
    required this.subCategories,
    required this.questionCount,
    required this.duration,
    required this.instructions,
  });

  final String title;

  /// Themen, aus denen die Aufgaben dieses Teils gezogen werden.
  /// Darf nicht leer sein – ein Test im Aufgabenpool wacht darüber.
  final List<SubCategory> subCategories;

  final int questionCount;
  final Duration duration;
  final String instructions;

  /// Alle Module, die dieser Teil berührt.
  Set<TrainingModule> get modules =>
      {for (final subCategory in subCategories) subCategory.module};

  /// Das Modul des Teils – `null`, wenn er mehrere umfasst.
  TrainingModule? get primaryModule {
    final all = modules;
    return all.length == 1 ? all.first : null;
  }

  /// Kurzbezeichnung der abgedeckten Bereiche für Kopfzeilen.
  String get moduleLabel {
    final single = primaryModule;
    if (single != null) return single.shortLabel;
    return modules.map((module) => module.shortLabel).join(' + ');
  }

  /// Durchschnittlich verfügbare Zeit pro Aufgabe – wird im Briefing vor dem
  /// Teil angezeigt.
  Duration get timePerQuestion {
    if (questionCount == 0) return Duration.zero;
    return Duration(seconds: duration.inSeconds ~/ questionCount);
  }
}

/// Bauplan einer kompletten Testsimulation.
class SimulationBlueprint {
  const SimulationBlueprint({
    required this.id,
    required this.title,
    required this.description,
    required this.parts,
    this.module,
  });

  final String id;
  final String title;
  final String description;
  final List<SimulationPart> parts;

  /// `null` bei der modulübergreifenden Gesamtsimulation.
  final TrainingModule? module;

  Duration get totalDuration => parts.fold(
        Duration.zero,
        (sum, part) => sum + part.duration,
      );

  int get totalQuestions =>
      parts.fold(0, (sum, part) => sum + part.questionCount);
}

/// Ein Testteil mit bereits gezogenen Aufgaben.
class LoadedPart {
  const LoadedPart({required this.part, required this.questions});

  final SimulationPart part;
  final List<Question> questions;
}

enum SimulationStage {
  /// Briefing vor einem Teil – der Countdown läuft noch nicht.
  briefing,

  /// Teil wird bearbeitet.
  running,

  /// Unterbrochen. Im echten Test nicht möglich – die Oberfläche weist
  /// deutlich darauf hin und die Auswertung vermerkt es.
  paused,

  /// Alle Teile abgeschlossen.
  finished,
}

/// Laufender Zustand einer Testsimulation über mehrere Teile hinweg.
class SimulationSession {
  const SimulationSession({
    required this.blueprint,
    required this.loadedParts,
    required this.startedAt,
    this.partIndex = 0,
    this.questionIndex = 0,
    this.answers = const [],
    this.response,
    this.remainingSeconds = 0,
    this.stage = SimulationStage.briefing,
    this.pauseCount = 0,
    this.pausedDuration = Duration.zero,
    this.summary,
  });

  final SimulationBlueprint blueprint;
  final List<LoadedPart> loadedParts;

  /// Beginn der Simulation – wird für den Verlaufseintrag gebraucht.
  final DateTime startedAt;

  final int partIndex;
  final int questionIndex;

  /// Antworten aller bisher bearbeiteten Teile, in Reihenfolge.
  final List<AnswerRecord> answers;

  final Response? response;
  final int remainingSeconds;
  final SimulationStage stage;

  /// Wie oft unterbrochen wurde. Steht in der Auswertung, damit ein
  /// pausierter Durchlauf nicht mit einem durchgezogenen verwechselt wird.
  final int pauseCount;

  /// Gesamte Pausenzeit – wird aus der Netto-Bearbeitungszeit herausgerechnet.
  final Duration pausedDuration;

  /// Auswertung. Steht erst fest, wenn [stage] auf
  /// [SimulationStage.finished] gewechselt ist.
  final TrainingSession? summary;

  LoadedPart get currentPart => loadedParts[partIndex];

  SimulationPart get currentPartSpec => currentPart.part;

  Question get currentQuestion => currentPart.questions[questionIndex];

  bool get isLastPart => partIndex >= loadedParts.length - 1;

  bool get isLastQuestionInPart =>
      questionIndex >= currentPart.questions.length - 1;

  bool get wasPaused => pauseCount > 0;

  int get correctCount => answers.where((answer) => answer.isCorrect).length;

  int get totalQuestions => loadedParts.fold(
        0,
        (sum, loaded) => sum + loaded.questions.length,
      );

  int? get selectedOptionIndex {
    final given = response;
    return given is ChoiceResponse ? given.optionIndex : null;
  }

  /// Anzahl der Antworten, die vor dem aktuellen Teil protokolliert wurden.
  /// Damit lässt sich die Auswertung wieder nach Teilen aufschlüsseln.
  int get answersBeforeCurrentPart {
    var count = 0;
    for (var i = 0; i < partIndex; i++) {
      count += loadedParts[i].questions.length;
    }
    return count;
  }

  double get partProgress {
    final total = currentPart.questions.length;
    return total == 0 ? 0 : questionIndex / total;
  }

  /// Schlüsselt die Antworten wieder nach Testteilen auf. Grundlage der
  /// Auswertung, die nach der Simulation angezeigt wird.
  List<PartResult> get partResults {
    final results = <PartResult>[];
    var offset = 0;
    for (final loaded in loadedParts) {
      final count = loaded.questions.length;
      results.add(
        PartResult(
          part: loaded.part,
          answers: answers.skip(offset).take(count).toList(),
        ),
      );
      offset += count;
    }
    return results;
  }

  SimulationSession copyWith({
    int? partIndex,
    int? questionIndex,
    List<AnswerRecord>? answers,
    Response? response,
    bool clearResponse = false,
    int? remainingSeconds,
    SimulationStage? stage,
    int? pauseCount,
    Duration? pausedDuration,
    TrainingSession? summary,
  }) {
    return SimulationSession(
      blueprint: blueprint,
      loadedParts: loadedParts,
      startedAt: startedAt,
      partIndex: partIndex ?? this.partIndex,
      questionIndex: questionIndex ?? this.questionIndex,
      answers: answers ?? this.answers,
      response: clearResponse ? null : (response ?? this.response),
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      stage: stage ?? this.stage,
      pauseCount: pauseCount ?? this.pauseCount,
      pausedDuration: pausedDuration ?? this.pausedDuration,
      summary: summary ?? this.summary,
    );
  }
}

/// Auswertung eines einzelnen Teils für den Ergebnis-Screen.
class PartResult {
  const PartResult({
    required this.part,
    required this.answers,
  });

  final SimulationPart part;
  final List<AnswerRecord> answers;

  int get correctCount => answers.where((answer) => answer.isCorrect).length;

  int get total => answers.length;

  double get accuracy => total == 0 ? 0 : correctCount / total;

  double get errorRate => total == 0 ? 0 : 1 - accuracy;

  /// Reine Bearbeitungszeit dieses Teils.
  Duration get timeSpent => answers.fold(
        Duration.zero,
        (sum, answer) => sum + answer.timeSpent,
      );

  /// Durchschnittszeit über die tatsächlich bearbeiteten Aufgaben.
  Duration get averageTimePerQuestion {
    final answered = answers.where((answer) => answer.isAnswered).toList();
    if (answered.isEmpty) return Duration.zero;

    final totalMs = answered.fold<int>(
      0,
      (sum, answer) => sum + answer.timeSpent.inMilliseconds,
    );
    return Duration(milliseconds: totalMs ~/ answered.length);
  }
}
