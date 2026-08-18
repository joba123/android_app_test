import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/review_book.dart';
import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/todays_plan.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 5, 14, 18);

  /// Ein Buch mit [wrong] falschen und [right] richtigen Antworten zu einem
  /// Thema.
  ReviewBook bookWith({
    required SubCategory subCategory,
    required int wrong,
    int right = 0,
    String prefix = 'q',
  }) {
    return const ReviewBook.empty().applySession(
      TrainingSession(
        id: 'session',
        mode: SessionMode.practice,
        module: TrainingModule.logic,
        startedAt: DateTime(2026, 5, 14, 17),
        finishedAt: DateTime(2026, 5, 14, 17, 30),
        results: [
          for (var index = 0; index < wrong + right; index++)
            QuestionResult(
              questionId: '$prefix$index',
              subCategory: subCategory,
              answered: true,
              correct: index >= wrong,
              timeSpent: const Duration(seconds: 10),
            ),
        ],
      ),
      at: now,
    );
  }

  group('Erster Start', () {
    test('schlägt eine kurze Einstiegsrunde vor', () {
      final plan = TodaysPlan.from(
        book: const ReviewBook.empty(),
        totalAnswered: 0,
        now: now,
      );

      expect(plan.reason, PlanReason.firstRound);
      expect(plan.length, TodaysPlan.firstRoundLength);
      expect(plan.scope.isMixed, isTrue);
      expect(plan.title, '10 Aufgaben zum Einstieg');
      expect(plan.reasonLabel, 'quer durch alle drei Bereiche');
    });

    test('nennt eine Zeitschätzung', () {
      final plan = TodaysPlan.from(
        book: const ReviewBook.empty(),
        totalAnswered: 0,
        now: now,
      );

      // Zehn Aufgaben zu 25 Sekunden sind gut vier Minuten.
      expect(plan.estimatedMinutes, 4);
    });

    test('rechnet mit dem gemessenen Tempo, wenn es eines gibt', () {
      final plan = TodaysPlan.from(
        book: const ReviewBook.empty(),
        totalAnswered: 0,
        now: now,
        measuredPace: const Duration(seconds: 60),
      );

      expect(plan.estimatedMinutes, 10);
    });
  });

  group('Fehler gehen vor', () {
    test('genug fällige Fehler ergeben eine Wiederholungsrunde', () {
      final book = bookWith(
        subCategory: SubCategory.numberSequences,
        wrong: 8,
      );

      final plan = TodaysPlan.from(book: book, totalAnswered: 8, now: now);

      expect(plan.reason, PlanReason.reviewDue);
      expect(plan.scope.isReview, isTrue);
      expect(plan.dueErrors, 8);
      expect(plan.reasonLabel, 'was zuletzt schiefging');
    });

    test('die Runde ist nie länger als die Zahl der Fehler', () {
      final book = bookWith(
        subCategory: SubCategory.numberSequences,
        wrong: 6,
      );

      final plan = TodaysPlan.from(book: book, totalAnswered: 6, now: now);

      expect(plan.length, 6);
    });

    test('und nie länger als eine normale Runde', () {
      final book = bookWith(
        subCategory: SubCategory.numberSequences,
        wrong: 40,
      );

      final plan = TodaysPlan.from(book: book, totalAnswered: 40, now: now);

      expect(plan.length, TodaysPlan.regularLength);
    });

    test('wenige Fehler lösen noch keine eigene Runde aus', () {
      // Zwei Fehler sind kein Grund, eine ganze Runde daraus zu machen.
      final book = bookWith(
        subCategory: SubCategory.numberSequences,
        wrong: 2,
        right: 10,
      );

      final plan = TodaysPlan.from(book: book, totalAnswered: 12, now: now);

      expect(plan.reason, isNot(PlanReason.reviewDue));
    });
  });

  group('Schwaches Thema', () {
    test('wird vorgeschlagen, wenn keine Fehler drängen', () {
      // Jede Aufgabe einmal falsch, dann einmal richtig: Die Wiederholung
      // ist damit auf morgen geschoben (nicht mehr faellig), die Quote des
      // Themas liegt aber bei 50 % und damit unter der Schwelle.
      TrainingSession round(String id, {required bool correct}) {
        return TrainingSession(
          id: id,
          mode: SessionMode.practice,
          module: TrainingModule.math,
          startedAt: now,
          finishedAt: now,
          results: [
            for (var index = 0; index < 10; index++)
              QuestionResult(
                questionId: 'dreisatz_$index',
                subCategory: SubCategory.ruleOfThree,
                answered: true,
                correct: correct,
                timeSpent: const Duration(seconds: 10),
              ),
          ],
        );
      }

      var book = const ReviewBook.empty()
          .applySession(round('falsch', correct: false), at: now);
      book = book.applySession(round('richtig', correct: true), at: now);

      expect(book.dueCount(now), 0, reason: 'Fehler sind vertagt');
      expect(book.masteryOf(SubCategory.ruleOfThree).accuracy, 0.5);

      final plan = TodaysPlan.from(book: book, totalAnswered: 20, now: now);

      expect(plan.reason, PlanReason.weakTopic);
      expect(plan.scope.subCategory, SubCategory.ruleOfThree);
      expect(plan.reasonLabel, 'dein schwächstes Thema');
      expect(plan.accuracyLabel, '50 %');
    });
  });

  group('Nichts Auffälliges', () {
    test('führt zu einer gemischten Runde', () {
      final book = bookWith(
        subCategory: SubCategory.spelling,
        wrong: 0,
        right: 12,
      );

      final plan = TodaysPlan.from(book: book, totalAnswered: 12, now: now);

      expect(plan.reason, PlanReason.keepGoing);
      expect(plan.scope.isMixed, isTrue);
      expect(plan.length, TodaysPlan.regularLength);
    });
  });

  group('Kennzahlen unter dem Vorschlag', () {
    test('zeigen keine Null-Werte', () {
      // Eine Kachel „0 offene Fehler" waere Fuellmaterial, kein Wert.
      final plan = TodaysPlan.from(
        book: const ReviewBook.empty(),
        totalAnswered: 0,
        now: now,
      );

      final facts = PlanFacts.of(plan);
      expect(facts.entries.map((entry) => entry.$2), ['Minuten']);
    });

    test('nennen Quote, Fehler und Zeit, wenn es sie gibt', () {
      const plan = TodaysPlan(
        // Der Umfang spielt fuer die Kennzahlen keine Rolle.
        scope: PracticeScope.mixed(),
        length: 20,
        reason: PlanReason.weakTopic,
        topicAccuracy: 0.41,
        dueErrors: 34,
        estimatedMinutes: 9,
      );

      final facts = PlanFacts.of(plan);

      expect(facts.entries, hasLength(3));
      expect(facts.entries[0], ('41 %', 'aktuell'));
      expect(facts.entries[1], ('34', 'offene Fehler'));
      expect(facts.entries[2], ('~9', 'Minuten'));
    });
  });
}
