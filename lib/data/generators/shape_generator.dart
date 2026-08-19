import 'dart:math';

import 'package:einstellungstest_trainer/data/generators/question_generator.dart';
import 'package:einstellungstest_trainer/models/figure.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';

/// Formen- und Musteraufgaben, gezeichnet statt beschrieben.
///
/// Drei Bauarten, die in Einstellungstests durchgängig vorkommen:
///
/// * **Reihe fortsetzen** – eine Größe ändert sich regelmäßig (Anzahl,
///   Drehung, Füllung), das nächste Glied ist gesucht.
/// * **Ausreißer finden** – vier Figuren, eine folgt der Regel nicht.
/// * **Analogie** – „A verhält sich zu B wie C zu ?"
///
/// Rückwärts konstruiert: Erst steht die Regel fest, dann entstehen die
/// Figuren daraus. Dadurch gibt es immer genau eine richtige Antwort, und der
/// Lösungsweg lässt sich in einem Satz sagen.
class ShapeGenerator extends QuestionGenerator {
  const ShapeGenerator();

  @override
  SubCategory get subCategory => SubCategory.shapes;

  static const List<FigureShape> _shapes = [
    FigureShape.circle,
    FigureShape.square,
    FigureShape.triangle,
    FigureShape.diamond,
    FigureShape.pentagon,
    FigureShape.star,
  ];

  @override
  Question generate(Random random, Difficulty difficulty, String id) {
    final kind = random.nextInt(3);
    return switch (kind) {
      0 => _sequence(random, difficulty, id),
      1 => _oddOneOut(random, difficulty, id),
      _ => _analogy(random, difficulty, id),
    };
  }

  /// Reihe fortsetzen: Anzahl, Drehung oder Füllung ändert sich regelmäßig.
  Question _sequence(Random random, Difficulty difficulty, String id) {
    final shape = _shapes[random.nextInt(_shapes.length)];
    final rule = random.nextInt(difficulty == Difficulty.easy ? 2 : 3);

    late List<FigureCell> row;
    late FigureCell answer;
    late String explanation;

    switch (rule) {
      case 0:
        // Anzahl waechst um eins. Mehr als sechs Formen passen nicht in eine
        // Zelle, und der Abstandhalter braucht darueber noch Platz – deshalb
        // beginnt die Reihe bei eins oder zwei.
        final start = 1 + random.nextInt(2);
        row = [
          for (var index = 0; index < 3; index++)
            FigureCell(shape: shape, count: start + index),
        ];
        answer = FigureCell(shape: shape, count: start + 3);
        explanation = 'Die Anzahl wächst je Schritt um eins: '
            '${row.map((cell) => cell.count).join(' – ')} – ${answer.count}.';
      case 1:
        // Fuellung wechselt bei jedem Schritt.
        final startFilled = random.nextBool();
        row = [
          for (var index = 0; index < 3; index++)
            FigureCell(
              shape: shape,
              count: 2,
              filled: index.isEven ? startFilled : !startFilled,
            ),
        ];
        answer = FigureCell(
          shape: shape,
          count: 2,
          filled: startFilled,
        );
        explanation = 'Die Füllung wechselt bei jedem Schritt. Nach '
            '${row.last.filled ? 'ausgefüllt' : 'nicht ausgefüllt'} folgt '
            '${answer.filled ? 'ausgefüllt' : 'nicht ausgefüllt'}.';
      default:
        // Drehung um jeweils eine Vierteldrehung.
        final turning = shape == FigureShape.circle
            ? FigureShape.triangle
            : shape;
        row = [
          for (var index = 0; index < 3; index++)
            FigureCell(shape: turning, quarterTurns: index % 4),
        ];
        answer = FigureCell(shape: turning, quarterTurns: 3 % 4);
        explanation = 'Die Figur dreht sich Schritt für Schritt um 90 Grad '
            'weiter.';
    }

    final options = _distractorsFor(random, answer);
    final correctIndex = random.nextInt(options.length + 1);
    final cells = [...options]..insert(correctIndex, answer);

    return Question(
      id: id,
      subCategory: SubCategory.shapes,
      prompt: 'Welche Figur setzt die Reihe fort?',
      figures: row,
      answer: MultipleChoice(
        options: [for (final cell in cells) cell.describe()],
        correctIndex: correctIndex,
        optionFigures: cells,
      ),
      explanation: explanation,
      difficulty: difficulty,
    );
  }

