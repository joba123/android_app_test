import 'dart:async';

import 'package:einstellungstest_trainer/data/simulation_blueprints.dart';
import 'package:einstellungstest_trainer/models/answer_record.dart';
import 'package:einstellungstest_trainer/models/simulation.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Steuert eine Testsimulation ueber mehrere Testteile hinweg.
///
/// Der entscheidende Unterschied zum Sprint: Der Countdown gilt jeweils fuer
/// einen Testteil. Laeuft er ab, werden die restlichen Aufgaben des Teils
/// automatisch als "nicht beantwortet" verbucht und es geht zum naechsten
/// Teil - genau wie in einem echten Auswahlverfahren.
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

  void answer(int optionIndex) {
    if (state.stage != SimulationStage.running) return;

    _record(optionIndex);
    _advance();
  }

  /// In der Simulation gibt es kein Zurueck - Ueberspringen kostet die Aufgabe.
  void skip() {
    if (state.stage != SimulationStage.running) return;

    _record(null);
    _advance();
  }

  void _record(int? optionIndex) {
    final record = AnswerRecord(
      question: state.currentQuestion,
      selectedIndex: optionIndex,
      timeSpent: DateTime.now().difference(_questionStartedAt),
    );
    state = state.copyWith(
      answers: [...state.answers, record],
      selectedIndex: optionIndex,
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
      clearSelection: true,
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

  /// Schliesst den laufenden Teil ab und fuellt unbearbeitete Aufgaben auf.
  void _completeCurrentPart() {
    _timer?.cancel();

    final questions = state.currentPart.questions;
    final answeredInPart = state.answers.length - state.answersBeforeCurrentPart;

    final answers = [...state.answers];
    for (var index = answeredInPart; index < questions.length; index++) {
      answers.add(
        AnswerRecord(
          question: questions[index],
          selectedIndex: null,
          timeSpent: Duration.zero,
        ),
      );
    }

    if (state.isLastPart) {
      state = state.copyWith(
        answers: answers,
        stage: SimulationStage.finished,
        clearSelection: true,
      );
      unawaited(
        ref.read(statsControllerProvider.notifier).recordSession(answers),
      );
      return;
    }

    final nextIndex = state.partIndex + 1;
    state = state.copyWith(
      answers: answers,
      partIndex: nextIndex,
      questionIndex: 0,
      clearSelection: true,
      stage: SimulationStage.briefing,
      remainingSeconds: state.loadedParts[nextIndex].part.duration.inSeconds,
    );
  }

  /// Simulation vorzeitig beenden - alle offenen Aufgaben zaehlen als falsch.
  void abort() {
    _timer?.cancel();
    while (state.stage != SimulationStage.finished) {
      _completeCurrentPart();
    }
  }
}

final simulationControllerProvider = AutoDisposeNotifierProvider.family<
    SimulationController, SimulationSession, String>(SimulationController.new);
