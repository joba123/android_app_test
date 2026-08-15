import 'dart:math';

import 'package:einstellungstest_trainer/data/generators/question_generator.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';

/// Prozentrechnung: Prozentwert, Prozentsatz, Grundwert, Erhöhung/Minderung
/// und der vermehrte Grundwert (Rückwärtsrechnung).
///
/// Die Zahlen werden so gewählt, dass jedes Ergebnis exakt aufgeht:
/// Grundwerte sind Vielfache von 20 bzw. 100, Prozentsätze Vielfache von 5,
/// Geldbeträge werden in Cent gerechnet.
class PercentageGenerator extends QuestionGenerator {
  const PercentageGenerator();

  @override
  SubCategory get subCategory => SubCategory.percentage;

  /// Faktor, dessen Vielfaches der Ausgangspreis sein muss, damit der
  /// erhöhte Preis auf volle Euro aufgeht.
  static const Map<int, int> _reverseSteps = {10: 10, 20: 5, 25: 4, 50: 2};

  @override
  Question generate(Random random, Difficulty difficulty, String id) {
    return switch (random.nextInt(5)) {
      0 => _percentageValue(random, difficulty, id),
      1 => _percentageRate(random, difficulty, id),
      2 => _baseValue(random, difficulty, id),
      3 => _priceChange(random, difficulty, id),
      _ => _reversePercentage(random, difficulty, id),
    };
  }

  /// Wie viel sind p % von G?
  Question _percentageValue(Random random, Difficulty difficulty, String id) {
    final (minBase, maxBase) = switch (difficulty) {
      Difficulty.easy => (100, 1000),
      Difficulty.medium => (200, 5000),
      Difficulty.hard => (1000, 25000),
    };

    // Grundwert als Vielfaches von 20 und Prozentsatz als Vielfaches von 5:
    // damit ist G · p immer durch 100 teilbar.
    final base = GeneratorSupport.multipleBetween(random, minBase, maxBase, 20);
    final percent = GeneratorSupport.multipleBetween(random, 5, 90, 5);
    final result = base * percent ~/ 100;

    return Question(
      id: id,
      subCategory: subCategory,
      prompt: 'Wie viel sind $percent % von '
          '${GeneratorSupport.integer(base)}?',
      answer: GeneratorSupport.count(result),
      explanation: 'Prozentwert = Grundwert · Prozentsatz : 100. '
          'Also ${GeneratorSupport.integer(base)} · $percent : 100 = '
          '${GeneratorSupport.integer(base * percent)} : 100 = '
          '${GeneratorSupport.integer(result)}.',
      difficulty: difficulty,
    );
  }

  /// Wie viel Prozent sind W von G?
  Question _percentageRate(Random random, Difficulty difficulty, String id) {
    final (minBase, maxBase) = switch (difficulty) {
      Difficulty.easy => (100, 1000),
      Difficulty.medium => (200, 4000),
      Difficulty.hard => (600, 12000),
    };

    final base = GeneratorSupport.multipleBetween(random, minBase, maxBase, 20);
    final percent = GeneratorSupport.multipleBetween(random, 5, 90, 5);
    final value = base * percent ~/ 100;

    return Question(
      id: id,
      subCategory: subCategory,
      prompt: 'Wie viel Prozent sind ${GeneratorSupport.integer(value)} '
          'von ${GeneratorSupport.integer(base)}?',
      answer: GeneratorSupport.count(percent, unit: '%'),
      explanation: 'Prozentsatz = Prozentwert · 100 : Grundwert. '
          'Also ${GeneratorSupport.integer(value)} · 100 : '
          '${GeneratorSupport.integer(base)} = '
          '${GeneratorSupport.integer(value * 100)} : '
          '${GeneratorSupport.integer(base)} = $percent %.',
      difficulty: difficulty,
    );
  }

