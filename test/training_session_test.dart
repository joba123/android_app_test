import 'package:einstellungstest_trainer/models/answer_record.dart';
import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  final startedAt = DateTime.utc(2026, 3, 14, 10, 0);
  final finishedAt = DateTime.utc(2026, 3, 14, 10, 12, 30);

  /// Sitzung mit drei Aufgaben: eine richtig, eine falsch, eine übersprungen.
  TrainingSession buildSession() {
    final first = numericQuestion(
      id: 'q1',
      subCategory: SubCategory.arithmetic,
      correctValue: 10,
    );
    final second = choiceQuestion(
      id: 'q2',
      subCategory: SubCategory.spelling,
      correctIndex: 1,
    );
    final third = choiceQuestion(
      id: 'q3',
      subCategory: SubCategory.spelling,
      correctIndex: 0,
    );

    return TrainingSession.fromAnswers(
      mode: SessionMode.practice,
      module: TrainingModule.math,
      startedAt: startedAt,
      finishedAt: finishedAt,
      answers: [
        AnswerRecord(
          question: first,
          response: correctResponse(first),
          timeSpent: const Duration(seconds: 20),
        ),
        AnswerRecord(
          question: second,
          response: wrongResponse(second),
          timeSpent: const Duration(seconds: 40),
        ),
        AnswerRecord(
          question: third,
          response: null,
          timeSpent: const Duration(seconds: 5),
        ),
      ],
    );
  }

  group('Aufbau aus einer beendeten Runde', () {
    test('übernimmt jede Aufgabe als Ergebnis', () {
      final session = buildSession();

      expect(session.results.length, 3);
      expect(
        session.results.map((result) => result.questionId),
        ['q1', 'q2', 'q3'],
      );
    });

    test('merkt sich Modus, Modul und Zeitstempel', () {
      final session = buildSession();

      expect(session.mode, SessionMode.practice);
      expect(session.module, TrainingModule.math);
      expect(session.startedAt, startedAt);
      expect(session.finishedAt, finishedAt);
      expect(session.duration, const Duration(minutes: 12, seconds: 30));
    });

    test('vergibt eine ID, wenn keine mitgegeben wurde', () {
      expect(buildSession().id, isNotEmpty);
    });
  });

  group('Auswertung', () {
    test('zählt richtig, falsch und übersprungen getrennt', () {
      final session = buildSession();

      expect(session.total, 3);
      expect(session.answeredCount, 2);
      expect(session.correctCount, 1);
      expect(session.wrongCount, 1);
      expect(session.skippedCount, 1);
    });

    test('bezieht die Trefferquote auf alle gestellten Aufgaben', () {
      final session = buildSession();

      // 1 von 3 richtig - die übersprungene zählt nicht als richtig.
      expect(session.accuracy, closeTo(1 / 3, 0.0001));
    });

    test('summiert die Bearbeitungszeit über alle Aufgaben', () {
      final session = buildSession();

      expect(session.timeOnQuestions, const Duration(seconds: 65));
    });

    test('mittelt die Zeit nur über tatsächlich bearbeitete Aufgaben', () {
      final session = buildSession();

      // (20 s + 40 s) / 2 - die übersprungenen 5 s zählen nicht mit.
      expect(session.averageTimePerQuestion, const Duration(seconds: 30));
    });

    test('gruppiert die Ergebnisse nach Unterkategorie', () {
      final grouped = buildSession().resultsBySubCategory;

      expect(grouped.keys.toSet(), {
        SubCategory.arithmetic,
        SubCategory.spelling,
      });
      expect(grouped[SubCategory.arithmetic]!.length, 1);
      expect(grouped[SubCategory.spelling]!.length, 2);
    });

    test('kommt mit einer leeren Sitzung zurecht', () {
      final empty = TrainingSession(
        id: 'leer',
        mode: SessionMode.sprint,
        module: TrainingModule.logic,
        startedAt: startedAt,
        finishedAt: startedAt,
        results: const [],
      );

      expect(empty.total, 0);
      expect(empty.accuracy, 0);
      expect(empty.averageTimePerQuestion, Duration.zero);
      expect(empty.timeOnQuestions, Duration.zero);
    });
  });

  group('Serialisierung', () {
    test('übersteht einen vollständigen Zyklus', () {
      final original = buildSession();

      final restored = TrainingSession.fromJson(original.toJson());

      expect(restored, isNotNull);
      expect(restored!.id, original.id);
      expect(restored.mode, original.mode);
      expect(restored.module, original.module);
      expect(restored.startedAt, original.startedAt);
      expect(restored.finishedAt, original.finishedAt);
      expect(restored.total, original.total);
      expect(restored.correctCount, original.correctCount);
      expect(restored.skippedCount, original.skippedCount);
      expect(restored.timeOnQuestions, original.timeOnQuestions);
      expect(
        restored.results.map((result) => result.subCategory),
        original.results.map((result) => result.subCategory),
      );
    });

    test('behält die modulübergreifende Simulation ohne Modul bei', () {
      final session = TrainingSession(
        id: 'gesamt',
        mode: SessionMode.simulation,
        module: null,
        startedAt: startedAt,
        finishedAt: finishedAt,
        results: const [],
      );

      final restored = TrainingSession.fromJson(session.toJson());

      expect(restored, isNotNull);
      expect(restored!.module, isNull);
      expect(restored.mode, SessionMode.simulation);
    });

    test('überspringt defekte Einzelergebnisse, statt alles zu verwerfen', () {
      final json = buildSession().toJson();
      (json['results'] as List).add({'questionId': 'kaputt'});
      (json['results'] as List).add({'subCategory': 'gibt_es_nicht'});

      final restored = TrainingSession.fromJson(json);

      expect(restored, isNotNull);
      expect(restored!.results.length, 3);
    });

    test('gibt null zurück, wenn Pflichtfelder fehlen', () {
      expect(TrainingSession.fromJson(const {}), isNull);
      expect(
        TrainingSession.fromJson(const {'id': 'x', 'startedAt': 'kein Datum'}),
        isNull,
      );
    });
  });
}
