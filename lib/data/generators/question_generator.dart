import 'dart:math';

import 'package:einstellungstest_trainer/data/question_validation.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';

/// Erzeugt Aufgaben einer Unterkategorie algorithmisch.
///
/// Grundregel für alle Implementierungen: **rückwärts konstruieren**. Erst wird
/// das Ergebnis festgelegt (bzw. die Zwischengrößen, aus denen es exakt
/// hervorgeht), dann die Aufgabenstellung daraus abgeleitet. So kann keine
/// Aufgabe mit krummem Ergebnis oder nie endender Division entstehen.
abstract class QuestionGenerator {
  const QuestionGenerator();

  SubCategory get subCategory;

  /// Erzeugt genau eine Aufgabe mit der übergebenen [id].
  Question generate(Random random, Difficulty difficulty, String id);
}

/// Gemeinsame Rechen- und Formathilfen der Generatoren.
///
/// Alle Beträge werden intern in **Cent** gerechnet. Das hält Geldergebnisse
/// exakt – mit `double` käme über kurz oder lang 793.7999999999999 heraus.
abstract final class GeneratorSupport {
  /// Zufällige ganze Zahl aus [min]..[max], beide einschließlich.
  static int between(Random random, int min, int max) {
    assert(max >= min, 'Ungültiger Bereich $min..$max');
    return min + random.nextInt(max - min + 1);
  }

  /// Zufälliges Vielfaches von [step] aus [min]..[max].
  static int multipleBetween(Random random, int min, int max, int step) {
    final lowest = (min + step - 1) ~/ step;
    final highest = max ~/ step;
    assert(highest >= lowest, 'Kein Vielfaches von $step in $min..$max');
    return between(random, lowest, highest) * step;
  }

  static T pick<T>(Random random, List<T> options) {
    return options[random.nextInt(options.length)];
  }

  /// Ganze Zahl mit Tausenderpunkten: 4500 wird zu "4.500".
  static String integer(int value) => groupDigits(value.toString());

  /// Dezimalzahl in deutscher Schreibweise: 2.5 wird zu "2,5".
  static String decimal(double value, int decimals) {
    final text = value.toStringAsFixed(decimals);
    final parts = text.split('.');
    final grouped = groupDigits(parts.first);
    return parts.length == 1 ? grouped : '$grouped,${parts[1]}';
  }

  /// Geldbetrag aus Cent: 79380 wird zu "793,80 €".
  static String euro(int cents) {
    final sign = cents < 0 ? '-' : '';
    final absolute = cents.abs();
    final euros = groupDigits((absolute ~/ 100).toString());
    final rest = (absolute % 100).toString().padLeft(2, '0');
    return '$sign$euros,$rest €';
  }

  /// Stundenangabe: 2.5 wird zu "2,5", 3.0 zu "3".
  static String hours(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : decimal(value, 1);
  }

  /// Geldaufgabe als Zahleneingabe – zwei Nachkommastellen, Cent-Toleranz.
  static NumericInput money(int cents) {
    return NumericInput(
      correctValue: cents / 100,
      tolerance: 0.01,
      decimals: 2,
      unit: '€',
    );
  }

  /// Ganzzahlige Lösung als Zahleneingabe.
  static NumericInput count(int value, {String? unit}) {
    return NumericInput(
      correctValue: value.toDouble(),
      unit: unit,
    );
  }
}
