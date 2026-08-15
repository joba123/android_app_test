import 'dart:math';

import 'package:einstellungstest_trainer/data/generators/question_generator.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';

/// Grundrechenarten: Addition, Subtraktion, Multiplikation, Division,
/// Punkt-vor-Strich und Vorzeichenregeln.
///
/// Divisionen werden immer aus Quotient und Divisor aufgebaut, nie zufällig
/// geteilt – dadurch geht jede Aufgabe exakt auf.
class ArithmeticGenerator extends QuestionGenerator {
  const ArithmeticGenerator();

  @override
  SubCategory get subCategory => SubCategory.arithmetic;

  @override
  Question generate(Random random, Difficulty difficulty, String id) {
    return switch (random.nextInt(5)) {
      0 => _addSubtract(random, difficulty, id),
      1 => _multiply(random, difficulty, id),
      2 => _divide(random, difficulty, id),
      3 => _precedence(random, difficulty, id),
      _ => _signs(random, difficulty, id),
    };
  }

  /// a + b − c
  Question _addSubtract(Random random, Difficulty difficulty, String id) {
    final (minA, maxA, minB, maxB, maxC) = switch (difficulty) {
      Difficulty.easy => (20, 99, 10, 49, 19),
      Difficulty.medium => (100, 999, 50, 499, 199),
      Difficulty.hard => (1000, 9999, 500, 4999, 999),
    };

    final a = GeneratorSupport.between(random, minA, maxA);
    final b = GeneratorSupport.between(random, minB, maxB);
    // c bleibt kleiner als a, damit das Zwischenergebnis nicht negativ wird.
    final c = GeneratorSupport.between(random, 1, min(maxC, a - 1));

    final step = a + b;
    final result = step - c;

    return Question(
      id: id,
      subCategory: subCategory,
      prompt: '${GeneratorSupport.integer(a)} + ${GeneratorSupport.integer(b)} '
          '− ${GeneratorSupport.integer(c)} = ?',
      answer: GeneratorSupport.count(result),
      explanation: 'Von links nach rechts rechnen: '
          '${GeneratorSupport.integer(a)} + ${GeneratorSupport.integer(b)} '
          '= ${GeneratorSupport.integer(step)}. '
          'Dann ${GeneratorSupport.integer(step)} − '
          '${GeneratorSupport.integer(c)} = '
          '${GeneratorSupport.integer(result)}.',
      difficulty: difficulty,
    );
  }

  /// a · b, im Lösungsweg in Zehner und Einer zerlegt.
  Question _multiply(Random random, Difficulty difficulty, String id) {
    final (minA, maxA, minB, maxB) = switch (difficulty) {
      Difficulty.easy => (2, 9, 11, 29),
      Difficulty.medium => (11, 29, 11, 49),
      Difficulty.hard => (21, 99, 21, 99),
    };

    final a = GeneratorSupport.between(random, minA, maxA);
    final b = GeneratorSupport.between(random, minB, maxB);
    final result = a * b;

    final tens = (b ~/ 10) * 10;
    final ones = b % 10;

    final explanation = ones == 0
        ? '${GeneratorSupport.integer(a)} · ${GeneratorSupport.integer(b)} = '
            '${GeneratorSupport.integer(a)} · ${b ~/ 10} · 10 = '
            '${GeneratorSupport.integer(a * (b ~/ 10))} · 10 = '
            '${GeneratorSupport.integer(result)}.'
        : 'Zerlegen: ${GeneratorSupport.integer(a)} · '
            '${GeneratorSupport.integer(b)} = '
            '${GeneratorSupport.integer(a)} · ${GeneratorSupport.integer(tens)} '
            '+ ${GeneratorSupport.integer(a)} · $ones = '
            '${GeneratorSupport.integer(a * tens)} + '
            '${GeneratorSupport.integer(a * ones)} = '
            '${GeneratorSupport.integer(result)}.';

    return Question(
      id: id,
      subCategory: subCategory,
      prompt: '${GeneratorSupport.integer(a)} · '
          '${GeneratorSupport.integer(b)} = ?',
      answer: GeneratorSupport.count(result),
      explanation: explanation,
      difficulty: difficulty,
    );
  }

