import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';

/// Eine korrekte Antwort für eine Aufgabe – unabhängig vom Antwortformat.
///
/// Damit bleiben die Controller-Tests lesbar: Sie interessieren sich für den
/// Ablauf, nicht dafür, ob gerade angetippt oder getippt wird.
Response correctResponse(Question question) {
  return switch (question.answer) {
    final MultipleChoice format => ChoiceResponse(format.correctIndex),
    final NumericInput format => NumericResponse(
        value: format.correctValue,
        input: format.correctValue.toString(),
      ),
  };
}

/// Eine garantiert falsche Antwort für eine Aufgabe.
Response wrongResponse(Question question) {
  return switch (question.answer) {
    final MultipleChoice format =>
      ChoiceResponse((format.correctIndex + 1) % format.options.length),
    final NumericInput format => NumericResponse(
        value: format.correctValue + format.tolerance + 1,
        input: 'daneben',
      ),
  };
}

/// Testaufgabe mit Antwortoptionen.
Question choiceQuestion({
  String id = 'q_choice',
  SubCategory subCategory = SubCategory.spelling,
  List<String> options = const ['A', 'B', 'C'],
  int correctIndex = 1,
}) {
  return Question(
    id: id,
    subCategory: subCategory,
    prompt: 'Testfrage',
    answer: MultipleChoice(options: options, correctIndex: correctIndex),
    explanation: 'Testerklärung',
  );
}

/// Testaufgabe mit Zahleneingabe.
Question numericQuestion({
  String id = 'q_numeric',
  SubCategory subCategory = SubCategory.arithmetic,
  double correctValue = 42,
  double tolerance = 0,
  int decimals = 0,
  String? unit,
}) {
  return Question(
    id: id,
    subCategory: subCategory,
    prompt: 'Testrechnung',
    answer: NumericInput(
      correctValue: correctValue,
      tolerance: tolerance,
      decimals: decimals,
      unit: unit,
    ),
    explanation: 'Testrechenweg',
  );
}
