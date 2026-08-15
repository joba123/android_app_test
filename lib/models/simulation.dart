import 'package:einstellungstest_trainer/models/answer_record.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';

/// Ein Testteil innerhalb einer Simulation, z. B. "Teil 2: Dreisatz & Prozent".
///
/// Jeder Teil hat eine feste Bearbeitungszeit. Laeuft sie ab, wird der Teil
/// automatisch abgeschlossen - offene Aufgaben zaehlen als nicht beantwortet.
/// Genau dieses Verhalten macht die Simulation realitaetsnah.
class SimulationPart {
  const SimulationPart({
    required this.title,
    required this.module,
    required this.topics,
    required this.questionCount,
    required this.duration,
    required this.instructions,
  });

  final String title;
  final TrainingModule module;

  /// Feinthemen, aus denen die Aufgaben dieses Teils gezogen werden.
  /// Leere Liste bedeutet: alle Themen des Moduls sind zugelassen.
  final List<String> topics;

  final int questionCount;
  final Duration duration;
  final String instructions;

  /// Durchschnittlich verfuegbare Zeit pro Aufgabe - wird dem Nutzer im
  /// Briefing vor dem Teil angezeigt.
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

  /// `null` bei der modul-uebergreifenden Gesamtsimulation.
  final TrainingModule? module;

  Duration get totalDuration => parts.fold(
        Duration.zero,
        (sum, part) => sum + part.duration,
      );

  int get totalQuestions => parts.fold(0, (sum, part) => sum + part.questionCount);
}

/// Ein Testteil mit bereits gezogenen Aufgaben.
class LoadedPart {
  const LoadedPart({required this.part, required this.questions});

  final SimulationPart part;
  final List<Question> questions;
}

enum SimulationStage {
  /// Briefing vor einem Teil - der Countdown laeuft noch nicht.
  briefing,

  /// Teil wird bearbeitet.
  running,

  /// Alle Teile abgeschlossen.
  finished,
}

/// Laufender Zustand einer Testsimulation ueber mehrere Teile hinweg.
class SimulationSession {
  const SimulationSession({
    required this.blueprint,
    required this.loadedParts,
    this.partIndex = 0,
    this.questionIndex = 0,
    this.answers = const [],
    this.selectedIndex,
    this.remainingSeconds = 0,
    this.stage = SimulationStage.briefing,
  });

  final SimulationBlueprint blueprint;
  final List<LoadedPart> loadedParts;
  final int partIndex;
  final int questionIndex;

  /// Antworten aller bisher bearbeiteten Teile, in Reihenfolge.
  final List<AnswerRecord> answers;

  final int? selectedIndex;
  final int remainingSeconds;
  final SimulationStage stage;

  LoadedPart get currentPart => loadedParts[partIndex];

  SimulationPart get currentPartSpec => currentPart.part;

  Question get currentQuestion => currentPart.questions[questionIndex];

  bool get isLastPart => partIndex >= loadedParts.length - 1;

  bool get isLastQuestionInPart => questionIndex >= currentPart.questions.length - 1;

  int get correctCount => answers.where((answer) => answer.isCorrect).length;

  int get totalQuestions => loadedParts.fold(
        0,
        (sum, loaded) => sum + loaded.questions.length,
      );

  /// Anzahl der Antworten, die vor dem aktuellen Teil protokolliert wurden.
  /// Damit laesst sich die Auswertung wieder nach Teilen aufschluesseln.
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

  /// Schluesselt die Antworten wieder nach Testteilen auf. Grundlage der
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
    int? selectedIndex,
    bool clearSelection = false,
    int? remainingSeconds,
    SimulationStage? stage,
  }) {
    return SimulationSession(
      blueprint: blueprint,
      loadedParts: loadedParts,
      partIndex: partIndex ?? this.partIndex,
      questionIndex: questionIndex ?? this.questionIndex,
      answers: answers ?? this.answers,
      selectedIndex: clearSelection ? null : (selectedIndex ?? this.selectedIndex),
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      stage: stage ?? this.stage,
    );
  }
}

/// Auswertung eines einzelnen Teils fuer den Ergebnis-Screen.
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
}
