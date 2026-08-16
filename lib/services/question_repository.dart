import 'dart:math';

import 'package:einstellungstest_trainer/data/generators/math_question_factory.dart';
import 'package:einstellungstest_trainer/data/question_pool.dart';
import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/simulation.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';

/// Liefert Aufgaben – egal aus welcher Quelle.
///
/// Hier läuft der Unterschied zwischen generiertem und handgeschriebenem
/// Content zusammen: Mathematik kommt aus der [MathQuestionFactory],
/// Logik und Sprache aus dem statischen [QuestionPool]. Screens und Controller
/// merken davon nichts.
///
/// Bei Multiple Choice werden zusätzlich die Antwortoptionen gemischt, damit
/// sich niemand eine Position merken kann. Aufgaben mit Zahleneingabe bleiben
/// unverändert – dort gibt es nichts zu mischen.
///
/// [random] lässt sich in Tests mit einem festen Seed überschreiben; der Seed
/// wird an die Generatoren durchgereicht.
class QuestionRepository {
  QuestionRepository({Random? random, MathQuestionFactory? mathFactory})
      : _random = random ?? Random(),
        _math = mathFactory ?? MathQuestionFactory(random: random);

  final Random _random;
  final MathQuestionFactory _math;

  /// Standardumfang einer Übungsrunde.
  static const int practiceLength = 10;

  /// Länge der Sprint-Warteschlange. 60 Sekunden reichen realistisch für
  /// deutlich weniger Aufgaben – der Puffer verhindert nur, dass sie ausgeht.
  static const int sprintQueueLength = 40;

  List<Question> draw({
    required TrainingModule module,
    required int count,
    List<SubCategory> subCategories = const [],
    Difficulty? difficulty,
  }) {
    if (QuestionPool.isGenerated(module)) {
      return _math.generate(
        count: count,
        subCategories: subCategories,
        difficulty: difficulty,
      );
    }

    final pool = QuestionPool.forSubCategories(module, subCategories)
      ..shuffle(_random);
    final take = count < pool.length ? count : pool.length;
    return [for (final question in pool.take(take)) _shuffleOptions(question)];
  }

  /// Übungsmodus: begrenzte Runde ohne Zeitdruck.
  ///
  /// Bei statischem Content kann das Ergebnis kürzer ausfallen als [count],
  /// wenn das gewählte Thema weniger Aufgaben hergibt.
  List<Question> drawForScope(
    PracticeScope scope, {
    int count = practiceLength,
    Difficulty? difficulty,
  }) {
    final module = scope.module;
    if (module == null) {
      return drawMixed(count: count, difficulty: difficulty);
    }

    return draw(
      module: module,
      count: count,
      subCategories: scope.subCategories,
      difficulty: difficulty,
    );
  }

  /// Misch-Modus: Aufgaben aus allen Modulen, möglichst gleichmäßig verteilt
  /// und anschließend durchgemischt.
  List<Question> drawMixed({
    required int count,
    Difficulty? difficulty,
  }) {
    if (count <= 0) return const [];

    const modules = TrainingModule.values;
    final shares = {for (final module in modules) module: 0};
    for (var index = 0; index < count; index++) {
      final module = modules[index % modules.length];
      shares[module] = shares[module]! + 1;
    }

    final drawn = [
      for (final entry in shares.entries)
        ...draw(
          module: entry.key,
          count: entry.value,
          difficulty: difficulty,
        ),
    ];

    return drawn..shuffle(_random);
  }

  /// Sprint-Modus: In 60 Sekunden soll die Warteschlange nicht ausgehen.
  /// Bei statischem Content wird der Pool dafür zweimal gemischt angehängt.
  List<Question> drawSprintQueue(TrainingModule module) {
    if (QuestionPool.isGenerated(module)) {
      return _math.generate(count: sprintQueueLength);
    }

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
