import 'dart:math';

import 'package:einstellungstest_trainer/data/generators/math_question_factory.dart';
import 'package:einstellungstest_trainer/data/question_validation.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rechnet einen Grundrechen-Aufgabentext unabhängig vom Generator nach.
///
/// Damit prüft der Test nicht nur, ob der Generator in sich stimmig ist,
/// sondern ob die angegebene Lösung tatsächlich zur gestellten Aufgabe passt.
/// Unterstützt die Formen, die [ArithmeticGenerator] erzeugt:
/// `a + b − c`, `a · b`, `a : b`, `a : b + c · d` und `(−a) + b − (−c)`.
num evaluateArithmetic(String prompt) {
  final normalized = prompt
      .replaceAll('= ?', '')
      .replaceAll('−', '-')
      .replaceAll('(', ' ')
      .replaceAll(')', ' ')
      // Tausenderpunkte entfernen – in diesen Aufgaben gibt es keine Dezimalen.
      .replaceAll('.', '');

  final tokens = RegExp(r'-?\d+|[+\-·:]')
      .allMatches(normalized)
      .map((match) => match.group(0)!)
      .toList();

  expect(tokens, isNotEmpty, reason: 'Konnte "$prompt" nicht zerlegen');

  // Erst Punkt vor Strich auflösen.
  final reduced = <String>[];
  for (var index = 0; index < tokens.length; index++) {
    final token = tokens[index];
    if (token == '·' || token == ':') {
      final left = num.parse(reduced.removeLast());
      final right = num.parse(tokens[++index]);
      reduced.add(
        (token == '·' ? left * right : left / right).toString(),
      );
    } else {
      reduced.add(token);
    }
  }

  // Dann von links nach rechts addieren und subtrahieren.
  var result = num.parse(reduced.first);
  for (var index = 1; index < reduced.length; index += 2) {
    final operator = reduced[index];
    final operand = num.parse(reduced[index + 1]);
    result = operator == '+' ? result + operand : result - operand;
  }
  return result;
}

/// Die generierten Themen des Moduls Mathematik.
final List<SubCategory> mathTopics = MathQuestionFactory.supportedSubCategories
    .where((topic) => topic.module == TrainingModule.math)
    .toList();

