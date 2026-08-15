import 'dart:math';

import 'package:einstellungstest_trainer/data/question_pool.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/simulation.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';

/// Zieht Aufgaben aus dem Pool und mischt dabei sowohl die Reihenfolge der
/// Aufgaben als auch die der Antwortoptionen.
///
/// Das Mischen der Optionen ist bewusst hier angesiedelt und nicht im Content:
/// So kann der Pool die Loesungen sauber lesbar notieren, ohne dass Nutzende
/// sich eine Position merken koennen.
///
/// [random] laesst sich in Tests mit einem festen Seed ueberschreiben.
class QuestionRepository {
  QuestionRepository({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Standardumfang einer Uebungsrunde.
  static const int practiceLength = 10;

  List<Question> draw({
    required TrainingModule module,
    required int count,
    List<String> topics = const [],
  }) {
    final pool = QuestionPool.forTopics(module, topics)..shuffle(_random);
    final take = count < pool.length ? count : pool.length;
    return [for (final question in pool.take(take)) _shuffleOptions(question)];
  }

  /// Uebungsmodus: begrenzte Runde ohne Zeitdruck.
  List<Question> drawPractice(TrainingModule module, {int count = practiceLength}) {
    return draw(module: module, count: count);
  }

  /// Sprint-Modus: In 60 Sekunden soll die Warteschlange nicht ausgehen,
  /// deshalb wird der Pool zweimal in unterschiedlicher Reihenfolge angehaengt.
  List<Question> drawSprintQueue(TrainingModule module) {
    final firstRound = QuestionPool.forModule(module)..shuffle(_random);
    final secondRound = QuestionPool.forModule(module)..shuffle(_random);
    return [
      for (final question in [...firstRound, ...secondRound])
        _shuffleOptions(question),
    ];
  }

  /// Testsimulation: Aufgaben fuer genau einen Testteil.
  List<Question> drawForPart(SimulationPart part) {
    return draw(
      module: part.module,
      count: part.questionCount,
      topics: part.topics,
    );
  }

  Question _shuffleOptions(Question question) {
    final order = List<int>.generate(question.options.length, (index) => index)
      ..shuffle(_random);
    return question.reordered(order);
  }
}
