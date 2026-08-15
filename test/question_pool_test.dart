import 'package:einstellungstest_trainer/data/generators/math_question_factory.dart';
import 'package:einstellungstest_trainer/data/question_pool.dart';
import 'package:einstellungstest_trainer/data/question_validation.dart';
import 'package:einstellungstest_trainer/data/simulation_blueprints.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:flutter_test/flutter_test.dart';

/// Prüfungen des handgeschriebenen Aufgabenbestands (Logik und Sprache).
/// Mathematik wird generiert und in math_generator_test.dart geprüft.
void main() {
  group('Aufgaben-Pool', () {
    test('IDs sind eindeutig', () {
      final ids = QuestionPool.all.map((question) => question.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('jede Aufgabe besteht die Validierung', () {
      for (final question in QuestionPool.all) {
        final problems = validateQuestion(question);
        expect(
          problems,
          isEmpty,
          reason: '${question.id}: ${problems.join('; ')}',
        );
      }
    });

    test('der statische Pool enthält keine Mathematik-Aufgaben', () {
      // Mathematik kommt vollständig aus den Generatoren – doppelte
      // Quellen wären doppelte Wahrheit.
      expect(QuestionPool.forModule(TrainingModule.math), isEmpty);
      expect(QuestionPool.isGenerated(TrainingModule.math), isTrue);
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

    test('jede statische Unterkategorie hat Aufgaben', () {
      for (final subCategory in SubCategory.values) {
        if (QuestionPool.isGenerated(subCategory.module)) continue;

        expect(
          QuestionPool.countForSubCategory(subCategory),
          greaterThan(0),
          reason: 'Unterkategorie ${subCategory.label} ist leer',
        );
      }
    });

    test('jede generierbare Unterkategorie hat einen Generator', () {
      for (final subCategory in SubCategory.values) {
        if (!QuestionPool.isGenerated(subCategory.module)) continue;

        expect(
          MathQuestionFactory.supports(subCategory),
          isTrue,
          reason: 'Für ${subCategory.label} fehlt ein Generator',
        );
      }
    });
  });

  group('Mindestumfang für den MVP', () {
    /// Untergrenzen aus der Produktvorgabe. Sie dürfen wachsen, aber nicht
    /// unterschritten werden.
    const minimums = {
      SubCategory.numberSequences: 20,
      SubCategory.figureAnalogies: 15,
      SubCategory.spelling: 20,
      SubCategory.wordAnalogies: 15,
    };

    test('die geforderten Aufgabenzahlen sind erreicht', () {
      minimums.forEach((subCategory, minimum) {
        expect(
          QuestionPool.countForSubCategory(subCategory),
          greaterThanOrEqualTo(minimum),
          reason: '${subCategory.label}: mindestens $minimum Aufgaben nötig',
        );
      });
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

    test('fordern nie mehr Aufgaben an, als der statische Pool hergibt', () {
      for (final blueprint in SimulationBlueprints.all) {
        for (final part in blueprint.parts) {
          // Generierte Module haben keine Obergrenze.
          if (QuestionPool.isGenerated(part.module)) continue;

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
