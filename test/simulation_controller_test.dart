import 'package:einstellungstest_trainer/data/simulation_blueprints.dart';
import 'package:einstellungstest_trainer/models/simulation.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/services/simulation_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    controller().answer(0);

    expect(read().answers, isEmpty);
    expect(read().stage, SimulationStage.briefing);
  });

  test('nach dem letzten Teil-Item folgt das Briefing des nächsten Teils', () {
    controller().startPart();
    expect(read().stage, SimulationStage.running);

    final questionCount = read().currentPart.questions.length;
    for (var i = 0; i < questionCount; i++) {
      controller().answer(read().currentQuestion.correctIndex);
    }

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

  test('Abbruch füllt alle offenen Aufgaben auf und wertet aus', () async {
    controller().startPart();
    controller().answer(read().currentQuestion.correctIndex);

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

  test('Ergebnis der Simulation landet in der Statistik', () async {
    controller().startPart();
    final questionCount = read().currentPart.questions.length;
    for (var i = 0; i < questionCount; i++) {
      controller().answer(read().currentQuestion.correctIndex);
    }
    controller().abort();
    await Future<void>.delayed(Duration.zero);

    final stats = container.read(statsControllerProvider);
    expect(stats.totalCorrect, questionCount);
    expect(stats.totalAnswered, questionCount);
  });
}
