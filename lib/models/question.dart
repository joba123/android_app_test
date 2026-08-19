import 'package:einstellungstest_trainer/models/figure.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';

enum Difficulty {
  easy(label: 'Leicht'),
  medium(label: 'Mittel'),
  hard(label: 'Schwer');

  const Difficulty({required this.label});

  final String label;
}

/// Wie eine Aufgabe beantwortet wird.
///
/// Bewusst als versiegelte Hierarchie statt als Enum mit optionalen Feldern:
/// So kann es keine Aufgabe geben, die gleichzeitig Antwortoptionen und einen
/// erwarteten Zahlenwert trägt, und die Auswertung lässt sich lückenlos über
/// ein `switch` abdecken.
sealed class AnswerFormat {
  const AnswerFormat();
}

/// Multiple Choice – der Regelfall für Logik und Sprache.
final class MultipleChoice extends AnswerFormat {
  const MultipleChoice({
    required this.options,
    required this.correctIndex,
    this.optionFigures,
  });

  final List<String> options;
  final int correctIndex;

  /// Gezeichnete Antwortmöglichkeiten – eine je Option, in derselben
  /// Reihenfolge. Ist das gesetzt, zeigt die Oberfläche die Figur statt des
  /// Textes; der Text bleibt als Beschreibung für Vorlesehilfen.
  ///
  /// Die Liste muss genauso lang sein wie [options]. Das lässt sich hier
  /// nicht per `assert` festhalten – in einem konstanten Konstruktor ist
  /// `length` nicht auswertbar –, wird aber von der Aufgabenprüfung
  /// mitgetragen.
  final List<FigureCell>? optionFigures;

  String get correctOption => options[correctIndex];

  /// Neue Instanz mit umsortierten Optionen. [order] enthält die
  /// ursprünglichen Indizes in ihrer neuen Reihenfolge; der Lösungsindex
  /// wird dabei korrekt mitgezogen.
  MultipleChoice reordered(List<int> order) {
    assert(
      order.length == options.length,
      'Reihenfolge passt nicht zur Anzahl der Optionen',
    );
    final figures = optionFigures;
    return MultipleChoice(
      options: [for (final index in order) options[index]],
      correctIndex: order.indexOf(correctIndex),
      optionFigures:
          figures == null ? null : [for (final index in order) figures[index]],
    );
  }
}

/// Freie Zahleneingabe – der Regelfall für Mathematik.
///
/// [tolerance] erlaubt Rundungsspielraum (z. B. bei Geldbeträgen). Bei 0 muss
/// der Wert exakt getroffen werden.
final class NumericInput extends AnswerFormat {
  const NumericInput({
    required this.correctValue,
    this.tolerance = 0,
    this.decimals = 0,
    this.unit,
  }) : assert(tolerance >= 0, 'Toleranz darf nicht negativ sein'),
       assert(decimals >= 0, 'Nachkommastellen dürfen nicht negativ sein');

  final double correctValue;
  final double tolerance;

  /// Nachkommastellen für die Anzeige der Musterlösung.
  final int decimals;

  /// Optionale Einheit, z. B. "€" oder "km/h". Wird als Suffix am Eingabefeld
  /// angezeigt und muss nicht mit eingetippt werden.
  final String? unit;

  /// Das [_epsilon] fängt Rundungsrauschen von Gleitkommazahlen ab: Ohne das
  /// könnte 793,79 bei einer Toleranz von 0,01 je nach Bitmuster knapp
  /// durchfallen. Der Wert liegt weit unterhalb jeder sinnvollen
  /// Antwortgenauigkeit und ändert daher nichts an der Bewertung.
  static const double _epsilon = 1e-9;

  bool accepts(double value) =>
      (value - correctValue).abs() <= tolerance + _epsilon;

  /// Musterlösung in deutscher Schreibweise, inklusive Einheit.
  String get formattedValue {
    final text = correctValue.toStringAsFixed(decimals).replaceAll('.', ',');
    return unit == null ? text : '$text $unit';
  }
}

/// Die Antwort, die jemand gegeben hat.
sealed class Response {
  const Response();
}

/// Eine angetippte Antwortoption.
final class ChoiceResponse extends Response {
  const ChoiceResponse(this.optionIndex);

  final int optionIndex;
}

/// Ein eingetippter Zahlenwert samt der ursprünglichen Eingabe.
final class NumericResponse extends Response {
  const NumericResponse({required this.value, required this.input});

  final double value;

  /// Roheingabe, damit die Auswertung zeigen kann, was getippt wurde.
  final String input;

