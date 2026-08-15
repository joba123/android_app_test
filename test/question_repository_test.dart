import 'dart:math';

import 'package:einstellungstest_trainer/data/math_questions.dart';
import 'package:einstellungstest_trainer/data/question_pool.dart';
import 'package:einstellungstest_trainer/data/simulation_blueprints.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/services/question_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late QuestionRepository repository;

  setUp(() {
    // Fester Seed: Die Tests sollen reproduzierbar sein.
    repository = QuestionRepository(random: Random(42));
  });

  test('Mischen der Optionen behält die richtige Antwort bei', () {
    final drawn = repository.draw(module: TrainingModule.math, count: 20);

    for (final question in drawn) {
      final original = QuestionPool.all.firstWhere(
        (candidate) => candidate.id == question.id,
      );

      expect(
        question.correctAnswer,
        original.correctAnswer,
        reason: '${question.id}: richtige Antwort ging beim Mischen verloren',
      );
      expect(question.options.toSet(), original.options.toSet());
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

  test('Themenfilter greift', () {
    final drawn = repository.draw(
      module: TrainingModule.math,
      count: 5,
      topics: [MathTopics.percentage],
    );

    expect(drawn, isNotEmpty);
    for (final question in drawn) {
      expect(question.topic, MathTopics.percentage);
    }
  });

  test('Sprint-Warteschlange ist länger als der Pool', () {
    final queue = repository.drawSprintQueue(TrainingModule.language);

    expect(
      queue.length,
      QuestionPool.countFor(TrainingModule.language) * 2,
    );
  });

  test('Simulationsteil liefert genau die geforderte Anzahl', () {
    for (final part in SimulationBlueprints.full.parts) {
      final drawn = repository.drawForPart(part);

      expect(drawn.length, part.questionCount);
      for (final question in drawn) {
        expect(question.module, part.module);
      }
    }
  });
}
