import 'package:einstellungstest_trainer/data/question_validation.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests für die Qualitätssicherung selbst.
///
/// Ein Validator, der nie anschlägt, ist wertlos – deshalb wird hier vor allem
/// geprüft, dass er kaputte Aufgaben auch wirklich erkennt.
void main() {
  Question build({
    String id = 'test_01',
    String prompt = 'Testfrage',
    String explanation = 'Testerklärung',
    required AnswerFormat answer,
  }) {
    return Question(
      id: id,
      subCategory: SubCategory.arithmetic,
      prompt: prompt,
      answer: answer,
      explanation: explanation,
    );
  }

  group('einwandfreie Aufgaben', () {
    test('Auswahlaufgabe wird durchgewinkt', () {
      final question = build(
        answer: const MultipleChoice(
          options: ['rot', 'grün', 'blau'],
          correctIndex: 1,
        ),
      );

      expect(validateQuestion(question), isEmpty);
    });

    test('Zahleneingabe mit Ergebnis im Lösungsweg wird durchgewinkt', () {
      final question = build(
        answer: const NumericInput(correctValue: 408),
        explanation: '17 · 24 = 408.',
      );

      expect(validateQuestion(question), isEmpty);
    });

    test('das Ergebnis darf im Lösungsweg gruppiert geschrieben sein', () {
      final question = build(
        answer: const NumericInput(correctValue: 4500),
        explanation: 'Drei Achtel von 12.000 sind 4.500.',
      );

      expect(validateQuestion(question), isEmpty);
    });

    test('Geldbeträge mit zwei Nachkommastellen werden erkannt', () {
      final question = build(
        answer: const NumericInput(
          correctValue: 793.80,
          tolerance: 0.01,
          decimals: 2,
          unit: '€',
        ),
        explanation: '810,00 € · 0,98 = 793,80 €.',
      );

      expect(validateQuestion(question), isEmpty);
    });
  });

  group('Pflichtfelder', () {
    test('leere ID fällt auf', () {
      final question = build(
        id: '   ',
        answer: const MultipleChoice(options: ['a', 'b'], correctIndex: 0),
      );

      expect(validateQuestion(question), contains('ID fehlt'));
    });

    test('leerer Aufgabentext fällt auf', () {
      final question = build(
        prompt: '',
        answer: const MultipleChoice(options: ['a', 'b'], correctIndex: 0),
      );

      expect(validateQuestion(question), contains('Aufgabentext fehlt'));
    });

    test('leerer Lösungsweg fällt auf', () {
      final question = build(
        explanation: '  ',
        answer: const MultipleChoice(options: ['a', 'b'], correctIndex: 0),
      );

      expect(validateQuestion(question), contains('Lösungsweg fehlt'));
    });
  });

  group('Auswahlaufgaben', () {
    test('eine einzige Option reicht nicht', () {
      final question = build(
        answer: const MultipleChoice(options: ['nur eine'], correctIndex: 0),
      );

      expect(validateQuestion(question), isNotEmpty);
    });

    test('ein Lösungsindex außerhalb der Optionen fällt auf', () {
      final question = build(
        answer: const MultipleChoice(options: ['a', 'b'], correctIndex: 5),
      );

      expect(
        validateQuestion(question).join(),
        contains('außerhalb der Optionen'),
      );
    });

    test('doppelte Optionen zerstören die Eindeutigkeit', () {
      final question = build(
        answer: const MultipleChoice(
          options: ['rot', 'grün', 'rot'],
          correctIndex: 0,
        ),
      );

      expect(
        validateQuestion(question),
        contains('Antwortoptionen sind nicht eindeutig'),
      );
    });

    test('Doppelungen werden auch bei anderer Schreibweise erkannt', () {
      final question = build(
        answer: const MultipleChoice(
          options: ['Rot', ' rot ', 'blau'],
          correctIndex: 2,
        ),
      );

      expect(
        validateQuestion(question),
        contains('Antwortoptionen sind nicht eindeutig'),
      );
    });

    test('eine leere Option fällt auf', () {
      final question = build(
        answer: const MultipleChoice(options: ['a', '  '], correctIndex: 0),
      );

      expect(
        validateQuestion(question),
        contains('mindestens eine Antwortoption ist leer'),
      );
    });
  });

  group('Zahleneingaben', () {
    test('ein nicht darstellbares Ergebnis fällt auf', () {
      // 1/3 lässt sich mit null Nachkommastellen nicht exakt angeben.
      final question = build(
        answer: const NumericInput(correctValue: 1 / 3),
        explanation: 'Das Ergebnis ist 0,333…',
      );

      expect(
        validateQuestion(question).join(),
        contains('nicht exakt darstellen'),
      );
    });

    test('zu wenige Nachkommastellen fallen auf', () {
      // 2,4 lässt sich mit null Nachkommastellen nicht angeben.
      final question = build(
        answer: const NumericInput(correctValue: 2.4),
        explanation: 'Das Ergebnis ist 2,4.',
      );

      expect(
        validateQuestion(question).join(),
        contains('nicht exakt darstellen'),
      );
    });

    test('harmloses Gleitkomma-Rauschen wird toleriert', () {
      // 0.1 + 0.2 ergibt 0.30000000000000004. Auf eine Nachkommastelle
      // gerundet ist das exakt 0,3 – der Abstand liegt weit unter der
      // Epsilon-Schwelle und soll die Aufgabe nicht durchfallen lassen.
      final question = build(
        answer: const NumericInput(correctValue: 0.1 + 0.2, decimals: 1),
        explanation: 'Das Ergebnis ist 0,3.',
      );

      expect(validateQuestion(question), isEmpty);
    });

    test('ein Lösungsweg ohne Ergebnis fällt auf', () {
      final question = build(
        answer: const NumericInput(correctValue: 408),
        explanation: 'Einfach ausrechnen.',
      );

      expect(
        validateQuestion(question),
        contains('Lösungsweg nennt das Ergebnis nicht'),
      );
    });

    test('unplausible Nachkommastellen fallen auf', () {
      final question = build(
        answer: const NumericInput(correctValue: 1, decimals: 7),
        explanation: 'Das Ergebnis ist 1,0000000.',
      );

      expect(
        validateQuestion(question).join(),
        contains('unplausible Nachkommastellen'),
      );
    });
  });

  group('Tausenderpunkte setzen', () {
    test('gruppiert ab vier Stellen', () {
      expect(groupDigits('4500'), '4.500');
      expect(groupDigits('12000'), '12.000');
      expect(groupDigits('1234567'), '1.234.567');
    });

    test('lässt kurze Zahlen unverändert', () {
      expect(groupDigits('7'), '7');
      expect(groupDigits('999'), '999');
    });

    test('behält das Vorzeichen', () {
      expect(groupDigits('-4500'), '-4.500');
    });
  });
}