  /// Ausreißer finden: drei Figuren folgen einer Regel, eine nicht.
  ///
  /// Die Anzahl ist in allen vier Feldern verschieden. Das ist Absicht: Sonst
  /// stünden dort mehrfach identische Figuren, und die Aufgabe liesse sich
  /// durch blosses Zaehlen gleicher Bilder loesen statt durch die Regel.
  Question _oddOneOut(Random random, Difficulty difficulty, String id) {
    final shape = _shapes[random.nextInt(_shapes.length)];
    final other = _shapes.where((candidate) => candidate != shape).toList()
      ..shuffle(random);
    final counts = [1, 2, 3, 4]..shuffle(random);
    final filled = random.nextBool();
    final breaksByShape = random.nextBool();

    final oddIndex = random.nextInt(4);
    final cells = [
      for (var index = 0; index < 4; index++)
        if (index == oddIndex)
          FigureCell(
            shape: breaksByShape ? other.first : shape,
            count: counts[index],
            filled: breaksByShape ? filled : !filled,
          )
        else
          FigureCell(shape: shape, count: counts[index], filled: filled),
    ];

    return Question(
      id: id,
      subCategory: SubCategory.shapes,
      prompt: 'Welche Figur passt nicht zu den anderen?',
      answer: MultipleChoice(
        options: [for (final cell in cells) cell.describe()],
        correctIndex: oddIndex,
        optionFigures: cells,
      ),
      explanation: breaksByShape
          ? 'Drei Felder zeigen ${shape.plural}, eines zeigt '
              '${other.first.plural}. Die Anzahl ist überall verschieden und '
              'damit kein Unterscheidungsmerkmal.'
          : 'Drei Felder sind '
              '${filled ? 'ausgefüllt' : 'nicht ausgefüllt'}, eines nicht.',
      difficulty: difficulty,
    );
  }

  /// Analogie: A zu B verhält sich wie C zu ?
  Question _analogy(Random random, Difficulty difficulty, String id) {
    final first = _shapes[random.nextInt(_shapes.length)];
    final second = _shapes.where((candidate) => candidate != first).toList()
      ..shuffle(random);
    final third = second.first;

    // Die Regel: von einer auf drei Formen.
    final a = FigureCell(shape: first, count: 1);
    final b = FigureCell(shape: first, count: 3);
    final c = FigureCell(shape: third, count: 1);
    final answer = FigureCell(shape: third, count: 3);

    final options = _distractorsFor(random, answer);
    final correctIndex = random.nextInt(options.length + 1);
    final cells = [...options]..insert(correctIndex, answer);

    return Question(
      id: id,
      subCategory: SubCategory.shapes,
      prompt: 'Die erste Figur verhält sich zur zweiten wie die dritte zu …?',
      figures: [a, b, c],
      answer: MultipleChoice(
        options: [for (final cell in cells) cell.describe()],
        correctIndex: correctIndex,
        optionFigures: cells,
      ),
      explanation: 'Aus einer Form werden drei. Aus einem '
          '${third.label} werden also drei ${third.plural}.',
      difficulty: difficulty,
    );
  }

  /// Drei falsche Figuren, die sich in genau einer Eigenschaft von der
  /// richtigen unterscheiden – damit die Aufgabe lösbar bleibt und nicht
  /// durch Ausschluss zerfällt.
  List<FigureCell> _distractorsFor(Random random, FigureCell answer) {
    final candidates = <FigureCell>{
      answer.copyWith(count: answer.count == 1 ? 2 : answer.count - 1),
      if (answer.count < 6) answer.copyWith(count: answer.count + 1),
      answer.copyWith(filled: !answer.filled),
      answer.copyWith(
        shape: _shapes.firstWhere((shape) => shape != answer.shape),
      ),
      if (answer.shape != FigureShape.circle)
        answer.copyWith(quarterTurns: (answer.quarterTurns + 1) % 4),
    }..remove(answer);

    final list = candidates.toList()..shuffle(random);
    return list.take(3).toList();
  }
}
