import 'dart:math';

import 'package:einstellungstest_trainer/data/generators/question_generator.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';

/// Textaufgaben mit Alltagsbezug: Einkauf, Rabatt, Zeit- und
/// Weg-Berechnungen sowie Arbeitszeit.
///
/// Geld wird durchgängig in Cent gerechnet. Bei Zeit/Weg werden die Größen so
/// gewählt, dass Strecke und Geschwindigkeit ganzzahlig bleiben, auch wenn die
/// Fahrzeit halbe Stunden enthält.
class WordProblemGenerator extends QuestionGenerator {
  const WordProblemGenerator();

  @override
  SubCategory get subCategory => SubCategory.wordProblems;

  /// Warenkorb-Bausteine: Name im Plural plus plausibler Preisrahmen in Cent.
  static const List<(String, int, int)> _goods = [
    ('Packungen Kaffee', 400, 900),
    ('Flaschen Saft', 120, 320),
    ('Kilogramm Äpfel', 150, 400),
    ('Päckchen Butter', 180, 350),
    ('Gläser Marmelade', 200, 450),
    ('Beutel Reis', 160, 380),
    ('Dosen Suppe', 100, 260),
    ('Tafeln Schokolade', 90, 240),
  ];

  static const List<String> _vehicles = [
    'Ein Zug',
    'Ein Reisebus',
    'Ein Lieferwagen',
    'Ein Pkw',
  ];

  static const List<(String, String)> _tasks = [
    ('Eine Sachbearbeiterin', 'Vorgänge'),
    ('Ein Handwerker', 'Fenster'),
    ('Ein Prüfer', 'Bauteile'),
    ('Eine Technikerin', 'Geräte'),
  ];

  @override
  Question generate(Random random, Difficulty difficulty, String id) {
    return switch (random.nextInt(5)) {
      0 => _shopping(random, difficulty, id),
      1 => _discount(random, difficulty, id),
      2 => _speed(random, difficulty, id),
      3 => _distance(random, difficulty, id),
      _ => _workRate(random, difficulty, id),
    };
  }

  /// Einkauf: zwei Positionen, Gesamtpreis gesucht.
  Question _shopping(Random random, Difficulty difficulty, String id) {
    final maxQuantity = switch (difficulty) {
      Difficulty.easy => 4,
      Difficulty.medium => 7,
      Difficulty.hard => 12,
    };

    final firstIndex = random.nextInt(_goods.length);
    var secondIndex = random.nextInt(_goods.length);
    if (secondIndex == firstIndex) {
      secondIndex = (secondIndex + 1) % _goods.length;
    }

    final (firstName, firstMin, firstMax) = _goods[firstIndex];
    final (secondName, secondMin, secondMax) = _goods[secondIndex];

    final firstPrice =
        GeneratorSupport.multipleBetween(random, firstMin, firstMax, 5);
    final secondPrice =
        GeneratorSupport.multipleBetween(random, secondMin, secondMax, 5);
    final firstCount = GeneratorSupport.between(random, 2, maxQuantity);
    final secondCount = GeneratorSupport.between(random, 2, maxQuantity);

    final firstSum = firstCount * firstPrice;
    final secondSum = secondCount * secondPrice;
    final total = firstSum + secondSum;

    return Question(
      id: id,
      subCategory: subCategory,
      prompt: 'Sie kaufen $firstCount $firstName zu je '
          '${GeneratorSupport.euro(firstPrice)} und $secondCount $secondName '
          'zu je ${GeneratorSupport.euro(secondPrice)}.\n'
          'Wie viel kostet der Einkauf insgesamt?',
      answer: GeneratorSupport.money(total),
      explanation: '$firstCount · ${GeneratorSupport.euro(firstPrice)} = '
          '${GeneratorSupport.euro(firstSum)}. '
          '$secondCount · ${GeneratorSupport.euro(secondPrice)} = '
          '${GeneratorSupport.euro(secondSum)}. '
          'Zusammen: ${GeneratorSupport.euro(firstSum)} + '
          '${GeneratorSupport.euro(secondSum)} = '
          '${GeneratorSupport.euro(total)}.',
      difficulty: difficulty,
    );
  }

  /// Rabatt – bei hoher Schwierigkeit zusätzlich Skonto auf den Rabattpreis.
  Question _discount(Random random, Difficulty difficulty, String id) {
    final (minPrice, maxPrice) = switch (difficulty) {
      Difficulty.easy => (40, 200),
      Difficulty.medium => (100, 900),
      Difficulty.hard => (200, 2400),
    };

    // Vielfaches von 20 Euro: dann bleibt auch die zweite Stufe centgenau.
    final euros =
        GeneratorSupport.multipleBetween(random, minPrice, maxPrice, 20);
    final discount = GeneratorSupport.multipleBetween(random, 10, 40, 5);

    final baseCents = euros * 100;
    final afterDiscount = baseCents - euros * discount;

    if (difficulty != Difficulty.hard) {
      return Question(
        id: id,
        subCategory: subCategory,
        prompt: 'Ein Gerät kostet ${GeneratorSupport.euro(baseCents)}. '
            'Im Angebot gibt es $discount % Rabatt.\n'
            'Wie hoch ist der Angebotspreis?',
        answer: GeneratorSupport.money(afterDiscount),
        explanation: '$discount % von ${GeneratorSupport.euro(baseCents)} sind '
            '${GeneratorSupport.euro(euros * discount)}. '
            'Angebotspreis: ${GeneratorSupport.euro(baseCents)} − '
            '${GeneratorSupport.euro(euros * discount)} = '
            '${GeneratorSupport.euro(afterDiscount)}.',
        difficulty: difficulty,
      );
    }

    final cashDiscount = GeneratorSupport.pick(random, [2, 5, 10]);
    final finalCents = afterDiscount * (100 - cashDiscount) ~/ 100;

    return Question(
      id: id,
      subCategory: subCategory,
      prompt: 'Ein Gerät kostet ${GeneratorSupport.euro(baseCents)}. '
          'Es gibt $discount % Rabatt und auf den Rabattpreis zusätzlich '
          '$cashDiscount % Skonto.\n'
          'Wie hoch ist der Endpreis?',
      answer: GeneratorSupport.money(finalCents),
      explanation: 'Erst der Rabatt: ${GeneratorSupport.euro(baseCents)} − '
          '$discount % = ${GeneratorSupport.euro(afterDiscount)}. '
          'Dann das Skonto darauf: ${GeneratorSupport.euro(afterDiscount)} · '
          '${GeneratorSupport.decimal((100 - cashDiscount) / 100, 2)} = '
          '${GeneratorSupport.euro(finalCents)}. '
          'Die beiden Prozentsätze dürfen nicht addiert werden.',
      difficulty: difficulty,
    );
  }

