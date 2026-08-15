import 'package:einstellungstest_trainer/models/quiz_session.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/services/quiz_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
  });

  /// Haelt den autoDispose-Provider am Leben, solange der Test laeuft.
  QuizConfig keepAlive(SessionMode mode, TrainingModule module) {
    final config = (mode: mode, module: module);
    final subscription = container.listen(
      quizControllerProvider(config),
      (_, __) {},
    );
    addTearDown(subscription.close);
    return config;
  }

  group('Übungsmodus', () {
    test('deckt nach der Antwort die Lösung auf und zählt sie', () {
      final config = keepAlive(SessionMode.practice, TrainingModule.math);
      final controller = container.read(quizControllerProvider(config).notifier);

      final before = container.read(quizControllerProvider(config));
      expect(before.revealed, isFalse);
      expect(before.remainingSeconds, isNull);

      controller.answer(before.currentQuestion.correctIndex);

      final after = container.read(quizControllerProvider(config));
      expect(after.revealed, isTrue);
      expect(after.correctCount, 1);
      expect(after.answers.length, 1);
      // Ohne "Weiter" bleibt die Aufgabe stehen.
      expect(after.currentIndex, before.currentIndex);
    });

    test('eine zweite Antwort auf dieselbe Aufgabe wird ignoriert', () {
      final config = keepAlive(SessionMode.practice, TrainingModule.math);
      final controller = container.read(quizControllerProvider(config).notifier);
      final question = container.read(quizControllerProvider(config)).currentQuestion;

      controller.answer(question.correctIndex);
      controller.answer((question.correctIndex + 1) % question.options.length);

      expect(container.read(quizControllerProvider(config)).answers.length, 1);
    });

    test('"Weiter" schaltet zur nächsten Aufgabe', () {
      final config = keepAlive(SessionMode.practice, TrainingModule.logic);
      final controller = container.read(quizControllerProvider(config).notifier);

      controller.answer(0);
      controller.next();

      final session = container.read(quizControllerProvider(config));
      expect(session.currentIndex, 1);
      expect(session.revealed, isFalse);
      expect(session.selectedIndex, isNull);
    });

    test('beendet die Runde nach der letzten Aufgabe', () {
      final config = keepAlive(SessionMode.practice, TrainingModule.language);
      final controller = container.read(quizControllerProvider(config).notifier);
      final total = container.read(quizControllerProvider(config)).questions.length;

      for (var i = 0; i < total; i++) {
        final current = container.read(quizControllerProvider(config));
        controller.answer(current.currentQuestion.correctIndex);
        controller.next();
      }

      final session = container.read(quizControllerProvider(config));
      expect(session.status, SessionStatus.finished);
      expect(session.correctCount, total);
    });
  });

  group('Sprint-Modus', () {
    test('startet mit 60 Sekunden und schaltet ohne Feedback weiter', () {
      final config = keepAlive(SessionMode.sprint, TrainingModule.math);
      final controller = container.read(quizControllerProvider(config).notifier);

      final before = container.read(quizControllerProvider(config));
      expect(before.remainingSeconds, QuizController.sprintSeconds);

      controller.answer(before.currentQuestion.correctIndex);

      final after = container.read(quizControllerProvider(config));
      expect(after.revealed, isFalse);
      expect(after.currentIndex, 1);
      expect(after.correctCount, 1);
    });

    test('Überspringen zählt als nicht beantwortet', () {
      final config = keepAlive(SessionMode.sprint, TrainingModule.logic);
      final controller = container.read(quizControllerProvider(config).notifier);

      controller.skip();

      final session = container.read(quizControllerProvider(config));
      expect(session.answers.single.isAnswered, isFalse);
      expect(session.answers.single.isCorrect, isFalse);
      expect(session.answeredCount, 0);
      expect(session.currentIndex, 1);
    });

    test('vorzeitiges Beenden schreibt den Bestwert in die Statistik',
        () async {
      final config = keepAlive(SessionMode.sprint, TrainingModule.math);
      final controller = container.read(quizControllerProvider(config).notifier);

      final first = container.read(quizControllerProvider(config));
      controller.answer(first.currentQuestion.correctIndex);
      final second = container.read(quizControllerProvider(config));
      controller.answer(second.currentQuestion.correctIndex);

      controller.finishEarly();
      // Das Persistieren laeuft asynchron an.
      await Future<void>.delayed(Duration.zero);

      final stats =
          container.read(statsControllerProvider).forModule(TrainingModule.math);
      expect(stats.bestSprintScore, 2);
      expect(stats.answered, 2);
      expect(stats.correct, 2);
    });
  });
}
