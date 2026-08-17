import 'package:einstellungstest_trainer/models/review_book.dart';
import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 5, 1, 12);

  /// Eine Sitzung aus einzeln beschriebenen Ergebnissen.
  TrainingSession sessionOf(List<QuestionResult> results) {
    return TrainingSession(
      id: 'session',
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
    bool answered = true,
  }) {
    return QuestionResult(
      questionId: id,
      subCategory: subCategory,
      answered: answered,
      correct: correct,
      timeSpent: const Duration(seconds: 8),
    );
  }

  group('Einzelne Aufgabe merken', () {
    test('eine falsche Antwort macht die Aufgabe sofort fällig', () {
      final book = const ReviewBook.empty().applySession(
        sessionOf([result('logic_seq_01', correct: false)]),
        at: now,
      );

      final memory = book.memories['logic_seq_01']!;
      expect(memory.wrongCount, 1);
      expect(memory.streak, 0);
      expect(memory.isDue(now), isTrue);
    });

    test('eine richtige Antwort schiebt sie einen Tag nach hinten', () {
      final book = const ReviewBook.empty().applySession(
        sessionOf([result('logic_seq_01', correct: true)]),
        at: now,
      );

      final memory = book.memories['logic_seq_01']!;
      expect(memory.isDue(now), isFalse);
      expect(memory.isDue(now.add(const Duration(days: 1))), isTrue);
    });

    test('die Abstände wachsen mit jeder richtigen Antwort', () {
      var memory = QuestionMemory(
        questionId: 'logic_seq_01',
        subCategory: SubCategory.numberSequences,
        lastSeen: now,
        dueAt: now,
      );

      final intervals = <Duration>[];
      var moment = now;
      for (var round = 0; round < QuestionMemory.intervals.length; round++) {
        memory = memory.record(correct: true, now: moment);
        intervals.add(memory.dueAt.difference(moment));
        moment = memory.dueAt;
      }

      expect(intervals, QuestionMemory.intervals);
    });

    test('nach genug richtigen Antworten gilt sie als gekonnt', () {
      var memory = QuestionMemory(
        questionId: 'logic_seq_01',
        subCategory: SubCategory.numberSequences,
        lastSeen: now,
        dueAt: now,
      );

      for (var round = 0; round < QuestionMemory.masteredStreak; round++) {
        memory = memory.record(correct: true, now: now);
      }

      expect(memory.isMastered, isTrue);
      // Gekonntes taucht nicht mehr auf, egal wie lange es her ist.
      expect(memory.isDue(now.add(const Duration(days: 3650))), isFalse);
    });

    test('ein Fehler setzt den Fortschritt vollständig zurück', () {
      var memory = QuestionMemory(
        questionId: 'logic_seq_01',
        subCategory: SubCategory.numberSequences,
        lastSeen: now,
        dueAt: now,
      );

      memory = memory.record(correct: true, now: now);
      memory = memory.record(correct: true, now: now);
      expect(memory.streak, 2);

      memory = memory.record(correct: false, now: now);

      expect(memory.streak, 0);
      expect(memory.wrongCount, 1);
      expect(memory.isDue(now), isTrue);
    });

    test('übersprungene Aufgaben zählen nicht', () {
      // Wer nicht geantwortet hat, hat nichts gezeigt – weder Können noch
      // Nichtkoennen.
      final book = const ReviewBook.empty().applySession(
        sessionOf([
          result('logic_seq_01', correct: false, answered: false),
        ]),
        at: now,
      );

      expect(book.memories, isEmpty);
      expect(book.topics, isEmpty);
    });

    test('generierte Mathe-Aufgaben werden nicht einzeln gemerkt', () {
      // Sie gibt es kein zweites Mal – sich die Kennung zu merken brächte
      // nichts und liesse den Speicher wachsen.
      final book = const ReviewBook.empty().applySession(
        sessionOf([
          result(
            'math_arithmetic_g1',
            correct: false,
            subCategory: SubCategory.arithmetic,
          ),
        ]),
        at: now,
      );

      expect(book.memories, isEmpty);
      // Auf Themenebene wird der Fehler sehr wohl verbucht.
      expect(book.masteryOf(SubCategory.arithmetic).answered, 1);
      expect(book.masteryOf(SubCategory.arithmetic).correct, 0);
    });

    test('Aufgaben ohne Kennung zahlen nur auf das Thema ein', () {
      // So kommen Sitzungen aus dem Cloud-Abgleich zurück.
      final book = const ReviewBook.empty().applySession(
        sessionOf([result('', correct: false)]),
        at: now,
      );

      expect(book.memories, isEmpty);
      expect(book.masteryOf(SubCategory.numberSequences).answered, 1);
    });
  });

  group('Fällige Aufgaben', () {
    test('das oft Falsche kommt zuerst', () {
      var book = const ReviewBook.empty();
      for (var round = 0; round < 3; round++) {
        book = book.applySession(
          sessionOf([result('oft_falsch', correct: false)]),
          at: now,
        );
      }
      book = book.applySession(
        sessionOf([result('einmal_falsch', correct: false)]),
        at: now,
      );

      expect(
        book.dueMemories(now).map((entry) => entry.questionId),
        ['oft_falsch', 'einmal_falsch'],
      );
    });

    test('noch nicht fällige Aufgaben bleiben draußen', () {
      final book = const ReviewBook.empty().applySession(
        sessionOf([
          result('richtig', correct: true),
          result('falsch', correct: false),
        ]),
        at: now,
      );

      expect(book.dueCount(now), 1);
      expect(book.dueMemories(now).single.questionId, 'falsch');
    });
  });

  group('Themenstärke', () {
    ReviewBook withAnswers({
      required SubCategory subCategory,
      required int total,
      required int correct,
    }) {
      return const ReviewBook.empty().applySession(
        sessionOf([
          for (var index = 0; index < total; index++)
            result(
              'q$index',
              correct: index < correct,
              subCategory: subCategory,
            ),
        ]),
        at: now,
      );
    }

    test('rechnet die Trefferquote je Thema', () {
      final book = withAnswers(
        subCategory: SubCategory.ruleOfThree,
        total: 10,
        correct: 4,
      );

      expect(book.masteryOf(SubCategory.ruleOfThree).accuracy, 0.4);
    });

    test('wenige Antworten reichen für kein Urteil', () {
      // Zwei Fehlversuche machen noch keine Schwaeche.
      final book = withAnswers(
        subCategory: SubCategory.ruleOfThree,
        total: 3,
        correct: 0,
      );

      expect(book.masteryOf(SubCategory.ruleOfThree).isWeak, isFalse);
      expect(book.weakTopics(), isEmpty);
    });

    test('unter der Schwelle gilt ein Thema als Schwachstelle', () {
      final book = withAnswers(
        subCategory: SubCategory.ruleOfThree,
        total: 10,
        correct: 4,
      );

      expect(book.masteryOf(SubCategory.ruleOfThree).isWeak, isTrue);
      expect(book.weakestTopic?.subCategory, SubCategory.ruleOfThree);
    });

    test('gute Themen tauchen nicht als Schwachstelle auf', () {
      final book = withAnswers(
        subCategory: SubCategory.spelling,
        total: 10,
        correct: 9,
      );

      expect(book.weakTopics(), isEmpty);
      expect(book.weakestTopic, isNull);
    });

    test('das schwächste Thema steht vorn', () {
      var book = withAnswers(
        subCategory: SubCategory.ruleOfThree,
        total: 10,
        correct: 5,
      );
      book = book.applySession(
        sessionOf([
          for (var index = 0; index < 10; index++)
            result(
              'p$index',
              correct: index < 2,
              subCategory: SubCategory.percentage,
            ),
        ]),
        at: now,
      );

      expect(book.weakestTopic?.subCategory, SubCategory.percentage);
      expect(book.weakTopics(), hasLength(2));
    });

    test('Mathematik wird über das Thema erfasst', () {
      final book = withAnswers(
        subCategory: SubCategory.arithmetic,
        total: 12,
        correct: 3,
      );

      expect(book.weakestTopic?.subCategory, SubCategory.arithmetic);
      expect(book.weakestTopic?.module, TrainingModule.math);
    });
  });

  group('Etwas zu tun', () {
    test('ein frisches Buch hat nichts anzubieten', () {
      expect(const ReviewBook.empty().hasWork(now), isFalse);
      expect(const ReviewBook.empty().dueCount(now), 0);
    });

    test('ein Fehler genügt', () {
      final book = const ReviewBook.empty().applySession(
        sessionOf([result('logic_seq_01', correct: false)]),
        at: now,
      );

      expect(book.hasWork(now), isTrue);
    });
  });

  group('Speichern und Laden', () {
    test('übersteht den JSON-Zyklus', () {
      var book = const ReviewBook.empty().applySession(
        sessionOf([
          result('logic_seq_01', correct: false),
          result('logic_seq_02', correct: true),
          for (var index = 0; index < 10; index++)
            result(
              'lang_$index',
              correct: index < 4,
              subCategory: SubCategory.spelling,
            ),
        ]),
        at: now,
      );
      book = book.applySession(
        sessionOf([result('logic_seq_01', correct: false)]),
        at: now,
      );

      final restored = ReviewBook.fromJson(book.toJson());

      expect(restored.memories.length, book.memories.length);
      expect(restored.memories['logic_seq_01']?.wrongCount, 2);
      expect(
        restored.masteryOf(SubCategory.spelling).accuracy,
        book.masteryOf(SubCategory.spelling).accuracy,
      );
      expect(restored.weakestTopic?.subCategory, SubCategory.spelling);
    });

    test('fängt beschädigte Einträge ab, ohne alles zu verwerfen', () {
      final restored = ReviewBook.fromJson(const {
        'memories': [
          {'id': 'gut', 'topic': 'number_sequences', 'wrong': 1, 'streak': 0,
              'seen': '2026-05-01T10:00:00Z', 'due': '2026-05-01T10:00:00Z'},
          {'id': 'ohne_thema', 'wrong': 1},
          'kein Objekt',
        ],
        'topics': [
          {'topic': 'gibt_es_nicht', 'answered': 5, 'correct': 1},
        ],
      });

      expect(restored.memories.keys, ['gut']);
      expect(restored.topics, isEmpty);
    });

    test('ein leeres Buch bleibt leer', () {
      expect(ReviewBook.fromJson(const {}).memories, isEmpty);
      expect(ReviewBook.fromJson(const {}).topics, isEmpty);
    });
  });
}
