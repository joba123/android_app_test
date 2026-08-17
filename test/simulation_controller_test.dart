import 'package:einstellungstest_trainer/data/simulation_blueprints.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/models/simulation.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/services/simulation_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

void main() {
  late ProviderContainer container;

  const blueprint = SimulationBlueprints.math;
  final provider = simulationControllerProvider(blueprint.id);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    final subscription = container.listen(provider, (_, __) {});
    addTearDown(subscription.close);
  });

  SimulationSession read() => container.read(provider);

  SimulationController controller() => container.read(provider.notifier);

  /// Beantwortet den laufenden Testteil vollständig richtig.
  int answerCurrentPartCorrectly() {
    final questionCount = read().currentPart.questions.length;
    for (var i = 0; i < questionCount; i++) {
      controller().answer(correctResponse(read().currentQuestion));
    }
    return questionCount;
  }

  test('startet im Briefing mit der Zeit des ersten Teils', () {
    final session = read();

    expect(session.stage, SimulationStage.briefing);
    expect(session.partIndex, 0);
    expect(session.remainingSeconds, blueprint.parts.first.duration.inSeconds);
    expect(session.loadedParts.length, blueprint.parts.length);
  });

  test('Aufgaben werden pro Teil in der geforderten Anzahl gezogen', () {
    final session = read();

    for (var i = 0; i < blueprint.parts.length; i++) {
      expect(
        session.loadedParts[i].questions.length,
        blueprint.parts[i].questionCount,
      );
    }
  });

  test('vor dem Start passiert beim Antworten nichts', () {
    controller().answer(const ChoiceResponse(0));

    expect(read().answers, isEmpty);
    expect(read().stage, SimulationStage.briefing);
  });

  test('eine Zahleneingabe vor dem Start wird ebenfalls abgewiesen', () {
    expect(controller().submitNumber('42'), isFalse);
    expect(read().answers, isEmpty);
  });

  test('nach dem letzten Teil-Item folgt das Briefing des nächsten Teils', () {
    controller().startPart();
    expect(read().stage, SimulationStage.running);

    final questionCount = answerCurrentPartCorrectly();

    final session = read();
    expect(session.stage, SimulationStage.briefing);
    expect(session.partIndex, 1);
    expect(session.questionIndex, 0);
    expect(session.answers.length, questionCount);
    expect(session.correctCount, questionCount);
    expect(session.remainingSeconds, blueprint.parts[1].duration.inSeconds);
  });

  test('Überspringen zählt als nicht beantwortet', () {
    controller().startPart();
    controller().skip();

    final record = read().answers.single;
    expect(record.isAnswered, isFalse);
    expect(record.isCorrect, isFalse);
  });

  test('eine unlesbare Zahleneingabe verbraucht die Aufgabe nicht', () {
    controller().startPart();

    // Der erste Teil besteht aus Grundrechenarten - also Zahleneingabe.
    expect(read().currentQuestion.isNumericInput, isTrue);
    expect(controller().submitNumber('keine Zahl'), isFalse);

    expect(read().answers, isEmpty);
    expect(read().questionIndex, 0);
  });

  test('Abbruch füllt alle offenen Aufgaben auf und wertet aus', () async {
    controller().startPart();
    controller().answer(correctResponse(read().currentQuestion));

    controller().abort();
    await Future<void>.delayed(Duration.zero);

    final session = read();
    expect(session.stage, SimulationStage.finished);
    // Jede Aufgabe jedes Teils ist protokolliert - auch die nie gesehenen.
    expect(session.answers.length, session.totalQuestions);
    expect(session.correctCount, 1);

    final unanswered =
        session.answers.where((answer) => !answer.isAnswered).length;
    expect(unanswered, session.totalQuestions - 1);
  });

  test('Auswertung schlüsselt korrekt nach Teilen auf', () {
    controller().abort();

    final results = read().partResults;
    expect(results.length, blueprint.parts.length);

    for (var i = 0; i < results.length; i++) {
      expect(results[i].part.title, blueprint.parts[i].title);
      expect(results[i].total, blueprint.parts[i].questionCount);
    }
  });

  group('Pausieren', () {
    test('nur aus dem laufenden Teil heraus möglich', () {
      // Im Briefing läuft noch keine Uhr, es gibt nichts zu pausieren.
      controller().pause();
      expect(read().stage, SimulationStage.briefing);
      expect(read().pauseCount, 0);

      controller().startPart();
      controller().pause();
      expect(read().stage, SimulationStage.paused);
      expect(read().pauseCount, 1);
    });

    test('während der Pause werden Antworten abgewiesen', () {
      controller().startPart();
      controller().answer(correctResponse(read().currentQuestion));
      final answeredBefore = read().answers.length;

      controller().pause();
      controller().answer(correctResponse(read().currentQuestion));
      controller().skip();
      expect(controller().submitNumber('42'), isFalse);

      expect(read().answers.length, answeredBefore);
      expect(read().stage, SimulationStage.paused);
    });

    test('Fortsetzen bringt den Teil zurück in den Lauf', () {
      controller().startPart();
      final questionIndex = read().questionIndex;

      controller().pause();
      controller().resume();

      expect(read().stage, SimulationStage.running);
      expect(read().questionIndex, questionIndex);
      expect(read().pausedDuration, greaterThanOrEqualTo(Duration.zero));
    });

    test('jede Unterbrechung wird gezählt', () {
      controller().startPart();

      for (var i = 0; i < 3; i++) {
        controller().pause();
        controller().resume();
      }

      expect(read().pauseCount, 3);
      expect(read().wasPaused, isTrue);
    });

    test('ein durchgezogener Lauf ist nicht als pausiert markiert', () {
      controller().startPart();
      answerCurrentPartCorrectly();

      expect(read().wasPaused, isFalse);
      expect(read().pauseCount, 0);
    });

    test('Abbrechen ist auch aus der Pause heraus möglich', () async {
      controller().startPart();
      controller().pause();

      controller().abort();
      await Future<void>.delayed(Duration.zero);

      expect(read().stage, SimulationStage.finished);
      expect(read().answers.length, read().totalQuestions);
    });
  });

  group('Modulübergreifender Testteil', () {
    test('Teil 4 der Gesamtsimulation zieht aus zwei Modulen', () {
      final provider = simulationControllerProvider(
        SimulationBlueprints.full.id,
      );
      final subscription = container.listen(provider, (_, __) {});
      addTearDown(subscription.close);

      final full = container.read(provider);
      final lastPart = full.loadedParts.last;

      expect(lastPart.part.modules.length, 2);
      expect(
        lastPart.questions.map((question) => question.module).toSet().length,
        2,
        reason: 'Der Teil soll Aufgaben aus beiden Modulen enthalten',
      );
      expect(lastPart.questions.length, lastPart.part.questionCount);
    });
  });

  group('Auswertung', () {
    test('steht erst nach dem letzten Teil bereit', () {
      expect(read().summary, isNull);

      controller().startPart();
      answerCurrentPartCorrectly();
      // Nach Teil 1 folgt das Briefing von Teil 2 - noch keine Auswertung.
      expect(read().stage, SimulationStage.briefing);
      expect(read().summary, isNull);
    });

    test('schlüsselt Fehlerquote nach Kategorie auf', () async {
      controller().startPart();
      answerCurrentPartCorrectly();
      controller().abort();
      await Future<void>.delayed(Duration.zero);

      final summary = read().summary;
      expect(summary, isNotNull);

      final byModule = summary!.resultsByModule;
      expect(byModule.keys, contains(TrainingModule.math));

      // Der erste Teil wurde vollständig richtig gelöst, der Rest gar nicht.
      expect(summary.errorRate, greaterThan(0));
      expect(summary.errorRate, closeTo(1 - summary.accuracy, 1e-9));
    });

    test('liefert Zeit pro Aufgabe je Testteil', () async {
      controller().startPart();
      answerCurrentPartCorrectly();
      controller().abort();
      await Future<void>.delayed(Duration.zero);

      final results = read().partResults;
      expect(results, hasLength(SimulationBlueprints.math.parts.length));

      final firstPart = results.first;
      expect(firstPart.total, greaterThan(0));
      expect(firstPart.errorRate, closeTo(0, 1e-9));
      expect(
        firstPart.averageTimePerQuestion,
        greaterThanOrEqualTo(Duration.zero),
      );

      // Nie bearbeitete Teile haben keine Durchschnittszeit.
      expect(results.last.averageTimePerQuestion, Duration.zero);
      expect(results.last.errorRate, closeTo(1, 1e-9));
    });
  });

  test('Ergebnis der Simulation landet in der Statistik', () async {
    controller().startPart();
    final questionCount = answerCurrentPartCorrectly();
    controller().abort();
    await Future<void>.delayed(Duration.zero);

    final stats = container.read(statsControllerProvider);
    expect(stats.totalCorrect, questionCount);
    expect(stats.totalAnswered, questionCount);
  });

  test('Simulation legt einen Verlaufseintrag mit Zeitstempel an', () async {
    controller().startPart();
    answerCurrentPartCorrectly();
    controller().abort();
    await Future<void>.delayed(Duration.zero);

    final history = container.read(sessionHistoryProvider);
    expect(history, hasLength(1));

    final session = history.single;
    expect(session.mode, SessionMode.simulation);
    expect(session.module, blueprint.module);
    expect(session.total, read().totalQuestions);
    expect(session.finishedAt.isBefore(DateTime.now().add(Duration.zero)), isTrue);
    expect(session.resultsBySubCategory.keys, isNotEmpty);
  });
}
