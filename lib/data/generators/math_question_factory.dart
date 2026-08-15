import 'dart:math';

import 'package:einstellungstest_trainer/data/generators/arithmetic_generator.dart';
import 'package:einstellungstest_trainer/data/generators/percentage_generator.dart';
import 'package:einstellungstest_trainer/data/generators/question_generator.dart';
import 'package:einstellungstest_trainer/data/generators/rule_of_three_generator.dart';
import 'package:einstellungstest_trainer/data/generators/word_problem_generator.dart';
import 'package:einstellungstest_trainer/data/question_validation.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';

/// Erzeugt Mathematik-Aufgaben auf Abruf – der Pool ist damit unbegrenzt.
///
/// Die Fabrik hält den Zufallsgenerator und einen laufenden Zähler für die
/// IDs. Eine Instanz pro Sitzung genügt; innerhalb einer Sitzung sind die IDs
/// dadurch eindeutig.
///
/// Qualitätssicherung: Jede erzeugte Aufgabe läuft durch [validateQuestion].
/// Der Aufruf steckt in einem `assert`, greift also in Debug- und Testläufen
/// und kostet im Release-Build nichts. Ein Generator, der eine krumme Zahl
/// oder einen Lösungsweg ohne Ergebnis liefert, fällt damit sofort auf.
class MathQuestionFactory {
  MathQuestionFactory({Random? random}) : _random = random ?? Random();

  final Random _random;
  int _serial = 0;

  static const Map<SubCategory, QuestionGenerator> _generators = {
    SubCategory.arithmetic: ArithmeticGenerator(),
    SubCategory.ruleOfThree: RuleOfThreeGenerator(),
    SubCategory.percentage: PercentageGenerator(),
    SubCategory.wordProblems: WordProblemGenerator(),
  };

  /// Die Unterkategorien, die generiert werden können.
  static List<SubCategory> get supportedSubCategories =>
      _generators.keys.toList();

  static bool supports(SubCategory subCategory) =>
      _generators.containsKey(subCategory);

  /// Eine einzelne Aufgabe.
  ///
  /// Ohne [difficulty] wird gemischt: überwiegend leicht und mittel, seltener
  /// schwer. Das hält eine Übungsrunde machbar, ohne zu langweilen.
  Question next(SubCategory subCategory, {Difficulty? difficulty}) {
    final generator = _generators[subCategory];
    if (generator == null) {
      throw ArgumentError.value(
        subCategory,
        'subCategory',
        'Für diese Unterkategorie gibt es keinen Generator',
      );
    }

    final level = difficulty ?? _randomDifficulty();
    final id = 'math_${subCategory.id}_g${_serial++}';
    final question = generator.generate(_random, level, id);

    assert(() {
      final problems = validateQuestion(question);
      if (problems.isNotEmpty) {
        throw StateError(
          'Generierte Aufgabe ist fehlerhaft (${question.id}): '
          '${problems.join('; ')}\nAufgabe: ${question.prompt}',
        );
      }
      return true;
    }());

    return question;
  }

  /// Mehrere Aufgaben, gleichmäßig über die gewünschten Unterkategorien
  /// verteilt und anschließend gemischt.
  ///
  /// Eine leere [subCategories]-Liste bedeutet: alle Unterkategorien.
  List<Question> generate({
    required int count,
    List<SubCategory> subCategories = const [],
    Difficulty? difficulty,
  }) {
    if (count <= 0) return const [];

    final pool = subCategories.isEmpty
        ? supportedSubCategories
        : subCategories.where(supports).toList();

    if (pool.isEmpty) {
      throw ArgumentError.value(
        subCategories,
        'subCategories',
        'Keine dieser Unterkategorien lässt sich generieren',
      );
    }

    // Reihum durch die Unterkategorien, damit ein Testteil nicht zufällig aus
    // nur einem Thema besteht.
    final rotation = [...pool]..shuffle(_random);
    final questions = [
      for (var index = 0; index < count; index++)
        next(rotation[index % rotation.length], difficulty: difficulty),
    ];

    return questions..shuffle(_random);
  }

  Difficulty _randomDifficulty() {
    final roll = _random.nextInt(10);
    if (roll < 4) return Difficulty.easy;
    if (roll < 8) return Difficulty.medium;
    return Difficulty.hard;
  }
}
