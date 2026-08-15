import 'dart:math';

import 'package:einstellungstest_trainer/data/question_pool.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/simulation.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';

/// Zieht Aufgaben aus dem Pool und mischt dabei sowohl die Reihenfolge der
/// Aufgaben als auch – bei Multiple Choice – die der Antwortoptionen.
///
/// Das Mischen der Optionen ist bewusst hier angesiedelt und nicht im Content:
/// So kann der Pool die Lösungen sauber lesbar notieren, ohne dass Nutzende
/// sich eine Position merken können. Aufgaben mit Zahleneingabe bleiben
/// unverändert – dort gibt es nichts zu mischen.
///
/// [random] lässt sich in Tests mit einem festen Seed überschreiben.
class QuestionRepository {
  QuestionRepository({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Standardumfang einer Übungsrunde.
  static const int practiceLength = 10;

  List<Question> draw({
    required TrainingModule module,
    required int count,
    List<SubCategory> subCategories = const [],
  }) {
    final pool = QuestionPool.forSubCategories(module, subCategories)
      ..shuffle(_random);
    final take = count < pool.length ? count : pool.length;
    return [for (final question in pool.take(take)) _shuffleOptions(question)];
  }

  /// Übungsmodus: begrenzte Runde ohne Zeitdruck.
  List<Question> drawPractice(
    TrainingModule module, {
    int count = practiceLength,
  }) {
    return draw(module: module, count: count);
  }

  /// Sprint-Modus: In 60 Sekunden soll die Warteschlange nicht ausgehen,
  /// deshalb wird der Pool zweimal in unterschiedlicher Reihenfolge angehängt.
  List<Question> drawSprintQueue(TrainingModule module) {
    final firstRound = QuestionPool.forModule(module)..shuffle(_random);
    final secondRound = QuestionPool.forModule(module)..shuffle(_random);
    return [
      for (final question in [...firstRound, ...secondRound])
        _shuffleOptions(question),
    ];
  }

  /// Testsimulation: Aufgaben für genau einen Testteil.
  List<Question> drawForPart(SimulationPart part) {
    return draw(
      module: part.module,
      count: part.questionCount,
      subCategories: part.subCategories,
    );
  }

  Question _shuffleOptions(Question question) {
    final format = question.answer;
    if (format is! MultipleChoice) return question;

    final order = List<int>.generate(format.options.length, (index) => index)
      ..shuffle(_random);
    return question.copyWith(answer: format.reordered(order));
  }
}
