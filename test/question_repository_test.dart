import 'dart:math';

import 'package:einstellungstest_trainer/data/question_pool.dart';
import 'package:einstellungstest_trainer/data/simulation_blueprints.dart';
import 'package:einstellungstest_trainer/models/practice_scope.dart';
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

  group('Statischer Content', () {
    test('Mischen der Optionen behält die richtige Antwort bei', () {
      final drawn = repository.draw(module: TrainingModule.language, count: 40);

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
      }
    });

    test('Übungsrunde liefert die gewünschte Anzahl ohne Wiederholungen', () {
      final drawn = repository.drawForScope(
        const PracticeScope.module(TrainingModule.logic),
        count: 8,
      );

      expect(drawn.length, 8);
      expect(drawn.map((question) => question.id).toSet().length, 8);
    });

    test('Anforderung über Poolgröße hinaus wird begrenzt statt zu scheitern',
        () {
      final available = QuestionPool.countFor(TrainingModule.logic);
      final drawn = repository.draw(
        module: TrainingModule.logic,
        count: available + 50,
      );

      expect(drawn.length, available);
    });

    test('Filter auf Unterkategorien greift', () {
      final drawn = repository.draw(
        module: TrainingModule.language,
        count: 5,
        subCategories: [SubCategory.spelling],
      );

      expect(drawn, isNotEmpty);
      for (final question in drawn) {
        expect(question.subCategory, SubCategory.spelling);
      }
    });

    test('Filter kann mehrere Unterkategorien zusammenfassen', () {
      final drawn = repository.draw(
        module: TrainingModule.language,
        count: 99,
        subCategories: [SubCategory.grammar, SubCategory.vocabulary],
      );

      expect(
        drawn.map((question) => question.subCategory).toSet(),
        {SubCategory.grammar, SubCategory.vocabulary},
      );
    });

    test('Sprint-Warteschlange ist doppelt so lang wie der Pool', () {
      final queue = repository.drawSprintQueue(TrainingModule.language);

      expect(queue.length, QuestionPool.countFor(TrainingModule.language) * 2);
    });
  });

  group('Generierte Mathematik', () {
    test('liefert immer genau die angeforderte Anzahl', () {
      // Anders als beim statischen Pool gibt es hier keine Obergrenze.
      for (final count in [1, 10, 50, 200]) {
        final drawn = repository.draw(
          module: TrainingModule.math,
          count: count,
        );
        expect(drawn.length, count);
      }
    });

    test('erzeugt ausschließlich Zahleneingaben mit eindeutigen IDs', () {
      final drawn = repository.draw(module: TrainingModule.math, count: 120);

      expect(drawn.every((question) => question.isNumericInput), isTrue);
      expect(drawn.map((question) => question.id).toSet().length, drawn.length);
    });

    test('respektiert den Filter auf Unterkategorien', () {
      final drawn = repository.draw(
        module: TrainingModule.math,
        count: 30,
        subCategories: [SubCategory.percentage],
      );

      for (final question in drawn) {
        expect(question.subCategory, SubCategory.percentage);
      }
    });

    test('reicht die Schwierigkeit durch', () {
      final drawn = repository.drawForScope(
        const PracticeScope.module(TrainingModule.math),
        count: 20,
        difficulty: Difficulty.hard,
      );

      expect(
        drawn.every((question) => question.difficulty == Difficulty.hard),
        isTrue,
      );
    });

    test('Sprint-Warteschlange hat die feste Pufferlänge', () {
      final queue = repository.drawSprintQueue(TrainingModule.math);

      expect(queue.length, QuestionRepository.sprintQueueLength);
    });

    test('derselbe Seed liefert dieselben Aufgaben', () {
      final first = QuestionRepository(random: Random(7))
          .draw(module: TrainingModule.math, count: 25);
      final second = QuestionRepository(random: Random(7))
          .draw(module: TrainingModule.math, count: 25);

      expect(
        first.map((question) => question.prompt).toList(),
        second.map((question) => question.prompt).toList(),
      );
    });
  });

  group('Übungsumfang', () {
    test('Misch-Modus zieht aus allen Modulen', () {
      final drawn = repository.drawForScope(
        const PracticeScope.mixed(),
        count: 30,
      );

      expect(drawn.length, 30);
      expect(
        drawn.map((question) => question.module).toSet(),
        TrainingModule.values.toSet(),
      );
    });

    test('Misch-Modus verteilt gleichmäßig über die Module', () {
      final drawn = repository.drawForScope(
        const PracticeScope.mixed(),
        count: 30,
      );

      for (final module in TrainingModule.values) {
        expect(
          drawn.where((question) => question.module == module).length,
          10,
          reason: 'Modul ${module.label} ist ungleich vertreten',
        );
      }
    });

    test('ein einzelnes Thema wird eingehalten', () {
      final drawn = repository.drawForScope(
        PracticeScope.subCategory(SubCategory.numberSequences),
        count: 12,
      );

      expect(drawn, isNotEmpty);
      for (final question in drawn) {
        expect(question.subCategory, SubCategory.numberSequences);
      }
    });

    test('ein knappes Thema liefert weniger statt zu scheitern', () {
      final available = QuestionPool.countForSubCategory(SubCategory.grammar);
      final drawn = repository.drawForScope(
        PracticeScope.subCategory(SubCategory.grammar),
        count: 30,
      );

      expect(drawn.length, available);
      expect(drawn.length, lessThan(30));
    });

    test('ein generiertes Thema liefert immer die volle Anzahl', () {
      final drawn = repository.drawForScope(
        PracticeScope.subCategory(SubCategory.percentage),
        count: 30,
      );

      expect(drawn.length, 30);
    });

    test('Misch-Modus mit null Aufgaben liefert eine leere Liste', () {
      expect(repository.drawMixed(count: 0), isEmpty);
    });
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
