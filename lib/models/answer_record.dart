import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';

/// Protokolliert eine bearbeitete (oder übersprungene) Aufgabe während einer
/// laufenden Sitzung.
///
/// Hält die vollständige [Question], damit die Auswertung Aufgabentext,
/// Musterlösung und Erklärung anzeigen kann. Für den dauerhaften Verlauf wird
/// daraus über [toResult] die schlanke, serialisierbare Form.
class AnswerRecord {
  const AnswerRecord({
    required this.question,
    required this.response,
    required this.timeSpent,
  });

  final Question question;

  /// `null` bedeutet: übersprungen bzw. Zeit abgelaufen, bevor geantwortet
  /// wurde.
  final Response? response;

  final Duration timeSpent;

  bool get isAnswered => response != null;

  bool get isCorrect {
    final given = response;
    return given != null && question.isCorrect(given);
  }

  /// Die gegebene Antwort als anzeigbarer Text.
  String get responseText {
    final given = response;
    return given == null ? '—' : question.describeResponse(given);
  }

  QuestionResult toResult() {
    return QuestionResult(
      questionId: question.id,
      subCategory: question.subCategory,
      answered: isAnswered,
      correct: isCorrect,
      timeSpent: timeSpent,
    );
  }
}
