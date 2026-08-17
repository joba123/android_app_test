import 'dart:math';

import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/review_book.dart';
import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/services/question_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final now = DateTime(2026, 5, 1, 12);

  TrainingSession sessionOf(
    List<QuestionResult> results, {
    String id = 'session',
  }) {
    return TrainingSession(
      id: id,
      mode: SessionMode.practice,
      module: TrainingModule.logic,
      startedAt: now.subtract(const Duration(minutes: 5)),
      finishedAt: now,
      results: results,
    );
  }

  QuestionResult result(
    String id, {
    required bool correct,
    SubCategory subCategory = SubCategory.numberSequences,
  }) {
    return QuestionResult(
      questionId: id,
      subCategory: subCategory,
      answered: true,
      correct: correct,
      timeSpent: const Duration(seconds: 8),
    );
  }

  group('Ziehen der Wiederholung', () {
    final repository = QuestionRepository(random: Random(7));

    test('ohne Vorwissen kommt eine gemischte Runde statt einer leeren', () {
      final questions = repository.drawReview(
        const ReviewBook.empty(),
        count: 10,
      );

      expect(questions, hasLength(10));
    });

    test('stellt die fälligen Aufgaben tatsächlich', () {
      final book = const ReviewBook.empty().applySession(
        sessionOf([
          result('logic_seq_01', correct: false),
          result('logic_seq_02', correct: false),
        ]),
        at: now,
      );

      final questions = repository.drawReview(book, count: 10);
      final ids = questions.map((question) => question.id).toSet();

      expect(ids, containsAll(['logic_seq_01', 'logic_seq_02']));
    });

    test('stellt keine Aufgabe doppelt', () {
      final book = const ReviewBook.empty().applySession(
        sessionOf([
          for (var index = 1; index <= 5; index++)
            result(
              'logic_seq_0$index',
              correct: false,
            ),
        ]),
        at: now,
      );

      final questions = repository.drawReview(book, count: 10);
      final ids = questions.map((question) => question.id).toList();

      expect(ids.toSet(), hasLength(ids.length));
    });

    test('zieht für ein schwaches Mathe-Thema neue Aufgaben', () {
      // Der Fall, fuer den die Themen-Ebene ueberhaupt existiert: Die alte
      // Aufgabe gibt es nicht mehr, den Aufgabentyp sehr wohl.
      final book = const ReviewBook.empty().applySession(
        sessionOf([
          for (var index = 0; index < 12; index++)
            result(
              'math_rule_of_three_g$index',
              correct: false,
              subCategory: SubCategory.ruleOfThree,
            ),
        ]),
        at: now,
      );

      final questions = repository.drawReview(book, count: 8);

      expect(questions, isNotEmpty);
      expect(
        questions.every(
          (question) => question.subCategory == SubCategory.ruleOfThree,
        ),
        isTrue,
      );
      // Frisch erzeugt, nicht die alten Kennungen.
      expect(
        questions.any((question) => question.id == 'math_rule_of_three_g0'),
        isFalse,
      );
    });

    test('verteilt auf mehrere Schwachstellen, statt eine auszureizen', () {
      var book = const ReviewBook.empty();
      for (final topic in [SubCategory.ruleOfThree, SubCategory.percentage]) {
        book = book.applySession(
          sessionOf([
            for (var index = 0; index < 12; index++)
              result(
                'math_${topic.id}_g$index',
                correct: false,
                subCategory: topic,
              ),
          ]),
          at: now,
        );
      }

      final questions = repository.drawReview(book, count: 10);
      final topics = questions.map((question) => question.subCategory).toSet();

      expect(topics, hasLength(2));
    });

    test('hält den gewünschten Umfang ein', () {
      final book = const ReviewBook.empty().applySession(
        sessionOf([
          for (var index = 1; index <= 5; index++)
            result('logic_seq_0$index', correct: false),
          for (var index = 0; index < 12; index++)
            result(
              'math_percentage_g$index',
              correct: false,
              subCategory: SubCategory.percentage,
            ),
        ]),
        at: now,
      );

      expect(repository.drawReview(book, count: 6), hasLength(6));
      expect(repository.drawReview(book, count: 0), isEmpty);
    });

    test('eine gekonnte Aufgabe kommt nicht mehr', () {
      var book = const ReviewBook.empty();
      var moment = now;

      for (var round = 0; round < QuestionMemory.masteredStreak; round++) {
        book = book.applySession(
          sessionOf([result('logic_seq_01', correct: true)], id: 's$round'),
          at: moment,
        );
        moment = book.memories['logic_seq_01']!.dueAt;
      }

      expect(book.memories['logic_seq_01']!.isMastered, isTrue);
      expect(book.dueCount(moment), 0);
    });
  });

  group('Verdrahtung', () {
    late ProviderContainer container;

    Future<ProviderContainer> build() async {
      final prefs = await SharedPreferences.getInstance();
      return ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
    }

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = await build();
    });

    tearDown(() => container.dispose());

    test('eine abgeschlossene Runde schreibt das Wissen fort', () async {
      await container.read(statsControllerProvider.notifier).record(
            sessionOf([
              result('logic_seq_01', correct: false),
              result('logic_seq_02', correct: true),
            ]),
          );

      final book = container.read(reviewBookProvider);
      expect(book.memories['logic_seq_01']?.wrongCount, 1);
      expect(container.read(dueReviewCountProvider), 1);
    });

    test('das Wissen überdauert einen Neustart', () async {
      await container.read(statsControllerProvider.notifier).record(
            sessionOf([result('logic_seq_01', correct: false)]),
          );

      container.dispose();
      container = await build();

      expect(container.read(dueReviewCountProvider), 1);
      expect(
        container.read(reviewBookProvider).memories['logic_seq_01']?.wrongCount,
        1,
      );
    });

    test('Zurücksetzen räumt auch die Fehler ab', () async {
      await container.read(statsControllerProvider.notifier).record(
            sessionOf([result('logic_seq_01', correct: false)]),
          );
      expect(container.read(dueReviewCountProvider), 1);

      await container.read(statsControllerProvider.notifier).reset();

      expect(container.read(dueReviewCountProvider), 0);
      expect(container.read(reviewBookProvider).memories, isEmpty);
    });

    test('der Wiederholungs-Umfang zieht aus dem Fehlerbestand', () async {
      await container.read(statsControllerProvider.notifier).record(
            sessionOf([
              result('logic_seq_01', correct: false),
              result('logic_seq_02', correct: false),
            ]),
          );

      final questions = container.read(questionRepositoryProvider).drawForScope(
            const PracticeScope.review(),
            count: 10,
            reviewBook: container.read(reviewBookProvider),
          );

      expect(
        questions.map((question) => question.id),
        containsAll(['logic_seq_01', 'logic_seq_02']),
      );
    });
  });

  group('Umfang der Wiederholung', () {
    test('trägt eine eigene Bezeichnung und einen eigenen Schlüssel', () {
      const scope = PracticeScope.review();

      expect(scope.label, 'Deine Fehler');
      expect(scope.shortLabel, 'Deine Fehler');
      expect(scope.storageKey, 'review');
      // Nicht mit dem Misch-Modus zu verwechseln, obwohl beide modullos sind.
      expect(scope.isMixed, isFalse);
      expect(scope == const PracticeScope.mixed(), isFalse);
    });
  });
}
