import 'package:einstellungstest_trainer/models/answer_record.dart';
import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';

export 'package:einstellungstest_trainer/models/session_mode.dart';

enum SessionStatus { running, finished }

/// Laufender Zustand einer Übungs- oder Sprint-Runde.
///
/// Die Testsimulation nutzt ein eigenes Modell ([SimulationSession]), weil sie
/// mehrere Testteile mit je eigener Zeit verwaltet. Beide münden am Ende in
/// eine [TrainingSession].
class QuizSession {
  const QuizSession({
    required this.mode,
    required this.scope,
    required this.questions,
    required this.startedAt,
    this.currentIndex = 0,
    this.answers = const [],
    this.response,
    this.revealed = false,
    this.remainingSeconds,
    this.status = SessionStatus.running,
    this.summary,
  });

  final SessionMode mode;

  /// Was geübt wird: ein Thema, ein ganzes Modul oder alles gemischt.
  final PracticeScope scope;

  final List<Question> questions;

  /// Beginn der Runde – wird für den Verlaufseintrag gebraucht.
  final DateTime startedAt;

  final int currentIndex;
  final List<AnswerRecord> answers;

  /// Bereits gegebene Antwort auf die aktuelle Aufgabe, solange sie noch
  /// angezeigt wird.
  final Response? response;

  /// Im Übungsmodus: Lösung samt Erklärung wird angezeigt.
  final bool revealed;

  /// Nur im Sprint-Modus gesetzt (Countdown über die gesamte Runde).
  final int? remainingSeconds;

  final SessionStatus status;

  /// Auswertung der Runde. Steht erst fest, wenn [status] auf
  /// [SessionStatus.finished] gewechselt ist.
  final TrainingSession? summary;

  Question get currentQuestion => questions[currentIndex];

  bool get isLastQuestion => currentIndex >= questions.length - 1;

  int get correctCount => answers.where((answer) => answer.isCorrect).length;

  int get answeredCount => answers.where((answer) => answer.isAnswered).length;

  /// Nummer der aktuellen Aufgabe für die Anzeige "Aufgabe 5/20".
  int get currentNumber => currentIndex + 1;

  int get totalQuestions => questions.length;

  /// Index der aktuell gewählten Option, falls es sich um eine
  /// Multiple-Choice-Aufgabe handelt und bereits getippt wurde.
  int? get selectedOptionIndex {
    final given = response;
    return given is ChoiceResponse ? given.optionIndex : null;
  }

  /// Fortschritt von 0.0 bis 1.0 für die Anzeige im Kopfbereich.
  double get progress =>
      questions.isEmpty ? 0 : (currentIndex + 1) / questions.length;

  QuizSession copyWith({
    int? currentIndex,
    List<AnswerRecord>? answers,
    Response? response,
    bool clearResponse = false,
    bool? revealed,
    int? remainingSeconds,
    SessionStatus? status,
    TrainingSession? summary,
  }) {
    return QuizSession(
      mode: mode,
      scope: scope,
      questions: questions,
      startedAt: startedAt,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      response: clearResponse ? null : (response ?? this.response),
      revealed: revealed ?? this.revealed,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
      summary: summary ?? this.summary,
    );
  }
}