  /// dividend : divisor – aufgebaut aus Quotient und Divisor, geht also auf.
  Question _divide(Random random, Difficulty difficulty, String id) {
    final (minD, maxD, minQ, maxQ) = switch (difficulty) {
      Difficulty.easy => (2, 9, 3, 20),
      Difficulty.medium => (3, 12, 10, 50),
      Difficulty.hard => (11, 25, 12, 80),
    };

    final divisor = GeneratorSupport.between(random, minD, maxD);
    final quotient = GeneratorSupport.between(random, minQ, maxQ);
    final dividend = divisor * quotient;

    return Question(
      id: id,
      subCategory: subCategory,
      prompt: '${GeneratorSupport.integer(dividend)} : '
          '${GeneratorSupport.integer(divisor)} = ?',
      answer: GeneratorSupport.count(quotient),
      explanation: 'Gesucht ist die Zahl, die mit '
          '${GeneratorSupport.integer(divisor)} multipliziert '
          '${GeneratorSupport.integer(dividend)} ergibt: '
          '${GeneratorSupport.integer(divisor)} · '
          '${GeneratorSupport.integer(quotient)} = '
          '${GeneratorSupport.integer(dividend)}. '
          'Also ist das Ergebnis ${GeneratorSupport.integer(quotient)}.',
      difficulty: difficulty,
    );
  }

  /// a : b + c · d – prüft Punkt vor Strich.
  Question _precedence(Random random, Difficulty difficulty, String id) {
    final (minB, maxB, minQ, maxQ, minC, maxC, minD, maxD) = switch (difficulty) {
      Difficulty.easy => (2, 5, 2, 10, 2, 9, 2, 5),
      Difficulty.medium => (2, 9, 5, 15, 3, 12, 3, 9),
      Difficulty.hard => (4, 12, 8, 25, 6, 19, 4, 12),
    };

    final b = GeneratorSupport.between(random, minB, maxB);
    final quotient = GeneratorSupport.between(random, minQ, maxQ);
    final a = b * quotient;
    final c = GeneratorSupport.between(random, minC, maxC);
    final d = GeneratorSupport.between(random, minD, maxD);

    final product = c * d;
    final result = quotient + product;

    return Question(
      id: id,
      subCategory: subCategory,
      prompt: '${GeneratorSupport.integer(a)} : ${GeneratorSupport.integer(b)} '
          '+ ${GeneratorSupport.integer(c)} · '
          '${GeneratorSupport.integer(d)} = ?',
      answer: GeneratorSupport.count(result),
      explanation: 'Punkt vor Strich: '
          '${GeneratorSupport.integer(a)} : ${GeneratorSupport.integer(b)} = '
          '${GeneratorSupport.integer(quotient)} und '
          '${GeneratorSupport.integer(c)} · ${GeneratorSupport.integer(d)} = '
          '${GeneratorSupport.integer(product)}. '
          'Erst danach addieren: ${GeneratorSupport.integer(quotient)} + '
          '${GeneratorSupport.integer(product)} = '
          '${GeneratorSupport.integer(result)}.',
      difficulty: difficulty,
    );
  }

  /// (−a) + b − (−c) – prüft die Vorzeichenregeln.
  Question _signs(Random random, Difficulty difficulty, String id) {
    final (minA, maxA, minB, maxB, minC, maxC) = switch (difficulty) {
      Difficulty.easy => (5, 20, 10, 40, 2, 10),
      Difficulty.medium => (10, 60, 20, 90, 5, 30),
      Difficulty.hard => (20, 150, 50, 250, 10, 80),
    };

    final a = GeneratorSupport.between(random, minA, maxA);
    final b = GeneratorSupport.between(random, minB, maxB);
    final c = GeneratorSupport.between(random, minC, maxC);
    final result = -a + b + c;

    return Question(
      id: id,
      subCategory: subCategory,
      prompt: '(−${GeneratorSupport.integer(a)}) + '
          '${GeneratorSupport.integer(b)} − '
          '(−${GeneratorSupport.integer(c)}) = ?',
      answer: GeneratorSupport.count(result),
      explanation: 'Minus vor der Klammer dreht das Vorzeichen: '
          '−${GeneratorSupport.integer(a)} + ${GeneratorSupport.integer(b)} '
          '+ ${GeneratorSupport.integer(c)} = '
          '${GeneratorSupport.integer(result)}.',
      difficulty: difficulty,
    );
  }
}