void main() {
  group('Qualitätssicherung über alle Unterkategorien', () {
    test('jede generierte Aufgabe besteht die Validierung', () {
      final factory = MathQuestionFactory(random: Random(1));

      for (final subCategory in MathQuestionFactory.supportedSubCategories) {
        for (final difficulty in Difficulty.values) {
          for (var run = 0; run < 300; run++) {
            final question = factory.next(subCategory, difficulty: difficulty);
            final problems = validateQuestion(question);

            expect(
              problems,
              isEmpty,
              reason: '${subCategory.label} / ${difficulty.label}: '
                  '${problems.join('; ')}\n${question.prompt}',
            );
          }
        }
      }
    });

    test('Mathematik wird durchgaengig als Zahleneingabe gestellt', () {
      final factory = MathQuestionFactory(random: Random(2));

      // Die Fabrik erzeugt inzwischen auch Formen und Konzentration; die
      // Zahleneingabe ist eine Eigenschaft der Mathematik, nicht der Fabrik.
      for (final question in factory.generate(
        count: 400,
        subCategories: mathTopics,
      )) {
        expect(question.isNumericInput, isTrue, reason: question.id);
        expect(question.module, TrainingModule.math);
      }
    });

    test('Geldaufgaben rechnen centgenau, Stückzahlen ganzzahlig', () {
      final factory = MathQuestionFactory(random: Random(3));

      for (final question in factory.generate(
        count: 600,
        subCategories: mathTopics,
      )) {
        final format = question.answer as NumericInput;

        if (format.unit == '€') {
          expect(format.decimals, 2, reason: question.id);
          expect(format.tolerance, closeTo(0.01, 1e-9), reason: question.id);
        } else if (format.decimals == 0) {
          expect(
            format.correctValue,
            format.correctValue.roundToDouble(),
            reason: '${question.id} verspricht eine ganze Zahl, '
                'liefert aber ${format.correctValue}',
          );
        }
      }
    });

    test('Ergebnisse sind nie unplausibel groß oder unendlich', () {
      final factory = MathQuestionFactory(random: Random(4));

      for (final question in factory.generate(
        count: 600,
        subCategories: mathTopics,
      )) {
        final value = (question.answer as NumericInput).correctValue;

        expect(value.isFinite, isTrue, reason: question.id);
        expect(value.abs(), lessThan(1000000), reason: question.id);
      }
    });

    test('IDs sind innerhalb einer Fabrik eindeutig', () {
      final factory = MathQuestionFactory(random: Random(5));
      final ids = factory.generate(count: 500).map((q) => q.id).toList();

      expect(ids.toSet().length, ids.length);
    });
  });

  group('Grundrechenarten', () {
    test('die angegebene Lösung stimmt mit der gestellten Aufgabe überein', () {
      final factory = MathQuestionFactory(random: Random(11));

      for (final difficulty in Difficulty.values) {
        for (var run = 0; run < 200; run++) {
          final question = factory.next(
            SubCategory.arithmetic,
            difficulty: difficulty,
          );
          final expected = evaluateArithmetic(question.prompt);
          final actual = (question.answer as NumericInput).correctValue;

          expect(
            actual,
            closeTo(expected.toDouble(), 1e-9),
            reason: '${question.prompt} → Generator sagt $actual, '
                'nachgerechnet ergibt $expected',
          );
        }
      }
    });

    test('Divisionen gehen immer ohne Rest auf', () {
      final factory = MathQuestionFactory(random: Random(12));

      for (var run = 0; run < 500; run++) {
        final question = factory.next(SubCategory.arithmetic);
        if (!question.prompt.contains(':')) continue;

        final value = (question.answer as NumericInput).correctValue;
        expect(value, value.roundToDouble(), reason: question.prompt);
      }
    });

    test('alle Aufgabentypen kommen tatsächlich vor', () {
      final factory = MathQuestionFactory(random: Random(13));
      final prompts = [
        for (var run = 0; run < 300; run++)
          factory.next(SubCategory.arithmetic).prompt,
      ];

      expect(prompts.where((p) => p.contains('·')), isNotEmpty);
      expect(prompts.where((p) => p.contains(':')), isNotEmpty);
      expect(prompts.where((p) => p.contains('(−')), isNotEmpty);
      expect(
        prompts.where((p) => p.contains(':') && p.contains('·')),
        isNotEmpty,
      );
    });
  });

  group('Prozentrechnung', () {
    test('Prozentwert-Aufgaben sind rechnerisch korrekt', () {
      final factory = MathQuestionFactory(random: Random(21));
      final pattern = RegExp(r'Wie viel sind (\d+) % von ([\d.]+)\?');
      var checked = 0;

      for (var run = 0; run < 400; run++) {
        final question = factory.next(SubCategory.percentage);
        final match = pattern.firstMatch(question.prompt);
        if (match == null) continue;

        final percent = int.parse(match.group(1)!);
        final base = int.parse(match.group(2)!.replaceAll('.', ''));
        final expected = base * percent / 100;

        expect(
          (question.answer as NumericInput).correctValue,
          closeTo(expected, 1e-9),
          reason: question.prompt,
        );
        checked++;
      }

      expect(checked, greaterThan(0), reason: 'Variante kam nie vor');
    });

    test('Prozentsatz-Aufgaben sind rechnerisch korrekt', () {
      final factory = MathQuestionFactory(random: Random(22));
      final pattern =
          RegExp(r'Wie viel Prozent sind ([\d.]+) von ([\d.]+)\?');
      var checked = 0;

      for (var run = 0; run < 400; run++) {
        final question = factory.next(SubCategory.percentage);
        final match = pattern.firstMatch(question.prompt);
        if (match == null) continue;

        final value = int.parse(match.group(1)!.replaceAll('.', ''));
        final base = int.parse(match.group(2)!.replaceAll('.', ''));
        final expected = value * 100 / base;

        expect(
          (question.answer as NumericInput).correctValue,
          closeTo(expected, 1e-9),
          reason: question.prompt,
        );
        checked++;
      }

      expect(checked, greaterThan(0), reason: 'Variante kam nie vor');
    });
  });

  group('Textaufgaben', () {
    test('Geschwindigkeitsaufgaben sind rechnerisch korrekt', () {
      final factory = MathQuestionFactory(random: Random(31));
      final pattern = RegExp(
        r'legt ([\d.]+) km in ([\d,]+) Stunden zurück',
      );
      var checked = 0;

      for (var run = 0; run < 400; run++) {
        final question = factory.next(SubCategory.wordProblems);
        final match = pattern.firstMatch(question.prompt);
        if (match == null) continue;

        final distance = int.parse(match.group(1)!.replaceAll('.', ''));
        final hours = double.parse(match.group(2)!.replaceAll(',', '.'));

        expect(
          (question.answer as NumericInput).correctValue,
          closeTo(distance / hours, 1e-9),
          reason: question.prompt,
        );
        checked++;
      }

      expect(checked, greaterThan(0), reason: 'Variante kam nie vor');
    });

    test('Einkaufsaufgaben nennen einen Gesamtpreis über null', () {
      final factory = MathQuestionFactory(random: Random(32));

      for (var run = 0; run < 300; run++) {
        final question = factory.next(SubCategory.wordProblems);
        expect(
          (question.answer as NumericInput).correctValue,
          greaterThan(0),
          reason: question.prompt,
        );
      }
    });
  });

  group('Steuerung der Fabrik', () {
    test('die gewünschte Schwierigkeit wird durchgereicht', () {
      final factory = MathQuestionFactory(random: Random(41));

      for (final difficulty in Difficulty.values) {
        for (final subCategory in MathQuestionFactory.supportedSubCategories) {
          final question =
              factory.next(subCategory, difficulty: difficulty);
          expect(question.difficulty, difficulty);
        }
      }
    });

    test('ohne Vorgabe entsteht eine Mischung aller Schwierigkeitsgrade', () {
      final factory = MathQuestionFactory(random: Random(42));
      final levels =
          factory.generate(count: 300).map((q) => q.difficulty).toSet();

      expect(levels, containsAll(Difficulty.values));
    });

    test('generate verteilt über die gewünschten Unterkategorien', () {
      final factory = MathQuestionFactory(random: Random(43));

      final questions = factory.generate(
        count: 40,
        subCategories: [SubCategory.ruleOfThree, SubCategory.percentage],
      );

      expect(
        questions.map((q) => q.subCategory).toSet(),
        {SubCategory.ruleOfThree, SubCategory.percentage},
      );
    });

    test('ohne Einschränkung kommen alle Unterkategorien vor', () {
      final factory = MathQuestionFactory(random: Random(44));
      final used = factory.generate(count: 80).map((q) => q.subCategory).toSet();

      expect(used, containsAll(MathQuestionFactory.supportedSubCategories));
    });

    test('derselbe Seed liefert dieselben Aufgaben', () {
      final first = MathQuestionFactory(random: Random(99)).generate(count: 50);
      final second = MathQuestionFactory(random: Random(99)).generate(count: 50);

      expect(
        first.map((q) => q.prompt).toList(),
        second.map((q) => q.prompt).toList(),
      );
    });

    test('eine nicht generierbare Unterkategorie wird abgelehnt', () {
      final factory = MathQuestionFactory(random: Random(45));

      expect(
        () => factory.next(SubCategory.spelling),
        throwsArgumentError,
      );
      expect(
        () => factory.generate(count: 5, subCategories: [SubCategory.spelling]),
        throwsArgumentError,
      );
    });

    test('eine Anforderung von null Aufgaben liefert eine leere Liste', () {
      final factory = MathQuestionFactory(random: Random(46));

      expect(factory.generate(count: 0), isEmpty);
    });
  });
}
