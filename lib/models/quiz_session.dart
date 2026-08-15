import 'package:einstellungstest_trainer/models/answer_record.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';

enum SessionMode {
  practice(label: 'Uebungsmodus'),
  sprint(label: 'Sprint-Modus'),
  simulation(label: 'Testsimulation');

  const SessionMode({required this.label});

  final String label;
}

enum SessionStatus { running, finished }

/// Laufender Zustand einer Uebungs- oder Sprint-Runde.
///
/// Die Testsimulation nutzt ein eigenes Modell ([SimulationSession]), weil sie
/// mehrere Testteile mit je eigener Zeit verwaltet.
class QuizSession {
  const QuizSession({
    required this.mode,
    required this.module,
    required this.questions,
    this.currentIndex = 0,
    this.answers = const [],
    this.selectedIndex,
    this.revealed = false,
    this.remainingSeconds,
    this.status = SessionStatus.running,
  });

  final SessionMode mode;
  final TrainingModule module;
  final List<Question> questions;
  final int currentIndex;
  final List<AnswerRecord> answers;

  /// Aktuell angetippte Option, solange noch nicht bestaetigt wurde.
  final int? selectedIndex;

  /// Im Uebungsmodus: Loesung samt Erklaerung wird angezeigt.
  final bool revealed;

  /// Nur im Sprint-Modus gesetzt (Countdown ueber die gesamte Runde).
  final int? remainingSeconds;

  final SessionStatus status;

  Question get currentQuestion => questions[currentIndex];

  bool get isLastQuestion => currentIndex >= questions.length - 1;

  int get correctCount => answers.where((answer) => answer.isCorrect).length;

  int get answeredCount => answers.where((answer) => answer.isAnswered).length;

  /// Fortschritt von 0.0 bis 1.0 fuer die Anzeige im Kopfbereich.
  double get progress => questions.isEmpty ? 0 : answers.length / questions.length;

  QuizSession copyWith({
    int? currentIndex,
    List<AnswerRecord>? answers,
    int? selectedIndex,
    bool clearSelection = false,
    bool? revealed,
    int? remainingSeconds,
    SessionStatus? status,
  }) {
    return QuizSession(
      mode: mode,
      module: module,
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      selectedIndex: clearSelection ? null : (selectedIndex ?? this.selectedIndex),
      revealed: revealed ?? this.revealed,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
    );
  }
}
