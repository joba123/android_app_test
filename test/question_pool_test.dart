import 'package:einstellungstest_trainer/data/question_pool.dart';
import 'package:einstellungstest_trainer/data/simulation_blueprints.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:flutter_test/flutter_test.dart';

/// Inhaltliche Grundprüfungen des Aufgaben-Pools.
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

    test('Aufgabentext und Erklärung sind gefüllt', () {
      for (final question in QuestionPool.all) {
        expect(question.prompt.trim(), isNotEmpty, reason: question.id);
        expect(question.explanation.trim(), isNotEmpty, reason: question.id);
      }
    });

    test('jedes Antwortformat ist in sich stimmig', () {
      for (final question in QuestionPool.all) {
        switch (question.answer) {
          case final MultipleChoice format:
            expect(
              format.options.length,
              greaterThanOrEqualTo(2),
              reason: '${question.id} hat zu wenige Optionen',
            );
            expect(
              format.correctIndex,
              inInclusiveRange(0, format.options.length - 1),
              reason: '${question.id} hat einen ungültigen correctIndex',
            );
            expect(
              format.options.toSet().length,
              format.options.length,
              reason: '${question.id} enthält doppelte Antwortoptionen',
            );
            for (final option in format.options) {
              expect(option.trim(), isNotEmpty, reason: question.id);
            }

          case final NumericInput format:
            expect(
              format.tolerance,
              greaterThanOrEqualTo(0),
              reason: '${question.id} hat eine negative Toleranz',
            );
            expect(
              format.decimals,
              inInclusiveRange(0, 4),
              reason: '${question.id} hat unplausible Nachkommastellen',
            );
            expect(
              format.correctValue.isFinite,
              isTrue,
              reason: '${question.id} hat keinen endlichen Lösungswert',
            );
        }
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

    test('jede Unterkategorie hat Aufgaben', () {
      for (final subCategory in SubCategory.values) {
        expect(
          QuestionPool.countForSubCategory(subCategory),
          greaterThan(0),
          reason: 'Unterkategorie ${subCategory.label} ist leer',
        );
      }
    });

    test('Mathematik setzt überwiegend auf Zahleneingabe', () {
      final mathQuestions = QuestionPool.forModule(TrainingModule.math);
      final numeric =
          mathQuestions.where((question) => question.isNumericInput).length;

      expect(numeric * 2, greaterThan(mathQuestions.length));
    });

    test('Logik und Sprache setzen auf Multiple Choice', () {
      for (final module in [TrainingModule.logic, TrainingModule.language]) {
        for (final question in QuestionPool.forModule(module)) {
          expect(
            question.isMultipleChoice,
            isTrue,
            reason: '${question.id} ist keine Auswahlaufgabe',
          );
        }
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

    test('ziehen nur aus Unterkategorien des eigenen Moduls', () {
      for (final blueprint in SimulationBlueprints.all) {
        for (final part in blueprint.parts) {
          for (final subCategory in part.subCategories) {
            expect(
              subCategory.module,
              part.module,
              reason: '${blueprint.title} / ${part.title}: '
                  '${subCategory.label} gehört nicht zu ${part.module.label}',
            );
          }
        }
      }
    });

    test('fordern nie mehr Aufgaben an, als der Pool hergibt', () {
      for (final blueprint in SimulationBlueprints.all) {
        for (final part in blueprint.parts) {
          final available = QuestionPool.forSubCategories(
            part.module,
            part.subCategories,
          ).length;

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
