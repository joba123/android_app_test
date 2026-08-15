import 'dart:math';

import 'package:einstellungstest_trainer/data/question_pool.dart';
import 'package:einstellungstest_trainer/data/simulation_blueprints.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/services/question_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late QuestionRepository repository;

  setUp(() {
    // Fester Seed: Die Tests sollen reproduzierbar sein.
    repository = QuestionRepository(random: Random(42));
  });

  Question originalOf(Question question) {
    return QuestionPool.all.firstWhere(
      (candidate) => candidate.id == question.id,
    );
  }

  test('Mischen der Optionen behält die richtige Antwort bei', () {
    final drawn = repository.draw(module: TrainingModule.language, count: 30);

    expect(drawn, isNotEmpty);
    for (final question in drawn) {
      final original = originalOf(question);

      expect(
        question.correctAnswerText,
        original.correctAnswerText,
        reason: '${question.id}: richtige Antwort ging beim Mischen verloren',
      );

      final shuffled = question.answer as MultipleChoice;
      final source = original.answer as MultipleChoice;
      expect(shuffled.options.toSet(), source.options.toSet());
      expect(shuffled.options.length, source.options.length);
    }
  });

  test('Aufgaben mit Zahleneingabe bleiben unverändert', () {
    final drawn = repository
        .draw(module: TrainingModule.math, count: 30)
        .where((question) => question.isNumericInput)
        .toList();

    expect(drawn, isNotEmpty);
    for (final question in drawn) {
      final original = originalOf(question).answer as NumericInput;
      final format = question.answer as NumericInput;

      expect(format.correctValue, original.correctValue);
      expect(format.tolerance, original.tolerance);
      expect(format.unit, original.unit);
    }
  });

  test('Übungsrunde liefert die gewünschte Anzahl ohne Wiederholungen', () {
    final drawn = repository.drawPractice(TrainingModule.logic, count: 8);

    expect(drawn.length, 8);
    expect(drawn.map((question) => question.id).toSet().length, 8);
  });

  test('Anforderung über Poolgröße hinaus wird begrenzt statt zu scheitern',
      () {
    final available = QuestionPool.countFor(TrainingModule.math);
    final drawn = repository.draw(
      module: TrainingModule.math,
      count: available + 50,
    );

    expect(drawn.length, available);
  });

  test('Filter auf Unterkategorien greift', () {
    final drawn = repository.draw(
      module: TrainingModule.math,
      count: 5,
      subCategories: [SubCategory.percentage],
    );

    expect(drawn, isNotEmpty);
    for (final question in drawn) {
      expect(question.subCategory, SubCategory.percentage);
    }
  });

  test('Filter kann mehrere Unterkategorien zusammenfassen', () {
    final drawn = repository.draw(
      module: TrainingModule.math,
      count: 99,
      subCategories: [SubCategory.ruleOfThree, SubCategory.percentage],
    );

    expect(
      drawn.map((question) => question.subCategory).toSet(),
      {SubCategory.ruleOfThree, SubCategory.percentage},
    );
  });

  test('Sprint-Warteschlange ist länger als der Pool', () {
    final queue = repository.drawSprintQueue(TrainingModule.language);

    expect(queue.length, QuestionPool.countFor(TrainingModule.language) * 2);
  });

  test('Simulationsteil liefert genau die geforderte Anzahl', () {
    for (final blueprint in SimulationBlueprints.all) {
      for (final part in blueprint.parts) {
        final drawn = repository.drawForPart(part);

        expect(
          drawn.length,
          part.questionCount,
          reason: '${blueprint.title} / ${part.title}',
        );
        for (final question in drawn) {
          expect(question.module, part.module);
          if (part.subCategories.isNotEmpty) {
            expect(part.subCategories, contains(question.subCategory));
          }
        }
      }
    }
  });
}
