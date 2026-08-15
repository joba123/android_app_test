import 'package:einstellungstest_trainer/models/question.dart';

/// Protokolliert eine beantwortete (oder uebersprungene) Aufgabe.
///
/// Wird sowohl fuer die Ergebnisanzeige als auch fuer die Statistik genutzt.
class AnswerRecord {
  const AnswerRecord({
    required this.question,
    required this.selectedIndex,
    required this.timeSpent,
  });

  final Question question;

  /// `null` bedeutet: uebersprungen bzw. Zeit abgelaufen, bevor geantwortet wurde.
  final int? selectedIndex;

  final Duration timeSpent;

  bool get isAnswered => selectedIndex != null;

  bool get isCorrect => selectedIndex == question.correctIndex;
}
