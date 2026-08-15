import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  group('Kategorie und Unterkategorie', () {
    test('die Kategorie ergibt sich aus der Unterkategorie', () {
      final question = numericQuestion(subCategory: SubCategory.percentage);

      expect(question.module, TrainingModule.math);
      expect(question.subCategory.label, 'Prozentrechnung');
    });

    test('jede Unterkategorie ist genau einem Modul zugeordnet', () {
      for (final module in TrainingModule.values) {
        for (final subCategory in SubCategory.of(module)) {
          expect(subCategory.module, module);
        }
      }
    });

    test('Unterkategorien lassen sich über ihre stabile ID wiederfinden', () {
      for (final subCategory in SubCategory.values) {
        expect(SubCategory.tryFromId(subCategory.id), subCategory);
      }
      expect(SubCategory.tryFromId('gibt_es_nicht'), isNull);
    });
  });

  group('Multiple Choice', () {
    test('erkennt die richtige und die falsche Option', () {
      final question = choiceQuestion(correctIndex: 1);

      expect(question.isCorrect(const ChoiceResponse(1)), isTrue);
      expect(question.isCorrect(const ChoiceResponse(0)), isFalse);
      expect(question.isCorrect(const ChoiceResponse(2)), isFalse);
    });

    test('meldet das eigene Antwortformat', () {
      final question = choiceQuestion();

      expect(question.isMultipleChoice, isTrue);
      expect(question.isNumericInput, isFalse);
    });

    test('Umsortieren zieht den Lösungsindex korrekt mit', () {
      const format = MultipleChoice(
        options: ['null', 'eins', 'zwei'],
        correctIndex: 1,
      );

      final reordered = format.reordered([2, 1, 0]);

      expect(reordered.options, ['zwei', 'eins', 'null']);
      expect(reordered.correctIndex, 1);
      expect(reordered.correctOption, 'eins');
    });

    test('Umsortieren erhält die richtige Antwort bei jeder Reihenfolge', () {
      const format = MultipleChoice(
        options: ['a', 'b', 'c'],
        correctIndex: 2,
      );

      for (final order in [
        [0, 1, 2],
        [0, 2, 1],
        [1, 0, 2],
        [1, 2, 0],
        [2, 0, 1],
        [2, 1, 0],
      ]) {
        final reordered = format.reordered(order);
        expect(reordered.correctOption, 'c', reason: 'Reihenfolge $order');
      }
    });

    test('zeigt Musterlösung und gegebene Antwort als Text', () {
      final question = choiceQuestion(
        options: const ['rot', 'grün', 'blau'],
        correctIndex: 2,
      );

      expect(question.correctAnswerText, 'blau');
      expect(question.describeResponse(const ChoiceResponse(0)), 'rot');
    });
  });

  group('Zahleneingabe', () {
    test('akzeptiert nur den exakten Wert, wenn keine Toleranz gesetzt ist', () {
      final question = numericQuestion(correctValue: 408);

      expect(
        question.isCorrect(
          const NumericResponse(value: 408, input: '408'),
        ),
        isTrue,
      );
      expect(
        question.isCorrect(
          const NumericResponse(value: 407.99, input: '407,99'),
        ),
        isFalse,
      );
    });

    test('akzeptiert Werte innerhalb der Toleranz', () {
      final question = numericQuestion(correctValue: 793.80, tolerance: 0.01);

      expect(
        question.isCorrect(
          const NumericResponse(value: 793.80, input: '793,80'),
        ),
        isTrue,
      );
      expect(
        question.isCorrect(
          const NumericResponse(value: 793.79, input: '793,79'),
        ),
        isTrue,
      );
      expect(
        question.isCorrect(
          const NumericResponse(value: 793.5, input: '793,50'),
        ),
        isFalse,
      );
    });

    test('meldet das eigene Antwortformat', () {
      final question = numericQuestion();

      expect(question.isNumericInput, isTrue);
      expect(question.isMultipleChoice, isFalse);
    });

    test('formatiert die Musterlösung deutsch inklusive Einheit', () {
      expect(
        numericQuestion(correctValue: 408).correctAnswerText,
        '408',
      );
      expect(
        numericQuestion(correctValue: 2.4, decimals: 1).correctAnswerText,
        '2,4',
      );
      expect(
        numericQuestion(correctValue: 793.80, decimals: 2, unit: '€')
            .correctAnswerText,
        '793,80 €',
      );
    });

    test('zeigt die Eingabe mit Einheit in der Auswertung', () {
      final question = numericQuestion(correctValue: 84, unit: 'km/h');

      expect(
        question.describeResponse(
          const NumericResponse(value: 84, input: '84'),
        ),
        '84 km/h',
      );
    });
  });

  group('Eingabe einlesen', () {
    void expectsValue(String input, double expected) {
      final parsed = NumericResponse.tryParse(input);
      expect(parsed, isNotNull, reason: 'konnte "$input" nicht lesen');
      expect(parsed!.value, expected, reason: 'Eingabe "$input"');
    }

    test('liest ganze Zahlen', () {
      expectsValue('408', 408);
      expectsValue('  45 ', 45);
      expectsValue('-5', -5);
    });

    test('akzeptiert Komma und Punkt als Dezimaltrennzeichen', () {
      expectsValue('2,4', 2.4);
      expectsValue('2.4', 2.4);
      expectsValue('793,80', 793.8);
    });

    test('erkennt Tausendertrennung anhand des hinteren Trennzeichens', () {
      expectsValue('1.234,56', 1234.56);
      expectsValue('1,234.56', 1234.56);
    });

    test('ignoriert mitgetippte Einheiten und Leerzeichen', () {
      expectsValue('68 €', 68);
      expectsValue('18 %', 18);
      expectsValue('4 500', 4500);
    });

    test('behält die Roheingabe für die Auswertung', () {
      final parsed = NumericResponse.tryParse(' 793,80 € ');

      expect(parsed, isNotNull);
      expect(parsed!.input, '793,80 €');
      expect(parsed.value, 793.8);
    });

    test('gibt null zurück, wenn keine Zahl erkennbar ist', () {
      expect(NumericResponse.tryParse(''), isNull);
      expect(NumericResponse.tryParse('   '), isNull);
      expect(NumericResponse.tryParse('keine Ahnung'), isNull);
      expect(NumericResponse.tryParse('12abc'), isNull);
      expect(NumericResponse.tryParse('-'), isNull);
    });
  });

  group('Format und Antwort passen nicht zusammen', () {
    test('eine Zahleneingabe auf eine Auswahlaufgabe gilt als falsch', () {
      final question = choiceQuestion();

      expect(
        question.isCorrect(const NumericResponse(value: 1, input: '1')),
        isFalse,
      );
      expect(
        question.describeResponse(const NumericResponse(value: 1, input: '1')),
        '—',
      );
    });

    test('eine Auswahl auf eine Rechenaufgabe gilt als falsch', () {
      final question = numericQuestion(correctValue: 42);

      expect(question.isCorrect(const ChoiceResponse(0)), isFalse);
    });

    test('ein Optionsindex außerhalb des Bereichs wirft nicht', () {
      final question = choiceQuestion(options: const ['a', 'b']);

      expect(question.isCorrect(const ChoiceResponse(9)), isFalse);
      expect(question.describeResponse(const ChoiceResponse(9)), '—');
    });
  });

  test('correctResponse und wrongResponse liefern das erwartete Ergebnis', () {
    for (final question in [choiceQuestion(), numericQuestion()]) {
      expect(question.isCorrect(correctResponse(question)), isTrue);
      expect(question.isCorrect(wrongResponse(question)), isFalse);
    }
  });
}
