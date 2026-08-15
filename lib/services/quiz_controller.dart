import 'dart:async';

import 'package:einstellungstest_trainer/models/answer_record.dart';
import 'package:einstellungstest_trainer/models/quiz_session.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Schluessel fuer den Session-Provider: Modus plus Modul.
typedef QuizConfig = ({SessionMode mode, TrainingModule module});

/// Steuert Uebungs- und Sprint-Runden.
///
/// Der Timer lebt im Controller, nicht im Widget. Dadurch laeuft der
/// Sprint-Countdown unabhaengig von Rebuilds weiter und wird ueber
/// `ref.onDispose` zuverlaessig abgeraeumt.
class QuizController extends AutoDisposeFamilyNotifier<QuizSession, QuizConfig> {
  /// Dauer einer Sprint-Runde in Sekunden.
  static const int sprintSeconds = 60;

  Timer? _timer;
  DateTime _questionStartedAt = DateTime.now();

  @override
  QuizSession build(QuizConfig arg) {
    final repository = ref.watch(questionRepositoryProvider);
    final questions = arg.mode == SessionMode.sprint
        ? repository.drawSprintQueue(arg.module)
        : repository.drawPractice(arg.module);

    ref.onDispose(() => _timer?.cancel());

    _questionStartedAt = DateTime.now();
    if (arg.mode == SessionMode.sprint) {
      _startTimer();
    }

    return QuizSession(
      mode: arg.mode,
      module: arg.module,
      questions: questions,
      remainingSeconds: arg.mode == SessionMode.sprint ? sprintSeconds : null,
    );
  }

  /// Antwort abgeben.
  ///
  /// Im Uebungsmodus wird die Loesung samt Erklaerung sofort aufgedeckt und
  /// der Nutzer geht per "Weiter" selbst zur naechsten Aufgabe. Im Sprint
  /// zaehlt Tempo - dort wird ohne Feedback direkt weitergeschaltet.
  void answer(int optionIndex) {
    if (state.status == SessionStatus.finished || state.revealed) return;

    final record = AnswerRecord(
      question: state.currentQuestion,
      selectedIndex: optionIndex,
      timeSpent: DateTime.now().difference(_questionStartedAt),
    );
    final answers = [...state.answers, record];

    if (state.mode == SessionMode.practice) {
      state = state.copyWith(
        answers: answers,
        selectedIndex: optionIndex,
        revealed: true,
      );
    } else {
      state = state.copyWith(answers: answers, selectedIndex: optionIndex);
      _advance();
    }
  }

  /// Aufgabe ueberspringen - zaehlt als nicht beantwortet.
  void skip() {
    if (state.status == SessionStatus.finished) return;

    final record = AnswerRecord(
      question: state.currentQuestion,
      selectedIndex: null,
      timeSpent: DateTime.now().difference(_questionStartedAt),
    );
    state = state.copyWith(answers: [...state.answers, record], revealed: false);
    _advance();
  }

  /// Im Uebungsmodus nach dem Aufdecken zur naechsten Aufgabe.
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
      clearSelection: true,
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
    state = state.copyWith(status: SessionStatus.finished, revealed: false);

    unawaited(
      ref.read(statsControllerProvider.notifier).recordSession(
            state.answers,
            sprintScore: state.mode == SessionMode.sprint ? state.correctCount : null,
            sprintModule: state.mode == SessionMode.sprint ? state.module : null,
          ),
    );
  }
}

final quizControllerProvider =
    AutoDisposeNotifierProvider.family<QuizController, QuizSession, QuizConfig>(
  QuizController.new,
);
