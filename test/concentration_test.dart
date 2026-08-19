import 'dart:math';

import 'package:einstellungstest_trainer/data/generators/math_question_factory.dart';
import 'package:einstellungstest_trainer/models/figure.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/strike_out_test.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Durchstreichtest', () {
    test('jede Zeile enthält genau den vorgesehenen Anteil an Zielen', () {
      final rows = const StrikeOutBuilder().build(
        rows: 12,
        perRow: 20,
        random: Random(1),
      );

      expect(rows, hasLength(12));
      for (final row in rows) {
        expect(row.symbols, hasLength(20));
        expect(row.targetCount, (20 * StrikeOutBuilder.targetShare).round());
      }
    });

    test('Ablenker sehen dem Ziel ähnlich, sind aber keines', () {
      final rows = const StrikeOutBuilder().build(
        rows: 8,
        perRow: 20,
        random: Random(2),
      );

      for (final row in rows) {
        for (final symbol in row.symbols) {
          expect(['d', 'p'], contains(symbol.letter));
          expect(symbol.marks, inInclusiveRange(1, 4));
          // Nur "d" mit genau zwei Strichen ist ein Ziel.
          expect(
            symbol.isTarget,
            symbol.letter == 'd' && symbol.marks == 2,
          );
        }
      }
    });

    test('die Auswertung trennt Fehler von Auslassungen', () {
      const result = StrikeResult(
        processed: 100,
        hits: 36,
        wrongTaps: 3,
        missed: 4,
        duration: Duration(seconds: 60),
      );

      expect(result.errors, 7);
      expect(result.score, 93);
      expect(result.errorRate, closeTo(0.07, 1e-9));
      expect(result.pace, closeTo(100, 0.001));
    });

    test('wer kaum etwas bearbeitet, bekommt kein Lob', () {
      const lazy = StrikeResult(
        processed: 20,
        hits: 8,
        wrongTaps: 0,
        missed: 0,
        duration: Duration(seconds: 100),
      );

      expect(lazy.errorRate, 0);
      expect(lazy.verdict, contains('Zu wenig'));
    });

    test('Hast wird benannt', () {
      const hasty = StrikeResult(
        processed: 200,
        hits: 60,
        wrongTaps: 10,
        missed: 20,
        duration: Duration(seconds: 100),
      );

      expect(hasty.verdict, contains('hastig'));
    });

    test('eine leere Auswertung rechnet nicht durch null', () {
      const nothing = StrikeResult(
        processed: 0,
        hits: 0,
        wrongTaps: 0,
        missed: 0,
        duration: Duration.zero,
      );

      expect(nothing.errorRate, 0);
      expect(nothing.pace, 0);
    });
  });

  group('Konzentrationsaufgaben', () {
    test('Zählaufgaben nennen die Trefferzahl exakt', () {
      final factory = MathQuestionFactory(random: Random(3));

      for (var run = 0; run < 60; run++) {
        final question = factory.next(SubCategory.counting);
        final format = question.answer as NumericInput;

        // Die Fläche steht im Aufgabentext – nachzählen muss die Lösung
        // bestätigen.
        final target = RegExp('"(.)"').firstMatch(question.prompt)!.group(1)!;
        final field = question.prompt.split('\n\n').last;
        final actual = field.split('').where((sign) => sign == target).length;

        expect(format.correctValue, actual.toDouble(), reason: question.id);
      }
    });

    test('beim Reihenvergleich stimmt genau eine Reihe überein', () {
      final factory = MathQuestionFactory(random: Random(4));

      for (var run = 0; run < 60; run++) {
        final question = factory.next(SubCategory.comparison);
        final format = question.answer as MultipleChoice;
        final reference = question.prompt.split('\n\n').last;

        expect(format.options[format.correctIndex], reference);
        expect(
          format.options.where((option) => option == reference),
          hasLength(1),
          reason: question.id,
        );
      }
    });
  });

  group('Formenaufgaben', () {
    test('jede Aufgabe hat gezeichnete Antwortmöglichkeiten', () {
      final factory = MathQuestionFactory(random: Random(5));

      for (var run = 0; run < 80; run++) {
        final question = factory.next(SubCategory.shapes);
        final format = question.answer as MultipleChoice;

        expect(format.optionFigures, isNotNull, reason: question.id);
        expect(format.optionFigures, hasLength(format.options.length));
        // Die Beschreibungen sind eindeutig – sonst waere die Aufgabe nicht
        // entscheidbar.
        expect(format.options.toSet().length, format.options.length);
      }
    });

    test('eine Zelle fasst höchstens sechs Formen', () {
      final factory = MathQuestionFactory(random: Random(6));

      for (var run = 0; run < 120; run++) {
        final question = factory.next(SubCategory.shapes);
        final cells = <FigureCell>[
          ...?question.figures,
          ...?(question.answer as MultipleChoice).optionFigures,
        ];

        for (final cell in cells) {
          expect(cell.count, inInclusiveRange(1, 6));
        }
      }
    });

    test('das Mischen der Optionen zieht die Figuren mit', () {
      const format = MultipleChoice(
        options: ['a', 'b', 'c'],
        correctIndex: 0,
        optionFigures: [
          FigureCell(shape: FigureShape.circle),
          FigureCell(shape: FigureShape.square),
          FigureCell(shape: FigureShape.star),
        ],
      );

      final shuffled = format.reordered([2, 0, 1]);

      expect(shuffled.options, ['c', 'a', 'b']);
      expect(shuffled.correctIndex, 1);
      expect(
        shuffled.optionFigures!.map((cell) => cell.shape),
        [FigureShape.star, FigureShape.circle, FigureShape.square],
      );
    });
  });
}
