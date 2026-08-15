import 'package:einstellungstest_trainer/data/question_pool.dart';
import 'package:einstellungstest_trainer/data/simulation_blueprints.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:flutter_test/flutter_test.dart';

/// Inhaltliche Grundpruefungen des Aufgaben-Pools.
///
/// Diese Tests sind die Absicherung beim Erweitern des Contents: Sie schlagen
/// an, sobald eine neue Aufgabe fehlerhaft notiert oder eine Simulation mehr
/// Aufgaben anfordert, als der Pool hergibt.
void main() {
  group('Aufgaben-Pool', () {
    test('IDs sind eindeutig', () {
      final ids = QuestionPool.all.map((question) => question.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('jede Aufgabe hat mindestens zwei Optionen und einen gültigen Index',
        () {
      for (final question in QuestionPool.all) {
        expect(
          question.options.length,
          greaterThanOrEqualTo(2),
          reason: '${question.id} hat zu wenige Optionen',
        );
        expect(
          question.correctIndex,
          inInclusiveRange(0, question.options.length - 1),
          reason: '${question.id} hat einen ungültigen correctIndex',
        );
      }
    });

    test('Optionen einer Aufgabe sind nicht doppelt', () {
      for (final question in QuestionPool.all) {
        expect(
          question.options.toSet().length,
          question.options.length,
          reason: '${question.id} enthält doppelte Antwortoptionen',
        );
      }
    });

    test('Aufgabentext und Erklärung sind gefüllt', () {
      for (final question in QuestionPool.all) {
        expect(question.prompt.trim(), isNotEmpty, reason: question.id);
        expect(question.explanation.trim(), isNotEmpty, reason: question.id);
      }
    });

    test('jedes Modul hat Aufgaben', () {
      for (final module in TrainingModule.values) {
        expect(
          QuestionPool.countFor(module),
          greaterThan(0),
          reason: 'Modul ${module.label} ist leer',
        );
      }
    });
  });

  group('Testsimulationen', () {
    test('dauern jeweils mindestens 30 Minuten', () {
      for (final blueprint in SimulationBlueprints.all) {
        expect(
          blueprint.totalDuration.inMinutes,
          greaterThanOrEqualTo(30),
          reason: '${blueprint.title} ist zu kurz',
        );
      }
    });

    test('bestehen aus mehreren Teilen mit fester Zeit', () {
      for (final blueprint in SimulationBlueprints.all) {
        expect(blueprint.parts.length, greaterThanOrEqualTo(2));
        for (final part in blueprint.parts) {
          expect(part.duration, greaterThan(Duration.zero));
          expect(part.questionCount, greaterThan(0));
        }
      }
    });

    test('fordern nie mehr Aufgaben an, als der Pool hergibt', () {
      for (final blueprint in SimulationBlueprints.all) {
        for (final part in blueprint.parts) {
          final available =
              QuestionPool.forTopics(part.module, part.topics).length;
          expect(
            available,
            greaterThanOrEqualTo(part.questionCount),
            reason: '${blueprint.title} / ${part.title}: '
                '$available verfügbar, ${part.questionCount} angefordert',
          );
        }
      }
    });
  });
}
