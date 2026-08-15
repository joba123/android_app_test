import 'dart:math';

import 'package:einstellungstest_trainer/data/generators/question_generator.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';

/// Dreisatz – proportional und antiproportional.
///
/// Alle Varianten werden aus einer ganzzahligen Grundgröße aufgebaut (Leistung
/// pro Einheit, Gesamtarbeit, Stückpreis in Cent). Dadurch geht jede Aufgabe
/// exakt auf, ohne dass gerundet werden muss.
class RuleOfThreeGenerator extends QuestionGenerator {
  const RuleOfThreeGenerator();

  @override
  SubCategory get subCategory => SubCategory.ruleOfThree;

  @override
  Question generate(Random random, Difficulty difficulty, String id) {
    return switch (random.nextInt(4)) {
      0 => _proportionalOutput(random, difficulty, id),
      1 => _inverseWorkers(random, difficulty, id),
      2 => _unitPrice(random, difficulty, id),
      _ => _consumption(random, difficulty, id),
    };
  }

  /// Je mehr Maschinen und Stunden, desto mehr Teile.
  Question _proportionalOutput(Random random, Difficulty difficulty, String id) {
    final (minRate, maxRate) = switch (difficulty) {
      Difficulty.easy => (2, 5),
      Difficulty.medium => (4, 12),
      Difficulty.hard => (7, 25),
    };

    // Leistung pro Maschine und Stunde – die Größe, aus der alles folgt.
    final rate = GeneratorSupport.between(random, minRate, maxRate);
    final machines = GeneratorSupport.between(random, 2, 6);
    final hours = GeneratorSupport.between(random, 2, 8);
    final askedMachines = GeneratorSupport.between(random, 2, 9);
    final askedHours = GeneratorSupport.between(random, 2, 10);

    final known = rate * machines * hours;
    final result = rate * askedMachines * askedHours;

    return Question(
      id: id,
      subCategory: subCategory,
      prompt: '$machines Maschinen produzieren '
          '${GeneratorSupport.integer(known)} Teile in $hours Stunden.\n'
          'Wie viele Teile schaffen $askedMachines Maschinen '
          'in $askedHours Stunden?',
      answer: GeneratorSupport.count(result, unit: 'Teile'),
      explanation: 'Erst auf eine Maschine und eine Stunde herunterrechnen: '
          '${GeneratorSupport.integer(known)} : ($machines · $hours) = '
          '$rate Teile. '
          'Dann hochrechnen: $askedMachines · $askedHours · $rate = '
          '${GeneratorSupport.integer(result)} Teile.',
      difficulty: difficulty,
    );
  }

  /// Je mehr Arbeiter, desto weniger Tage – umgekehrter Dreisatz.
  Question _inverseWorkers(Random random, Difficulty difficulty, String id) {
    final maxFactor = switch (difficulty) {
      Difficulty.easy => 2,
      Difficulty.medium => 3,
      Difficulty.hard => 4,
    };

    final askedWorkers = GeneratorSupport.between(random, 2, 9);
    var workers = GeneratorSupport.between(random, 2, 12);
    if (workers == askedWorkers) workers = askedWorkers == 2 ? 3 : 2;

    // Die Ausgangsdauer wird als Vielfaches der gesuchten Besetzung gewählt.
    // Damit ist die Gesamtarbeit garantiert ohne Rest auf sie aufteilbar –
    // ein Teilersuchen mit Sonderfällen erübrigt sich.
    final factor = GeneratorSupport.between(random, 1, maxFactor);
    final days = askedWorkers * factor;
    final totalWorkDays = workers * days;
    final result = workers * factor;

    return Question(
      id: id,
      subCategory: subCategory,
      prompt: '$workers Arbeiter benötigen für einen Auftrag $days Tage.\n'
          'Wie lange brauchen $askedWorkers Arbeiter bei gleicher Leistung?',
      answer: GeneratorSupport.count(result, unit: 'Tage'),
      explanation: 'Umgekehrter Dreisatz: Insgesamt sind '
          '$workers · $days = ${GeneratorSupport.integer(totalWorkDays)} '
          'Arbeitstage nötig. '
          'Auf $askedWorkers Arbeiter verteilt: '
          '${GeneratorSupport.integer(totalWorkDays)} : $askedWorkers = '
          '${GeneratorSupport.integer(result)} Tage.',
      difficulty: difficulty,
    );
  }

  /// Stückpreis hoch- oder herunterrechnen.
  Question _unitPrice(Random random, Difficulty difficulty, String id) {
    final (minUnit, maxUnit) = switch (difficulty) {
      Difficulty.easy => (100, 500),
      Difficulty.medium => (120, 1500),
      Difficulty.hard => (245, 4995),
    };

    final unitCents = GeneratorSupport.multipleBetween(
      random,
      minUnit,
      maxUnit,
      5,
    );
    final known = GeneratorSupport.between(random, 2, 8);
    var asked = GeneratorSupport.between(random, 3, 15);
    if (asked == known) asked += 1;

    final knownTotal = known * unitCents;
    final result = asked * unitCents;

    return Question(
      id: id,
      subCategory: subCategory,
      prompt: '$known Packungen kosten zusammen '
          '${GeneratorSupport.euro(knownTotal)}.\n'
          'Was kosten $asked Packungen?',
      answer: GeneratorSupport.money(result),
      explanation: 'Eine Packung kostet '
          '${GeneratorSupport.euro(knownTotal)} : $known = '
          '${GeneratorSupport.euro(unitCents)}. '
          '$asked Packungen kosten $asked · '
          '${GeneratorSupport.euro(unitCents)} = '
          '${GeneratorSupport.euro(result)}.',
      difficulty: difficulty,
    );
  }

  /// Verbrauch pro 100 km auf eine Strecke umrechnen.
  Question _consumption(Random random, Difficulty difficulty, String id) {
    final (minDistance, maxDistance) = switch (difficulty) {
      Difficulty.easy => (200, 500),
      Difficulty.medium => (150, 750),
      Difficulty.hard => (250, 950),
    };

    final distance =
        GeneratorSupport.multipleBetween(random, minDistance, maxDistance, 50);

    // Bei Strecken, die kein Vielfaches von 100 sind, muss der Verbrauch
    // gerade sein, damit das Ergebnis ganzzahlig bleibt.
    final needsEvenRate = distance % 100 != 0;
    final rate = needsEvenRate
        ? GeneratorSupport.multipleBetween(random, 6, 14, 2)
        : GeneratorSupport.between(random, 5, 14);

    final result = rate * distance ~/ 100;

    return Question(
      id: id,
      subCategory: subCategory,
      prompt: 'Ein Fahrzeug verbraucht $rate Liter auf 100 Kilometer.\n'
          'Wie viele Liter braucht es für '
          '${GeneratorSupport.integer(distance)} Kilometer?',
      answer: GeneratorSupport.count(result, unit: 'Liter'),
      explanation: 'Auf einen Kilometer entfallen $rate : 100 Liter. '
          'Für ${GeneratorSupport.integer(distance)} km also '
          '$rate · ${GeneratorSupport.integer(distance)} : 100 = '
          '${GeneratorSupport.integer(result)} Liter.',
      difficulty: difficulty,
    );
  }
}