  /// Zeit/Weg: Durchschnittsgeschwindigkeit gesucht.
  Question _speed(Random random, Difficulty difficulty, String id) {
    final (minSpeed, maxSpeed) = switch (difficulty) {
      Difficulty.easy => (40, 90),
      Difficulty.medium => (50, 130),
      Difficulty.hard => (60, 180),
    };

    // Gerade Geschwindigkeit und halbe Stunden ergeben zusammen immer eine
    // ganzzahlige Strecke.
    final speed = GeneratorSupport.multipleBetween(random, minSpeed, maxSpeed, 2);
    final halfHours = GeneratorSupport.between(random, 3, 9);
    final hours = halfHours / 2;
    final distance = speed * halfHours ~/ 2;

    return Question(
      id: id,
      subCategory: subCategory,
      prompt: '${GeneratorSupport.pick(random, _vehicles)} legt '
          '${GeneratorSupport.integer(distance)} km in '
          '${GeneratorSupport.hours(hours)} Stunden zurück.\n'
          'Wie hoch ist die Durchschnittsgeschwindigkeit?',
      answer: GeneratorSupport.count(speed, unit: 'km/h'),
      explanation: 'Geschwindigkeit = Strecke : Zeit. '
          'Also ${GeneratorSupport.integer(distance)} km : '
          '${GeneratorSupport.hours(hours)} h = '
          '${GeneratorSupport.integer(speed)} km/h.',
      difficulty: difficulty,
    );
  }

  /// Zeit/Weg: zurückgelegte Strecke gesucht.
  Question _distance(Random random, Difficulty difficulty, String id) {
    final (minSpeed, maxSpeed) = switch (difficulty) {
      Difficulty.easy => (40, 90),
      Difficulty.medium => (50, 130),
      Difficulty.hard => (60, 180),
    };

    final speed = GeneratorSupport.multipleBetween(random, minSpeed, maxSpeed, 2);
    final halfHours = GeneratorSupport.between(random, 3, 11);
    final hours = halfHours / 2;
    final distance = speed * halfHours ~/ 2;

    return Question(
      id: id,
      subCategory: subCategory,
      prompt: '${GeneratorSupport.pick(random, _vehicles)} fährt '
          '${GeneratorSupport.hours(hours)} Stunden lang mit durchschnittlich '
          '${GeneratorSupport.integer(speed)} km/h.\n'
          'Welche Strecke legt es zurück?',
      answer: GeneratorSupport.count(distance, unit: 'km'),
      explanation: 'Strecke = Geschwindigkeit · Zeit. '
          'Also ${GeneratorSupport.integer(speed)} km/h · '
          '${GeneratorSupport.hours(hours)} h = '
          '${GeneratorSupport.integer(distance)} km.',
      difficulty: difficulty,
    );
  }

  /// Arbeitszeit: Stückzahl in einer gegebenen Zeitspanne.
  Question _workRate(Random random, Difficulty difficulty, String id) {
    final minutesPerPiece = switch (difficulty) {
      Difficulty.easy => GeneratorSupport.pick(random, [10, 15, 20, 30]),
      Difficulty.medium => GeneratorSupport.pick(random, [12, 20, 25, 45]),
      Difficulty.hard => GeneratorSupport.pick(random, [35, 40, 45, 50]),
    };

    // Nur Stundenzahlen zulassen, bei denen die Stückzahl ganzzahlig aufgeht.
    final validHours = [
      for (var hours = 2; hours <= 9; hours++)
        if ((hours * 60) % minutesPerPiece == 0) hours,
    ];
    final hours = GeneratorSupport.pick(random, validHours);

    final minutes = hours * 60;
    final pieces = minutes ~/ minutesPerPiece;
    final (worker, unit) = GeneratorSupport.pick(random, _tasks);

    return Question(
      id: id,
      subCategory: subCategory,
      prompt: '$worker benötigt $minutesPerPiece Minuten pro Vorgang.\n'
          'Wie viele $unit schafft sie oder er in $hours Stunden?',
      answer: GeneratorSupport.count(pieces, unit: unit),
      explanation: '$hours Stunden sind $hours · 60 = '
          '${GeneratorSupport.integer(minutes)} Minuten. '
          '${GeneratorSupport.integer(minutes)} : $minutesPerPiece = '
          '${GeneratorSupport.integer(pieces)} $unit.',
      difficulty: difficulty,
    );
  }
}
