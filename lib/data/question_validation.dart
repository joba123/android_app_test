import 'package:einstellungstest_trainer/models/question.dart';

/// Qualitätssicherung für Aufgaben – egal ob handgeschrieben oder generiert.
///
/// Der Validator ist die gemeinsame Messlatte: Die Generatoren prüfen jede
/// erzeugte Aufgabe im Debug-Build gegen ihn (siehe MathQuestionFactory), und
/// die Tests jagen sowohl den statischen Pool als auch tausende generierte
/// Aufgaben hindurch.
///
/// Gibt eine leere Liste zurück, wenn alles in Ordnung ist, sonst je einen
/// Klartext-Befund pro Problem.
List<String> validateQuestion(Question question) {
  final problems = <String>[];

  if (question.id.trim().isEmpty) {
    problems.add('ID fehlt');
  }
  if (question.prompt.trim().isEmpty) {
    problems.add('Aufgabentext fehlt');
  }
  if (question.explanation.trim().isEmpty) {
    problems.add('Lösungsweg fehlt');
  }

  switch (question.answer) {
    case final MultipleChoice format:
      problems.addAll(_validateMultipleChoice(format));
    case final NumericInput format:
      problems.addAll(_validateNumericInput(format, question.explanation));
  }

  return problems;
}

List<String> _validateMultipleChoice(MultipleChoice format) {
  final problems = <String>[];

  if (format.options.length < 2) {
    problems.add('weniger als zwei Antwortoptionen');
  }
  if (format.correctIndex < 0 || format.correctIndex >= format.options.length) {
    problems.add('correctIndex ${format.correctIndex} liegt außerhalb der Optionen');
  }
  final figures = format.optionFigures;
  if (figures != null && figures.length != format.options.length) {
    problems.add('Zu jeder Antwortoption gehört genau eine Figur');
  }

  if (format.options.any((option) => option.trim().isEmpty)) {
    problems.add('mindestens eine Antwortoption ist leer');
  }

  // Doppelte Optionen zerstören die Eindeutigkeit der richtigen Antwort.
  final normalized =
      format.options.map((option) => option.trim().toLowerCase()).toList();
  if (normalized.toSet().length != normalized.length) {
    problems.add('Antwortoptionen sind nicht eindeutig');
  }

  return problems;
}

List<String> _validateNumericInput(NumericInput format, String explanation) {
  final problems = <String>[];

  if (!format.correctValue.isFinite) {
    problems.add('Lösungswert ist keine endliche Zahl');
    return problems;
  }
  // Eine negative Toleranz fängt bereits der Konstruktor von NumericInput ab.
  if (format.decimals < 0 || format.decimals > 4) {
    problems.add('unplausible Nachkommastellen: ${format.decimals}');
  }

  // Der Lösungswert muss sich mit den vorgesehenen Nachkommastellen exakt
  // darstellen lassen. Das fängt Gleitkomma-Unfälle wie 0.30000000000000004
  // und nie endende Divisionen wie 1/3 ab, bevor sie in einer Aufgabe landen.
  final rounded =
      double.parse(format.correctValue.toStringAsFixed(format.decimals));
  if ((rounded - format.correctValue).abs() > 1e-9) {
    problems.add(
      'Lösungswert ${format.correctValue} lässt sich mit '
      '${format.decimals} Nachkommastellen nicht exakt darstellen',
    );
  }

  // Ein Rechenweg, der das Ergebnis nicht nennt, ist kein Rechenweg.
  if (!_explanationStatesResult(explanation, format)) {
    problems.add('Lösungsweg nennt das Ergebnis nicht');
  }

  return problems;
}

/// Prüft, ob der Lösungsweg das Ergebnis ausschreibt – in einfacher oder in
/// gruppierter Schreibweise ("4500" bzw. "4.500").
bool _explanationStatesResult(String explanation, NumericInput format) {
  final plain =
      format.correctValue.toStringAsFixed(format.decimals).replaceAll('.', ',');
  if (explanation.contains(plain)) return true;

  final separatorIndex = plain.indexOf(',');
  final integerPart =
      separatorIndex == -1 ? plain : plain.substring(0, separatorIndex);
  final fraction =
      separatorIndex == -1 ? '' : plain.substring(separatorIndex);

  return explanation.contains('${groupDigits(integerPart)}$fraction');
}

/// Setzt Tausenderpunkte in eine Ziffernfolge: "4500" wird zu "4.500".
String groupDigits(String digits) {
  final negative = digits.startsWith('-');
  final body = negative ? digits.substring(1) : digits;

  final buffer = StringBuffer();
  for (var index = 0; index < body.length; index++) {
    if (index > 0 && (body.length - index) % 3 == 0) buffer.write('.');
    buffer.write(body[index]);
  }

  return negative ? '-$buffer' : buffer.toString();
}
