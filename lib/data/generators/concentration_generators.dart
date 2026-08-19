import 'dart:math';

import 'package:einstellungstest_trainer/data/generators/question_generator.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';

/// Zeichen, aus denen die Konzentrationsaufgaben gebaut werden.
///
/// Bewusst ähnlich aussehende Paare (O/0, l/1, m/n): Genau daran scheitert
/// im echten Test die Sorgfalt, nicht an exotischen Symbolen.
const List<String> _symbols = [
  'A', 'V', 'W', 'M', 'N', 'X', 'K', 'R', 'P', 'B',
  'O', 'Q', 'C', 'G', 'S', '5', '2', 'Z', '8', 'E',
];

/// „Wie oft kommt das Zeichen vor?" – eine Fläche voller Zeichen, eine Zahl
/// als Antwort.
///
/// Rückwärts konstruiert: Erst steht die Trefferzahl fest, dann wird die
/// Fläche darum herum gefüllt. Dadurch stimmt die Lösung immer exakt.
class CountingGenerator extends QuestionGenerator {
  const CountingGenerator();

  @override
  SubCategory get subCategory => SubCategory.counting;

  @override
  Question generate(Random random, Difficulty difficulty, String id) {
    final (rows, columns) = switch (difficulty) {
      Difficulty.easy => (4, 10),
      Difficulty.medium => (5, 12),
      Difficulty.hard => (6, 14),
    };
    final total = rows * columns;

    final target = _symbols[random.nextInt(_symbols.length)];
    final others = _symbols.where((symbol) => symbol != target).toList();

    // Zwischen 8 und 16 Prozent der Flaeche sind Treffer – genug, um zaehlen
    // zu muessen, wenig genug, um sich verzaehlen zu koennen.
    final hits = (total * (0.08 + random.nextDouble() * 0.08)).round();

    final field = <String>[
      for (var index = 0; index < hits; index++) target,
      for (var index = hits; index < total; index++)
        others[random.nextInt(others.length)],
    ]..shuffle(random);

    final lines = [
      for (var row = 0; row < rows; row++)
        field.sublist(row * columns, (row + 1) * columns).join(' '),
    ];

    return Question(
      id: id,
      subCategory: SubCategory.counting,
      prompt: 'Wie oft kommt "$target" vor?\n\n${lines.join('\n')}',
      answer: NumericInput(correctValue: hits.toDouble()),
      explanation: 'Das Zeichen "$target" steht $hits Mal in der Fläche. '
          'Zeilenweise zählen und die Zwischensumme merken – wer springt, '
          'zählt doppelt.',
      difficulty: difficulty,
    );
  }
}

/// „Welche Reihe ist gleich?" – zwei identische Zeichenfolgen unter mehreren,
/// die sich an genau einer Stelle unterscheiden.
class ComparisonGenerator extends QuestionGenerator {
  const ComparisonGenerator();

  @override
  SubCategory get subCategory => SubCategory.comparison;

  @override
  Question generate(Random random, Difficulty difficulty, String id) {
    final length = switch (difficulty) {
      Difficulty.easy => 7,
      Difficulty.medium => 9,
      Difficulty.hard => 12,
    };

    final base = [
      for (var index = 0; index < length; index++)
        _symbols[random.nextInt(_symbols.length)],
    ];
    final reference = base.join(' ');

    // Drei Abweichler, die sich an genau einer Stelle unterscheiden.
    final options = <String>[];
    final usedPositions = <int>{};
    while (options.length < 3) {
      final position = random.nextInt(length);
      if (!usedPositions.add(position)) continue;

      final changed = [...base];
      final alternatives =
          _symbols.where((symbol) => symbol != base[position]).toList();
      changed[position] = alternatives[random.nextInt(alternatives.length)];
      options.add(changed.join(' '));
    }

    final correctIndex = random.nextInt(4);
    options.insert(correctIndex, reference);

    return Question(
      id: id,
      subCategory: SubCategory.comparison,
      prompt: 'Welche Reihe stimmt mit dieser überein?\n\n$reference',
      answer: MultipleChoice(options: options, correctIndex: correctIndex),
      explanation: 'Nur eine Reihe ist Zeichen für Zeichen gleich. Die '
          'übrigen weichen an genau einer Stelle ab – von links nach rechts '
          'paarweise vergleichen, nicht im Ganzen lesen.',
      difficulty: difficulty,
    );
  }
}
