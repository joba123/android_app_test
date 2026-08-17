import 'package:einstellungstest_trainer/models/module_stats.dart';
import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';
import 'package:einstellungstest_trainer/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late StorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = StorageService(await SharedPreferences.getInstance());
  });

  TrainingSession session(int index) {
    final finishedAt = DateTime.utc(2026, 1, 1).add(Duration(hours: index));
    return TrainingSession(
      id: 'session_$index',
      mode: SessionMode.practice,
      module: TrainingModule.math,
      startedAt: finishedAt.subtract(const Duration(minutes: 5)),
      finishedAt: finishedAt,
      results: [
        QuestionResult(
          questionId: 'q$index',
          subCategory: SubCategory.arithmetic,
          answered: true,
          correct: index.isEven,
          timeSpent: const Duration(seconds: 12),
        ),
      ],
    );
  }

  group('Fortschritt', () {
    test('ist zu Beginn leer', () {
      final stats = storage.loadStats();

      expect(stats.totalAnswered, 0);
      expect(stats.totalCorrect, 0);
    });

    test('übersteht Speichern und Laden', () async {
      var stats = TrainingStats.empty();
      stats = stats.withModule(
        stats.forModule(TrainingModule.logic).merge(
              addedAnswered: 8,
              addedCorrect: 6,
              completedSession: true,
            ),
      );

      await storage.saveStats(stats);
      final restored = storage.loadStats().forModule(TrainingModule.logic);

      expect(restored.answered, 8);
      expect(restored.correct, 6);
      expect(restored.sessionsCompleted, 1);
    });
  });

  group('Sprint-Bestwerte', () {
    test('sind zu Beginn leer', () {
      expect(
        storage.loadStats().bestSprint(
              PracticeScope.subCategory(SubCategory.arithmetic),
            ),
        0,
      );
    });

    test('werden je Aufgabentyp getrennt gespeichert', () async {
      final arithmetic = PracticeScope.subCategory(SubCategory.arithmetic);
      final percentage = PracticeScope.subCategory(SubCategory.percentage);

      var stats = TrainingStats.empty()
          .withSprintResult(arithmetic, 14)
          .withSprintResult(percentage, 6);
      await storage.saveStats(stats);

      stats = storage.loadStats();
      expect(stats.bestSprint(arithmetic), 14);
      expect(stats.bestSprint(percentage), 6);
    });

    test('ein Aufgabentyp teilt sich den Bestwert nicht mit seinem Modul',
        () async {
      final topic = PracticeScope.subCategory(SubCategory.arithmetic);
      const wholeModule = PracticeScope.module(TrainingModule.math);

      await storage.saveStats(
        TrainingStats.empty().withSprintResult(topic, 18),
      );

      final stats = storage.loadStats();
      expect(stats.bestSprint(topic), 18);
      expect(stats.bestSprint(wholeModule), 0);
      // Für die Modulübersicht zählt trotzdem der beste Lauf im Modul.
      expect(stats.bestSprintInModule(TrainingModule.math), 18);
    });

    test('ein schlechteres Ergebnis überschreibt den Bestwert nicht', () {
      final topic = PracticeScope.subCategory(SubCategory.spelling);

      final stats = TrainingStats.empty()
          .withSprintResult(topic, 12)
          .withSprintResult(topic, 9);

      expect(stats.bestSprint(topic), 12);
    });

    test('Zurücksetzen löscht auch die Bestwerte', () async {
      final topic = PracticeScope.subCategory(SubCategory.arithmetic);
      await storage.saveStats(
        TrainingStats.empty().withSprintResult(topic, 20),
      );

      await storage.resetStats();

      expect(storage.loadStats().bestSprint(topic), 0);
    });
  });

  group('Sitzungsverlauf', () {
    test('ist zu Beginn leer', () {
      expect(storage.loadSessions(), isEmpty);
    });

    test('stellt neue Sitzungen an den Anfang', () async {
      await storage.appendSession(session(1));
      await storage.appendSession(session(2));

      final history = storage.loadSessions();
      expect(history.map((entry) => entry.id), ['session_2', 'session_1']);
    });

    test('übersteht Speichern und Laden vollständig', () async {
      await storage.appendSession(session(1));

      final restored = storage.loadSessions().single;
      expect(restored.mode, SessionMode.practice);
      expect(restored.module, TrainingModule.math);
      expect(restored.results.single.subCategory, SubCategory.arithmetic);
      expect(restored.results.single.timeSpent, const Duration(seconds: 12));
      expect(restored.duration, const Duration(minutes: 5));
    });

    test('begrenzt den Verlauf auf die Obergrenze', () async {
      for (var i = 0; i < StorageService.maxStoredSessions + 5; i++) {
        await storage.appendSession(session(i));
      }

      final history = storage.loadSessions();
      expect(history.length, StorageService.maxStoredSessions);
      // Die jüngste Sitzung steht vorne, die ältesten sind herausgefallen.
      expect(
        history.first.id,
        'session_${StorageService.maxStoredSessions + 4}',
      );
    });

    test('appendSession liefert den gekürzten Verlauf direkt zurück', () async {
      await storage.appendSession(session(1));
      final returned = await storage.appendSession(session(2));

      expect(returned.map((entry) => entry.id), ['session_2', 'session_1']);
    });
  });

  group('Robustheit', () {
    test('beschädigte Daten blockieren die App nicht', () async {
      SharedPreferences.setMockInitialValues({
        'training_stats_v1': 'kein JSON',
        'training_sessions_v1': '{"auch":"kein Array"}',
      });
      final broken = StorageService(await SharedPreferences.getInstance());

      expect(broken.loadStats().totalAnswered, 0);
      expect(broken.loadSessions(), isEmpty);
    });

    test('Zurücksetzen löscht Fortschritt und Verlauf', () async {
      await storage.saveStats(TrainingStats.empty());
      await storage.appendSession(session(1));

      await storage.resetStats();

      expect(storage.loadSessions(), isEmpty);
      expect(storage.loadStats().totalAnswered, 0);
    });
  });
}
