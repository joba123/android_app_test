import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/quiz_session.dart';
import 'package:einstellungstest_trainer/models/simulation.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/services/question_repository.dart';
import 'package:einstellungstest_trainer/services/quiz_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

/// Liefert immer denselben, im Test vorgegebenen Aufgabensatz. Damit lassen
/// sich Abläufe prüfen, die von einem bestimmten Antwortformat abhängen.
class _FixedRepository extends QuestionRepository {
  _FixedRepository(this.questions);

  final List<Question> questions;

  @override
  List<Question> draw({
    required TrainingModule module,
    required int count,
    List<SubCategory> subCategories = const [],
    Difficulty? difficulty,
  }) =>
      questions;

  @override
  List<Question> drawForScope(
    PracticeScope scope, {
    int count = QuestionRepository.practiceLength,
    Difficulty? difficulty,
  }) =>
      questions;

  @override
  List<Question> drawSprintQueue(TrainingModule module) => questions;

  @override
  List<Question> drawForPart(SimulationPart part) => questions;
}

void main() {
  late ProviderContainer container;

  Future<ProviderContainer> buildContainer({
    List<Question>? questions,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    return ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        if (questions != null)
          questionRepositoryProvider
              .overrideWithValue(_FixedRepository(questions)),
      ],
    );
  }

  setUp(() async {
    container = await buildContainer();
    addTearDown(container.dispose);
  });

  /// Hält den autoDispose-Provider am Leben, solange der Test läuft.
  QuizConfig keepAlive(
    SessionMode mode,
    TrainingModule module, {
    int length = QuizController.defaultPracticeLength,
  }) {
    final config = (
      mode: mode,
      scope: PracticeScope.module(module),
      length: length,
    );
    final subscription = container.listen(
      quizControllerProvider(config),
      (_, __) {},
    );
    addTearDown(subscription.close);
    return config;
  }

  /// Wie [keepAlive], aber für beliebige Übungsumfänge.
  QuizConfig keepAliveScope(PracticeScope scope, {int length = 20}) {
    final config = (mode: SessionMode.practice, scope: scope, length: length);
    final subscription = container.listen(
      quizControllerProvider(config),
      (_, __) {},
    );
    addTearDown(subscription.close);
    return config;
  }

  group('Übungsumfang', () {
    test('die gewählte Aufgabenzahl bestimmt die Rundenlänge', () {
      for (final length in [10, 20, 30]) {
        final config = keepAliveScope(
          const PracticeScope.module(TrainingModule.logic),
          length: length,
        );

        expect(
          container.read(quizControllerProvider(config)).totalQuestions,
          length,
        );
      }
    });

    test('ein knappes Thema kürzt die Runde, statt zu scheitern', () {
      final config = keepAliveScope(
        PracticeScope.subCategory(SubCategory.grammar),
        length: 30,
      );
      final session = container.read(quizControllerProvider(config));

      expect(session.totalQuestions, lessThan(30));
      expect(session.totalQuestions, greaterThan(0));
      for (final question in session.questions) {
        expect(question.subCategory, SubCategory.grammar);
      }
    });

    test('der Misch-Modus zieht aus allen Modulen', () {
      final config = keepAliveScope(const PracticeScope.mixed(), length: 30);
      final session = container.read(quizControllerProvider(config));

      expect(
        session.questions.map((question) => question.module).toSet(),
        TrainingModule.values.toSet(),
      );
    });

    test('die Fortschrittsanzeige zählt ab eins', () {
      final config = keepAliveScope(
        const PracticeScope.module(TrainingModule.logic),
        length: 20,
      );
      final controller = container.read(quizControllerProvider(config).notifier);

      expect(container.read(quizControllerProvider(config)).currentNumber, 1);

      controller.answer(
        correctResponse(
          container.read(quizControllerProvider(config)).currentQuestion,
        ),
      );
      controller.next();

      final session = container.read(quizControllerProvider(config));
      expect(session.currentNumber, 2);
      expect(session.totalQuestions, 20);
      expect(session.progress, closeTo(2 / 20, 1e-9));
    });
  });

  group('Auswertung der Runde', () {
    test('am Ende steht eine Zusammenfassung bereit', () {
      final config = keepAliveScope(
        const PracticeScope.module(TrainingModule.logic),
        length: 10,
      );
      final controller = container.read(quizControllerProvider(config).notifier);

      expect(container.read(quizControllerProvider(config)).summary, isNull);

      for (var i = 0; i < 10; i++) {
        final current = container.read(quizControllerProvider(config));
        controller.answer(correctResponse(current.currentQuestion));
        controller.next();
      }

      final summary = container.read(quizControllerProvider(config)).summary;
      expect(summary, isNotNull);
      expect(summary!.total, 10);
      expect(summary.correctCount, 10);
      expect(summary.accuracy, 1.0);
      expect(summary.mode, SessionMode.practice);
      expect(summary.module, TrainingModule.logic);
    });

    test('Fehlerquote und Zeiten sind in sich stimmig', () {
      final config = keepAliveScope(
        const PracticeScope.module(TrainingModule.logic),
        length: 10,
      );
      final controller = container.read(quizControllerProvider(config).notifier);

      // Zwei richtig, eine falsch, eine übersprungen, Rest richtig.
      for (var i = 0; i < 10; i++) {
        final current = container.read(quizControllerProvider(config));
        if (i == 2) {
          controller.answer(wrongResponse(current.currentQuestion));
        } else if (i == 5) {
          controller.skip();
          continue;
        } else {
          controller.answer(correctResponse(current.currentQuestion));
        }
        controller.next();
      }

      final summary = container.read(quizControllerProvider(config)).summary!;

      expect(summary.total, 10);
      expect(summary.correctCount, 8);
      expect(summary.wrongCount, 1);
      expect(summary.skippedCount, 1);
      expect(
        summary.correctCount + summary.wrongCount + summary.skippedCount,
        summary.total,
      );
      // Fehlerquote ist die Gegenzahl zur Trefferquote.
      expect(1 - summary.accuracy, closeTo(0.2, 1e-9));
      expect(summary.duration, greaterThanOrEqualTo(Duration.zero));
      expect(
        summary.averageTimePerQuestion,
        greaterThanOrEqualTo(Duration.zero),
      );
    });

    test('eine gemischte Runde schlüsselt nach Thema auf', () {
      final config = keepAliveScope(const PracticeScope.mixed(), length: 12);
      final controller = container.read(quizControllerProvider(config).notifier);

      final total =
          container.read(quizControllerProvider(config)).totalQuestions;
      for (var i = 0; i < total; i++) {
        final current = container.read(quizControllerProvider(config));
        controller.answer(correctResponse(current.currentQuestion));
        controller.next();
      }

      final summary = container.read(quizControllerProvider(config)).summary!;
      expect(summary.resultsBySubCategory.length, greaterThan(1));
      expect(summary.module, isNull);
    });
  });

  group('Übungsmodus', () {
    test('deckt nach der Antwort die Lösung auf und zählt sie', () {
      final config = keepAlive(SessionMode.practice, TrainingModule.math);
      final controller = container.read(quizControllerProvider(config).notifier);

      final before = container.read(quizControllerProvider(config));
      expect(before.revealed, isFalse);
      expect(before.remainingSeconds, isNull);

      controller.answer(correctResponse(before.currentQuestion));

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
      final question =
          container.read(quizControllerProvider(config)).currentQuestion;

      controller.answer(correctResponse(question));
      controller.answer(wrongResponse(question));

      expect(container.read(quizControllerProvider(config)).answers.length, 1);
    });

    test('"Weiter" schaltet zur nächsten Aufgabe', () {
      final config = keepAlive(SessionMode.practice, TrainingModule.logic);
      final controller = container.read(quizControllerProvider(config).notifier);

      controller.answer(
        correctResponse(
          container.read(quizControllerProvider(config)).currentQuestion,
        ),
      );
      controller.next();

      final session = container.read(quizControllerProvider(config));
      expect(session.currentIndex, 1);
      expect(session.revealed, isFalse);
      expect(session.response, isNull);
    });

    test('beendet die Runde nach der letzten Aufgabe', () {
      final config = keepAlive(SessionMode.practice, TrainingModule.language);
      final controller = container.read(quizControllerProvider(config).notifier);
      final total =
          container.read(quizControllerProvider(config)).questions.length;

      for (var i = 0; i < total; i++) {
        final current = container.read(quizControllerProvider(config));
        controller.answer(correctResponse(current.currentQuestion));
        controller.next();
      }

      final session = container.read(quizControllerProvider(config));
      expect(session.status, SessionStatus.finished);
      expect(session.correctCount, total);
    });
  });

  group('Zahleneingabe', () {
    setUp(() async {
      container = await buildContainer(
        questions: [
          numericQuestion(id: 'n1', correctValue: 84, unit: 'km/h'),
          numericQuestion(id: 'n2', correctValue: 2.4, tolerance: 0.01),
        ],
      );
      addTearDown(container.dispose);
    });

    test('eine getippte Zahl wird gelesen und als richtig gewertet', () {
      final config = keepAlive(SessionMode.practice, TrainingModule.math);
      final controller = container.read(quizControllerProvider(config).notifier);

      final accepted = controller.submitNumber('84');

      expect(accepted, isTrue);
      final session = container.read(quizControllerProvider(config));
      expect(session.revealed, isTrue);
      expect(session.correctCount, 1);
      expect(session.answers.single.responseText, '84 km/h');
    });

    test('deutsche Schreibweise mit Komma wird akzeptiert', () {
      final config = keepAlive(SessionMode.practice, TrainingModule.math);
      final controller = container.read(quizControllerProvider(config).notifier);

      controller.submitNumber('84');
      controller.next();

      expect(controller.submitNumber('2,4'), isTrue);
      expect(container.read(quizControllerProvider(config)).correctCount, 2);
    });

    test('eine unlesbare Eingabe lässt die Aufgabe offen', () {
      final config = keepAlive(SessionMode.practice, TrainingModule.math);
      final controller = container.read(quizControllerProvider(config).notifier);

      final accepted = controller.submitNumber('weiß nicht');

      expect(accepted, isFalse);
      final session = container.read(quizControllerProvider(config));
      expect(session.answers, isEmpty);
      expect(session.revealed, isFalse);
    });

    test('eine falsche Zahl wird als falsch gewertet', () {
      final config = keepAlive(SessionMode.practice, TrainingModule.math);
      final controller = container.read(quizControllerProvider(config).notifier);

      controller.submitNumber('80');

      final session = container.read(quizControllerProvider(config));
      expect(session.answers.single.isAnswered, isTrue);
      expect(session.answers.single.isCorrect, isFalse);
      expect(session.correctCount, 0);
    });
  });

  group('Sprint-Modus', () {
    test('startet mit 60 Sekunden und schaltet ohne Feedback weiter', () {
      final config = keepAlive(SessionMode.sprint, TrainingModule.math);
      final controller = container.read(quizControllerProvider(config).notifier);

      final before = container.read(quizControllerProvider(config));
      expect(before.remainingSeconds, QuizController.sprintSeconds);

      controller.answer(correctResponse(before.currentQuestion));

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

      for (var i = 0; i < 2; i++) {
        final current = container.read(quizControllerProvider(config));
        controller.answer(correctResponse(current.currentQuestion));
      }

      controller.finishEarly();
      // Das Persistieren läuft asynchron an.
      await Future<void>.delayed(Duration.zero);

      final stats = container
          .read(statsControllerProvider)
          .forModule(TrainingModule.math);
      expect(stats.bestSprintScore, 2);
      expect(stats.answered, 2);
      expect(stats.correct, 2);
    });

    test('legt einen Eintrag im Sitzungsverlauf an', () async {
      final config = keepAlive(SessionMode.sprint, TrainingModule.logic);
      final controller = container.read(quizControllerProvider(config).notifier);

      final current = container.read(quizControllerProvider(config));
      controller.answer(correctResponse(current.currentQuestion));
      controller.finishEarly();
      await Future<void>.delayed(Duration.zero);

      final history = container.read(sessionHistoryProvider);
      expect(history, hasLength(1));
      expect(history.single.mode, SessionMode.sprint);
      expect(history.single.module, TrainingModule.logic);
      expect(history.single.correctCount, 1);
    });
  });
}