  /// W sind p % von welcher Zahl?
  Question _baseValue(Random random, Difficulty difficulty, String id) {
    final (minBase, maxBase) = switch (difficulty) {
      Difficulty.easy => (200, 1500),
      Difficulty.medium => (300, 6000),
      Difficulty.hard => (900, 20000),
    };

    // Grundwert als Vielfaches von 100: dann ist auch der Wert für 1 %
    // ganzzahlig und der Lösungsweg bleibt sauber.
    final base = GeneratorSupport.multipleBetween(random, minBase, maxBase, 100);
    final percent = GeneratorSupport.multipleBetween(random, 5, 90, 5);
    final value = base * percent ~/ 100;
    final onePercent = base ~/ 100;

    return Question(
      id: id,
      subCategory: subCategory,
      prompt: '${GeneratorSupport.integer(value)} entsprechen $percent %.\n'
          'Wie groß ist der Grundwert (100 %)?',
      answer: GeneratorSupport.count(base),
      explanation: '1 % sind ${GeneratorSupport.integer(value)} : $percent = '
          '${GeneratorSupport.integer(onePercent)}. '
          '100 % sind also ${GeneratorSupport.integer(onePercent)} · 100 = '
          '${GeneratorSupport.integer(base)}.',
      difficulty: difficulty,
    );
  }

  /// Preis wird um p % gesenkt oder erhöht.
  Question _priceChange(Random random, Difficulty difficulty, String id) {
    final (minPrice, maxPrice) = switch (difficulty) {
      Difficulty.easy => (20, 200),
      Difficulty.medium => (40, 900),
      Difficulty.hard => (120, 4500),
    };

    // Ganze Euro als Ausgangspreis: p % davon ergibt immer volle Cent.
    final euros = GeneratorSupport.between(random, minPrice, maxPrice);
    final percent = GeneratorSupport.multipleBetween(random, 5, 45, 5);
    final isDiscount = random.nextBool();

    final baseCents = euros * 100;
    final changeCents = euros * percent;
    final resultCents =
        isDiscount ? baseCents - changeCents : baseCents + changeCents;

    final verb = isDiscount ? 'gesenkt' : 'erhöht';
    final operator = isDiscount ? '−' : '+';

    return Question(
      id: id,
      subCategory: subCategory,
      prompt: 'Ein Artikel kostet ${GeneratorSupport.euro(baseCents)}. '
          'Der Preis wird um $percent % $verb.\n'
          'Wie hoch ist der neue Preis?',
      answer: GeneratorSupport.money(resultCents),
      explanation: '$percent % von ${GeneratorSupport.euro(baseCents)} sind '
          '${GeneratorSupport.euro(changeCents)}. '
          'Neuer Preis: ${GeneratorSupport.euro(baseCents)} $operator '
          '${GeneratorSupport.euro(changeCents)} = '
          '${GeneratorSupport.euro(resultCents)}.',
      difficulty: difficulty,
    );
  }

  /// Vermehrter Grundwert: Vom erhöhten Preis auf den Ausgangspreis schließen.
  Question _reversePercentage(Random random, Difficulty difficulty, String id) {
    final (minPrice, maxPrice) = switch (difficulty) {
      Difficulty.easy => (20, 150),
      Difficulty.medium => (40, 600),
      Difficulty.hard => (100, 2500),
    };

    final percent = GeneratorSupport.pick(random, _reverseSteps.keys.toList());
    final step = _reverseSteps[percent]!;

    final original =
        GeneratorSupport.multipleBetween(random, minPrice, maxPrice, step);
    final increasedCents = original * (100 + percent);
    final factor = (100 + percent) / 100;

    return Question(
      id: id,
      subCategory: subCategory,
      prompt: 'Nach einer Erhöhung um $percent % kostet ein Ticket '
          '${GeneratorSupport.euro(increasedCents)}.\n'
          'Wie hoch war der ursprüngliche Preis?',
      answer: GeneratorSupport.money(original * 100),
      explanation: 'Der neue Preis entspricht ${100 + percent} % des alten, '
          'also dem ${GeneratorSupport.decimal(factor, 2)}-fachen. '
          'Rückwärts: ${GeneratorSupport.euro(increasedCents)} : '
          '${GeneratorSupport.decimal(factor, 2)} = '
          '${GeneratorSupport.euro(original * 100)}. '
          'Der häufige Fehler ist, vom neuen Preis einfach $percent % '
          'abzuziehen.',
      difficulty: difficulty,
    );
  }
}
