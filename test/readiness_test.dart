import 'package:einstellungstest_trainer/models/field_of_study.dart';
import 'package:einstellungstest_trainer/models/readiness.dart';
import 'package:einstellungstest_trainer/models/review_book.dart';
import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 19, 10);

  /// Ein Fehlerbuch, in dem [topic] genau [answered] Aufgaben hat, davon
  /// [correct] richtig.
  ReviewBook bookWith({
    required SubCategory topic,
    required int answered,
    required int correct,
  }) {
    return const ReviewBook.empty().applySession(
      TrainingSession(
        id: 'session',
        mode: SessionMode.practice,
        module: TrainingModule.language,
        startedAt: now,
        finishedAt: now,
        results: [
          for (var index = 0; index < answered; index++)
            QuestionResult(
              questionId: 'q$index',
              subCategory: topic,
              answered: true,
              correct: index < correct,
              timeSpent: const Duration(seconds: 10),
            ),
        ],
      ),
      at: now,
    );
  }

  group('Ein Schritt des Leitfadens', () {
    test('braucht Menge und Quote', () {
      const step = TopicStep(
        subCategory: SubCategory.spelling,
        weight: TopicWeight.core,
        answered: 30,
        accuracy: 0.9,
      );

      expect(step.hasEnough, isTrue);
      expect(step.hitsTarget, isTrue);
      expect(step.isDone, isTrue);
    });

    test('gute Quote allein reicht nicht', () {
      const step = TopicStep(
        subCategory: SubCategory.spelling,
        weight: TopicWeight.core,
        answered: 5,
        accuracy: 1,
      );

      expect(step.isDone, isFalse);
      expect(step.missing, 25);
      expect(step.advice, 'Noch 25 Aufgaben');
    });

    test('viele Aufgaben mit schlechter Quote reichen auch nicht', () {
      const step = TopicStep(
        subCategory: SubCategory.spelling,
        weight: TopicWeight.core,
        answered: 60,
        accuracy: 0.5,
      );

      expect(step.hasEnough, isTrue);
      expect(step.isDone, isFalse);
      expect(step.advice, contains('50 %'));
    });

    test('Nebenthemen verlangen weniger', () {
      const core = TopicStep(
        subCategory: SubCategory.spelling,
        weight: TopicWeight.core,
        answered: 0,
        accuracy: 0,
      );
      const supporting = TopicStep(
        subCategory: SubCategory.spelling,
        weight: TopicWeight.supporting,
        answered: 0,
        accuracy: 0,
      );

      expect(supporting.required, lessThan(core.required));
    });
  });

  group('Der Leitfaden einer Fachrichtung', () {
    test('nimmt nur die Themen der Fachrichtung auf', () {
      final readiness = Readiness.from(
        field: FieldOfStudy.it,
        book: const ReviewBook.empty(),
      );

      final topics = readiness.steps.map((step) => step.subCategory).toSet();
      expect(topics, FieldOfStudy.it.weights.keys.toSet());
      // Rechtschreibung gehoert nicht zum Informatik-Profil.
      expect(topics.contains(SubCategory.spelling), isFalse);
    });

    test('zaehlt erledigte und offene Schritte', () {
      final readiness = Readiness.from(
        field: FieldOfStudy.publicService,
        book: bookWith(
          topic: SubCategory.spelling,
          answered: 40,
          correct: 36,
        ),
      );

      expect(
        readiness.doneSteps.map((step) => step.subCategory),
        contains(SubCategory.spelling),
      );
      expect(readiness.openSteps, isNotEmpty);
      expect(readiness.isReady, isFalse);
    });

    test('ohne Simulation ist niemand fertig', () {
      // Alle Themen erledigt, aber kein Ernstfall gelaufen.
      final steps = [
        for (final topic in FieldOfStudy.trades.topics)
          TopicStep(
            subCategory: topic,
            weight: FieldOfStudy.trades.weights[topic]!,
            answered: 99,
            accuracy: 1,
          ),
      ];
      const withoutRun = Readiness(
        field: FieldOfStudy.trades,
        steps: [],
        simulationScore: null,
      );

      final readiness = Readiness(
        field: FieldOfStudy.trades,
        steps: steps,
        simulationScore: null,
      );

      expect(readiness.openSteps, isEmpty);
      expect(readiness.isReady, isFalse);
      expect(readiness.summary, contains('Testsimulation'));
      expect(withoutRun.simulationPassed, isFalse);
    });

    test('eine zu schwache Simulation zaehlt nicht', () {
      const weak = Readiness(
        field: FieldOfStudy.general,
        steps: [],
        simulationScore: 0.5,
      );
      const strong = Readiness(
        field: FieldOfStudy.general,
        steps: [],
        simulationScore: 0.8,
      );

      expect(weak.simulationPassed, isFalse);
      expect(strong.simulationPassed, isTrue);
    });

    test('schlaegt zuerst ein Kernthema vor', () {
      final readiness = Readiness.from(
        field: FieldOfStudy.police,
        book: const ReviewBook.empty(),
      );

      expect(readiness.nextStep, isNotNull);
      expect(readiness.nextStep!.weight, TopicWeight.core);
    });

    test('der Fortschritt liegt zwischen 0 und 1', () {
      final empty = Readiness.from(
        field: FieldOfStudy.police,
        book: const ReviewBook.empty(),
      );
      expect(empty.progress, 0);

      final started = Readiness.from(
        field: FieldOfStudy.police,
        book: bookWith(
          topic: SubCategory.spelling,
          answered: 30,
          correct: 30,
        ),
        simulationScore: 0.9,
      );

      expect(started.progress, greaterThan(0));
      expect(started.progress, lessThan(1));
    });
  });

  group('Fachrichtungen', () {
    test('haben alle Themen und eine Beschreibung', () {
      for (final field in FieldOfStudy.values) {
        expect(field.weights, isNotEmpty, reason: field.label);
        expect(field.description.trim(), isNotEmpty, reason: field.label);
        expect(field.topics.length, field.weights.length);
      }
    });

    test('nennen Kernthemen vor Nebenthemen', () {
      for (final field in FieldOfStudy.values) {
        var seenSupporting = false;
        for (final topic in field.topics) {
          final weight = field.weights[topic]!;
          if (weight == TopicWeight.supporting) seenSupporting = true;
          if (weight == TopicWeight.core) {
            expect(
              seenSupporting,
              isFalse,
              reason: '${field.label}: Kernthema nach einem Nebenthema',
            );
          }
        }
      }
    });

    test('jede Fachrichtung hat mindestens ein Kernthema', () {
      for (final field in FieldOfStudy.values) {
        expect(
          field.weights.values.where((w) => w == TopicWeight.core),
          isNotEmpty,
          reason: field.label,
        );
      }
    });

    test('IDs sind eindeutig und stabil', () {
      final ids = FieldOfStudy.values.map((field) => field.id).toList();
      expect(ids.toSet().length, ids.length);
      expect(FieldOfStudy.fromId('police'), FieldOfStudy.police);
      // Unbekannte Kennung faellt auf Allgemein zurueck statt zu werfen.
      expect(FieldOfStudy.fromId('gibtsnicht'), FieldOfStudy.general);
    });
  });
}
