import 'package:einstellungstest_trainer/models/training_module.dart';

enum Difficulty {
  easy(label: 'Leicht'),
  medium(label: 'Mittel'),
  hard(label: 'Schwer');

  const Difficulty({required this.label});

  final String label;
}

/// Eine einzelne Multiple-Choice-Aufgabe.
///
/// Aufgaben sind unveraenderlich. Das Mischen der Antwortoptionen passiert
/// bewusst nicht hier, sondern in der [QuestionRepository], damit derselbe
/// Aufgaben-Pool mehrfach in unterschiedlicher Reihenfolge nutzbar ist.
class Question {
  const Question({
    required this.id,
    required this.module,
    required this.topic,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.difficulty = Difficulty.medium,
  });

  final String id;
  final TrainingModule module;

  /// Feinthema innerhalb des Moduls, z. B. "Dreisatz" oder "Zahlenreihe".
  /// Die Testsimulation gruppiert ihre Teile ueber dieses Feld.
  final String topic;

  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final Difficulty difficulty;

  String get correctAnswer => options[correctIndex];

  /// Liefert eine Kopie mit neu angeordneten Optionen. [order] enthaelt die
  /// urspruenglichen Indizes in ihrer neuen Reihenfolge.
  Question reordered(List<int> order) {
    assert(order.length == options.length, 'Reihenfolge passt nicht zur Anzahl der Optionen');
    return Question(
      id: id,
      module: module,
      topic: topic,
      prompt: prompt,
      options: [for (final index in order) options[index]],
      correctIndex: order.indexOf(correctIndex),
      explanation: explanation,
      difficulty: difficulty,
    );
  }
}
