import 'dart:async';

import 'package:einstellungstest_trainer/models/answer_record.dart';
import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/quiz_session.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Schlüssel für den Session-Provider.
///
/// [length] gilt nur für den Übungsmodus – im Sprint bestimmt die Zeit das
/// Ende der Runde, nicht die Aufgabenzahl.
typedef QuizConfig = ({SessionMode mode, PracticeScope scope, int length});

/// Steuert Übungs- und Sprint-Runden.
///
/// Der Timer lebt im Controller, nicht im Widget. Dadurch läuft der
/// Sprint-Countdown unabhängig von Rebuilds weiter und wird über
/// `ref.onDispose` zuverlässig abgeräumt.
class QuizController extends AutoDisposeFamilyNotifier<QuizSession, QuizConfig> {
  /// Dauer einer Sprint-Runde in Sekunden.
  static const int sprintSeconds = 60;

  /// Auswahlmöglichkeiten für den Umfang einer Übungsrunde.
  static const List<int> practiceLengths = [10, 20, 30];

  static const int defaultPracticeLength = 20;

  Timer? _timer;
  DateTime _questionStartedAt = DateTime.now();

  @override
  QuizSession build(QuizConfig arg) {
    final repository = ref.watch(questionRepositoryProvider);
    final isSprint = arg.mode == SessionMode.sprint;

    final questions = isSprint
        ? repository.drawSprintQueue(arg.scope)
        : repository.drawForScope(arg.scope, count: arg.length);

    ref.onDispose(() => _timer?.cancel());

    // Bestwert vor der Runde festhalten, damit die Auswertung eine
    // Verbesserung erkennen kann – nach dem Verbuchen wäre er bereits
    // überschrieben.
    final previousBest = isSprint
        ? ref.read(statsControllerProvider).bestSprint(arg.scope)
        : 0;

    final now = DateTime.now();
    _questionStartedAt = now;
    if (isSprint) _startTimer();

    return QuizSession(
      mode: arg.mode,
      scope: arg.scope,
      questions: questions,
      startedAt: now,
      remainingSeconds: isSprint ? sprintSeconds : null,
      previousSprintBest: previousBest,
    );
  }

  /// Antwort abgeben.
  ///
  /// Im Übungsmodus wird die Lösung samt Erklärung sofort aufgedeckt und der
  /// Nutzer geht per "Weiter" selbst zur nächsten Aufgabe. Im Sprint zählt
  /// Tempo – dort wird ohne Feedback direkt weitergeschaltet.
  void answer(Response response) {
    if (state.status == SessionStatus.finished || state.revealed) return;
    if (state.questions.isEmpty) return;

    final record = AnswerRecord(
      question: state.currentQuestion,
      response: response,
      timeSpent: DateTime.now().difference(_questionStartedAt),
    );
    final answers = [...state.answers, record];

    if (state.mode == SessionMode.practice) {
      state = state.copyWith(
        answers: answers,
        response: response,
        revealed: true,
      );
    } else {
      state = state.copyWith(answers: answers, response: response);
      _advance();
    }
  }

  /// Eine Antwortoption antippen.
  void selectOption(int optionIndex) => answer(ChoiceResponse(optionIndex));

  /// Eine getippte Zahl abgeben.
  ///
  /// Gibt `false` zurück, wenn sich aus der Eingabe keine Zahl lesen lässt –
  /// dann bleibt die Aufgabe offen und die Oberfläche kann einen Hinweis
  /// anzeigen.
  bool submitNumber(String input) {
    final parsed = NumericResponse.tryParse(input);
    if (parsed == null) return false;

    answer(parsed);
    return true;
  }

  /// Aufgabe überspringen – zählt als nicht beantwortet.
  void skip() {
    if (state.status == SessionStatus.finished) return;
    if (state.questions.isEmpty) return;

    final record = AnswerRecord(
      question: state.currentQuestion,
      response: null,
      timeSpent: DateTime.now().difference(_questionStartedAt),
    );
    state = state.copyWith(
      answers: [...state.answers, record],
      revealed: false,
      clearResponse: true,
    );
    _advance();
  }

  /// Im Übungsmodus nach dem Aufdecken zur nächsten Aufgabe.
  void next() {
    if (state.status == SessionStatus.finished) return;
    _advance();
  }

  void finishEarly() => _finish();

  void _advance() {
    if (state.isLastQuestion) {
      _finish();
      return;
    }
    _questionStartedAt = DateTime.now();
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      clearResponse: true,
      revealed: false,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = (state.remainingSeconds ?? 0) - 1;
      if (remaining <= 0) {
        state = state.copyWith(remainingSeconds: 0);
        _finish();
      } else {
        state = state.copyWith(remainingSeconds: remaining);
      }
    });
  }

  void _finish() {
    if (state.status == SessionStatus.finished) return;
    _timer?.cancel();

    final summary = TrainingSession.fromAnswers(
      mode: state.mode,
      module: state.scope.module,
      startedAt: state.startedAt,
      finishedAt: DateTime.now(),
      answers: state.answers,
    );

    state = state.copyWith(
      status: SessionStatus.finished,
      revealed: false,
      summary: summary,
    );

    unawaited(
      ref.read(statsControllerProvider.notifier).record(
        summary,
        scope: state.scope,
      ),
    );
  }
}

final quizControllerProvider =
    AutoDisposeNotifierProvider.family<QuizController, QuizSession, QuizConfig>(
  QuizController.new,
);