  /// Liest eine Zahl in deutscher Schreibweise ein.
  ///
  /// Akzeptiert Komma und Punkt als Dezimaltrennzeichen und ignoriert
  /// Leerzeichen sowie mitgetippte Einheiten wie "€" oder "%". Sind beide
  /// Trennzeichen vorhanden ("1.234,56"), gilt das hintere als Dezimal-
  /// trennzeichen und das vordere als Tausendertrennung. Steht nur ein Punkt,
  /// wird er als Dezimaltrennzeichen gelesen – auf einem Ziffernblock tippt
  /// kaum jemand Tausenderpunkte, aber sehr wohl "2.5" statt "2,5".
  ///
  /// Gibt `null` zurück, wenn sich keine Zahl erkennen lässt.
  static NumericResponse? tryParse(String input) {
    var text = input.replaceAll(RegExp(r'[\s €%]'), '');
    if (text.isEmpty) return null;

    final lastComma = text.lastIndexOf(',');
    final lastDot = text.lastIndexOf('.');

    if (lastComma >= 0 && lastDot >= 0) {
      if (lastComma > lastDot) {
        text = text.replaceAll('.', '').replaceAll(',', '.');
      } else {
        text = text.replaceAll(',', '');
      }
    } else if (lastComma >= 0) {
      text = text.replaceAll(',', '.');
    }

    final value = double.tryParse(text);
    if (value == null) return null;

    return NumericResponse(value: value, input: input.trim());
  }
}

/// Eine einzelne Aufgabe.
///
/// Aufgaben sind unveränderlich. Das Mischen der Antwortoptionen passiert
/// bewusst nicht hier, sondern in der QuestionRepository, damit derselbe Pool
/// mehrfach in unterschiedlicher Reihenfolge nutzbar ist.
class Question {
  const Question({
    required this.id,
    required this.subCategory,
    required this.prompt,
    required this.answer,
    required this.explanation,
    this.difficulty = Difficulty.medium,
    this.imageAsset,
    this.figures,
  });

  final String id;

  /// Feinthema der Aufgabe. Die Kategorie (Modul) ergibt sich daraus – sie
  /// wird nicht separat gespeichert, damit beides nicht auseinanderlaufen kann.
  final SubCategory subCategory;

  final String prompt;
  final AnswerFormat answer;

  /// Kurzer Rechenweg bzw. Begründung der Lösung.
  final String explanation;

  final Difficulty difficulty;

  /// Optionales Bild zur Aufgabe, z. B. `assets/figures/reihe_01.png`.
  ///
  /// Vorgesehen für Figurenanalogien und Matrizenaufgaben, die sich sprachlich
  /// nur behelfsmäßig beschreiben lassen. Ist der Wert gesetzt, zeigt die
  /// QuestionCard das Bild über dem Aufgabentext an. Damit das greift, muss
  /// der Asset-Ordner zusätzlich in `pubspec.yaml` eingetragen werden.
  final String? imageAsset;

  /// Gezeichnete Figuren zur Aufgabe, von links nach rechts. Wird statt eines
  /// Bildes verwendet, wo sich eine Figur eindeutig beschreiben lässt.
  final List<FigureCell>? figures;

  /// Die Kategorie der Aufgabe.
  TrainingModule get module => subCategory.module;

  bool get isMultipleChoice => answer is MultipleChoice;

  bool get isNumericInput => answer is NumericInput;

  /// Prüft eine gegebene Antwort. Passt das Antwortformat nicht zur Aufgabe
  /// (z. B. eine Zahleneingabe auf eine Multiple-Choice-Frage), gilt sie als
  /// falsch statt einen Fehler zu werfen.
  bool isCorrect(Response response) {
    return switch ((answer, response)) {
      (final MultipleChoice format, final ChoiceResponse given) =>
        given.optionIndex == format.correctIndex,
      (final NumericInput format, final NumericResponse given) =>
        format.accepts(given.value),
      _ => false,
    };
  }

  /// Die Musterlösung als anzeigbarer Text.
  String get correctAnswerText {
    return switch (answer) {
      final MultipleChoice format => format.correctOption,
      final NumericInput format => format.formattedValue,
    };
  }

  /// Die gegebene Antwort als anzeigbarer Text – für die Auswertung.
  String describeResponse(Response response) {
    return switch ((answer, response)) {
      (final MultipleChoice format, final ChoiceResponse given) =>
        given.optionIndex >= 0 && given.optionIndex < format.options.length
            ? format.options[given.optionIndex]
            : '—',
      (final NumericInput format, final NumericResponse given) =>
        format.unit == null ? given.input : '${given.input} ${format.unit}',
      _ => '—',
    };
  }

  Question copyWith({AnswerFormat? answer}) {
    return Question(
      id: id,
      subCategory: subCategory,
      prompt: prompt,
      answer: answer ?? this.answer,
      explanation: explanation,
      difficulty: difficulty,
      imageAsset: imageAsset,
    );
  }
}
