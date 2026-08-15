import 'dart:async';

import 'package:einstellungstest_trainer/data/simulation_blueprints.dart';
import 'package:einstellungstest_trainer/models/answer_record.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/models/simulation.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Steuert eine Testsimulation über mehrere Testteile hinweg.
///
/// Der entscheidende Unterschied zum Sprint: Der Countdown gilt jeweils für
/// einen Testteil. Läuft er ab, werden die restlichen Aufgaben des Teils
/// automatisch als "nicht beantwortet" verbucht und es geht zum nächsten Teil –
/// genau wie in einem echten Auswahlverfahren.
class SimulationController
    extends AutoDisposeFamilyNotifier<SimulationSession, String> {
  Timer? _timer;
  DateTime _questionStartedAt = DateTime.now();

  @override
  SimulationSession build(String blueprintId) {
    final blueprint = SimulationBlueprints.all.firstWhere(
      (candidate) => candidate.id == blueprintId,
      orElse: () => SimulationBlueprints.full,
    );
    final repository = ref.watch(questionRepositoryProvider);

    final loadedParts = [
      for (final part in blueprint.parts)
        LoadedPart(part: part, questions: repository.drawForPart(part)),
    ];

    ref.onDispose(() => _timer?.cancel());

    return SimulationSession(
      blueprint: blueprint,
      loadedParts: loadedParts,
      startedAt: DateTime.now(),
      remainingSeconds: blueprint.parts.first.duration.inSeconds,
    );
  }

  /// Startet den aktuellen Testteil nach dem Briefing.
  void startPart() {
    if (state.stage != SimulationStage.briefing) return;

    _questionStartedAt = DateTime.now();
    state = state.copyWith(
      stage: SimulationStage.running,
      remainingSeconds: state.currentPartSpec.duration.inSeconds,
    );
    _startTimer();
  }

  void answer(Response response) {
    if (state.stage != SimulationStage.running) return;

    _record(response);
    _advance();
  }

  void selectOption(int optionIndex) => answer(ChoiceResponse(optionIndex));

  /// Gibt `false` zurück, wenn sich aus der Eingabe keine Zahl lesen lässt.
  bool submitNumber(String input) {
    if (state.stage != SimulationStage.running) return false;

    final parsed = NumericResponse.tryParse(input);
    if (parsed == null) return false;

    answer(parsed);
    return true;
  }

  /// In der Simulation gibt es kein Zurück – Überspringen kostet die Aufgabe.
  void skip() {
    if (state.stage != SimulationStage.running) return;

    _record(null);
    _advance();
  }

  void _record(Response? response) {
    final record = AnswerRecord(
      question: state.currentQuestion,
      response: response,
      timeSpent: DateTime.now().difference(_questionStartedAt),
    );
    state = state.copyWith(
      answers: [...state.answers, record],
      response: response,
      clearResponse: response == null,
    );
  }

  void _advance() {
    if (state.isLastQuestionInPart) {
      _completeCurrentPart();
      return;
    }
    _questionStartedAt = DateTime.now();
    state = state.copyWith(
      questionIndex: state.questionIndex + 1,
      clearResponse: true,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = state.remainingSeconds - 1;
      if (remaining <= 0) {
        state = state.copyWith(remainingSeconds: 0);
        _completeCurrentPart();
      } else {
        state = state.copyWith(remainingSeconds: remaining);
      }
    });
  }

  /// Schließt den laufenden Teil ab und füllt unbearbeitete Aufgaben auf.
  void _completeCurrentPart() {
    _timer?.cancel();

    final questions = state.currentPart.questions;
    final answeredInPart = state.answers.length - state.answersBeforeCurrentPart;

    final answers = [...state.answers];
    for (var index = answeredInPart; index < questions.length; index++) {
      answers.add(
        AnswerRecord(
          question: questions[index],
          response: null,
          timeSpent: Duration.zero,
        ),
      );
    }

    if (state.isLastPart) {
      state = state.copyWith(
        answers: answers,
        stage: SimulationStage.finished,
        clearResponse: true,
      );

      final session = TrainingSession.fromAnswers(
        mode: SessionMode.simulation,
        module: state.blueprint.module,
        startedAt: state.startedAt,
        finishedAt: DateTime.now(),
        answers: answers,
      );
      unawaited(ref.read(statsControllerProvider.notifier).record(session));
      return;
    }

    final nextIndex = state.partIndex + 1;
    state = state.copyWith(
      answers: answers,
      partIndex: nextIndex,
      questionIndex: 0,
      clearResponse: true,
      stage: SimulationStage.briefing,
      remainingSeconds: state.loadedParts[nextIndex].part.duration.inSeconds,
    );
  }

  /// Simulation vorzeitig beenden – alle offenen Aufgaben zählen als falsch.
  void abort() {
    _timer?.cancel();
    while (state.stage != SimulationStage.finished) {
      _completeCurrentPart();
    }
  }
}

final simulationControllerProvider = AutoDisposeNotifierProvider.family<
    SimulationController, SimulationSession, String>(SimulationController.new);
