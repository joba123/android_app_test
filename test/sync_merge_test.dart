import 'package:einstellungstest_trainer/models/module_stats.dart';
import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';
import 'package:einstellungstest_trainer/services/sync/cloud_models.dart';
import 'package:einstellungstest_trainer/services/sync/sync_merge.dart';
import 'package:flutter_test/flutter_test.dart';

TrainingSession session(
  String id, {
  int total = 4,
  int correct = 3,
  SubCategory subCategory = SubCategory.arithmetic,
  DateTime? finishedAt,
  SessionMode mode = SessionMode.practice,
}) {
  final end = finishedAt ?? DateTime.utc(2026, 3, 1);
  return TrainingSession(
    id: id,
    mode: mode,
    module: subCategory.module,
    startedAt: end.subtract(const Duration(minutes: 5)),
    finishedAt: end,
    results: [
      for (var index = 0; index < total; index++)
        QuestionResult(
          questionId: '$id-$index',
          subCategory: subCategory,
          answered: true,
          correct: index < correct,
          timeSpent: const Duration(seconds: 10),
        ),
    ],
  );
}

TrainingStats statsWith({
  required TrainingModule module,
  required int answered,
  required int correct,
  int sessions = 1,
  Map<String, int> sprintBests = const {},
}) {
  var stats = TrainingStats.empty();
  stats = stats.withModule(
    ModuleStats(
      module: module,
      answered: answered,
      correct: correct,
      sessionsCompleted: sessions,
    ),
  );
  return TrainingStats(perModule: stats.perModule, sprintBests: sprintBests);
}

void main() {
  group('Erster Abgleich', () {
    test('lädt alle lokalen Sitzungen hoch', () {
      final local = LocalSnapshot(
        stats: statsWith(module: TrainingModule.math, answered: 8, correct: 6),
        sessions: [session('a'), session('b')],
      );

      final outcome = mergeForSync(
        local: local,
        cloudProfile: null,
        cloudSessions: const [],
        cloudSessionIds: const {},
      );

      expect(outcome.uploadedCount, 2);
      expect(outcome.downloadedCount, 0);
    });

    test('übernimmt die lokalen Zähler unverändert', () {
      // Die Historie ist gekappt, die Zähler laufen über die gesamte
      // Nutzungsdauer: Beim ersten Abgleich sind sie die bessere Quelle.
      final local = LocalSnapshot(
        stats: statsWith(
          module: TrainingModule.math,
          answered: 400,
          correct: 300,
          sessions: 40,
        ),
        sessions: [session('a')],
      );

      final outcome = mergeForSync(
        local: local,
        cloudProfile: null,
        cloudSessions: const [],
        cloudSessionIds: const {},
      );

      final math = outcome.stats.forModule(TrainingModule.math);
      expect(math.answered, 400);
      expect(math.correct, 300);
    });
  });

  group('Wiederholter Abgleich', () {
    test('lädt nichts hoch, wenn die Cloud alles kennt', () {
      final sessions = [session('a'), session('b')];
      final profile = CloudProfile.fromLocal(
        stats: statsWith(module: TrainingModule.math, answered: 8, correct: 6),
        examDate: null,
        examLabel: null,
        examUpdatedAt: null,
      );

      final outcome = mergeForSync(
        local: LocalSnapshot(stats: profile.toStats(), sessions: sessions),
        cloudProfile: profile,
        cloudSessions: [
          for (final entry in sessions) CloudSession.fromSession(entry),
        ],
        cloudSessionIds: sessions.map((entry) => entry.id).toSet(),
      );

      expect(outcome.uploadedCount, 0);
      expect(outcome.hasChanges, isFalse);
    });

    test('verdoppelt den Fortschritt nicht', () {
      // Genau der Fall, der beim zweiten Anmelden auf demselben Geraet
      // auftritt: Alles ist schon in der Cloud, die Zaehler duerfen sich
      // trotzdem nicht bewegen.
      final sessions = [session('a', total: 4, correct: 3)];
      final profile = CloudProfile.fromLocal(
        stats: statsWith(module: TrainingModule.math, answered: 4, correct: 3),
        examDate: null,
        examLabel: null,
        examUpdatedAt: null,
      );

      final outcome = mergeForSync(
        local: LocalSnapshot(stats: profile.toStats(), sessions: sessions),
        cloudProfile: profile,
        cloudSessions: [CloudSession.fromSession(sessions.single)],
        cloudSessionIds: {'a'},
      );

      final math = outcome.stats.forModule(TrainingModule.math);
      expect(math.answered, 4);
      expect(math.correct, 3);
    });

    test('rechnet nur die der Cloud fehlenden Sitzungen auf', () {
      final known = session('a', total: 4, correct: 3);
      final fresh = session('b', total: 6, correct: 2);
      final profile = CloudProfile.fromLocal(
        stats: statsWith(module: TrainingModule.math, answered: 4, correct: 3),
        examDate: null,
        examLabel: null,
        examUpdatedAt: null,
      );

      final outcome = mergeForSync(
        local: LocalSnapshot(
          stats: statsWith(
            module: TrainingModule.math,
            answered: 10,
            correct: 5,
            sessions: 2,
          ),
          sessions: [known, fresh],
        ),
        cloudProfile: profile,
        cloudSessions: [CloudSession.fromSession(known)],
        cloudSessionIds: {'a'},
      );

      final math = outcome.stats.forModule(TrainingModule.math);
      expect(math.answered, 10);
      expect(math.correct, 5);
      expect(outcome.toUpload.map((entry) => entry.id), ['b']);
    });
  });

  group('Zusammenführen der Historie', () {
    test('übernimmt Sitzungen, die nur in der Cloud liegen', () {
      final remote = session(
        'remote',
        finishedAt: DateTime.utc(2026, 2, 1),
        subCategory: SubCategory.spelling,
      );

      final outcome = mergeForSync(
        local: LocalSnapshot(
          stats: TrainingStats.empty(),
          sessions: [session('lokal', finishedAt: DateTime.utc(2026, 4, 1))],
        ),
        cloudProfile: const CloudProfile(),
        cloudSessions: [CloudSession.fromSession(remote)],
        cloudSessionIds: const {'remote'},
      );

      expect(outcome.downloadedCount, 1);
      expect(outcome.sessions.map((entry) => entry.id), ['lokal', 'remote']);
    });

    test('behält bei gleicher Kennung den lokalen Eintrag', () {
      // Lokal liegen die Aufgaben-Kennungen vor, in der Cloud nur Summen.
      final local = session('a');

      final outcome = mergeForSync(
        local: LocalSnapshot(stats: TrainingStats.empty(), sessions: [local]),
        cloudProfile: const CloudProfile(),
        cloudSessions: [CloudSession.fromSession(local)],
        cloudSessionIds: const {'a'},
      );

      expect(outcome.sessions.single.results.first.questionId, 'a-0');
    });

    test('kappt die Historie auf die Obergrenze', () {
      final outcome = mergeForSync(
        local: LocalSnapshot(
          stats: TrainingStats.empty(),
          sessions: [
            for (var index = 0; index < 6; index++)
              session(
                'lokal$index',
                finishedAt: DateTime.utc(2026, 5, 1).add(Duration(hours: index)),
              ),
          ],
        ),
        cloudProfile: const CloudProfile(),
        cloudSessions: const [],
        cloudSessionIds: const {},
        historyLimit: 3,
      );

      expect(outcome.sessions, hasLength(3));
      // Neueste zuerst.
      expect(outcome.sessions.first.id, 'lokal5');
    });
  });

  group('Sprint-Bestwerte', () {
    test('der höhere Wert gewinnt, je Aufgabentyp', () {
      final scope = PracticeScope.subCategory(SubCategory.arithmetic);
      final other = PracticeScope.subCategory(SubCategory.spelling);

      final outcome = mergeForSync(
        local: LocalSnapshot(
          stats: statsWith(
            module: TrainingModule.math,
            answered: 0,
            correct: 0,
            sessions: 0,
            sprintBests: {scope.storageKey: 12, other.storageKey: 4},
          ),
          sessions: const [],
        ),
        cloudProfile: CloudProfile(
          sprintBests: {scope.storageKey: 18},
        ),
        cloudSessions: const [],
        cloudSessionIds: const {},
      );

      expect(outcome.stats.bestSprint(scope), 18);
      expect(outcome.stats.bestSprint(other), 4);
    });
  });

  group('Testtermin', () {
    test('die jüngere Änderung gewinnt', () {
      final outcome = mergeForSync(
        local: LocalSnapshot(
          stats: TrainingStats.empty(),
          sessions: const [],
          examDate: DateTime.utc(2026, 9, 1),
          examLabel: 'lokal',
          examUpdatedAt: DateTime.utc(2026, 6, 1),
        ),
        cloudProfile: CloudProfile(
          examDate: DateTime.utc(2026, 10, 5),
          examLabel: 'cloud',
          examUpdatedAt: DateTime.utc(2026, 7, 1),
        ),
        cloudSessions: const [],
        cloudSessionIds: const {},
      );

      expect(outcome.examDate, DateTime.utc(2026, 10, 5));
      expect(outcome.examLabel, 'cloud');
    });

    test('ein einseitig gesetzter Termin bleibt erhalten', () {
      final outcome = mergeForSync(
        local: LocalSnapshot(
          stats: TrainingStats.empty(),
          sessions: const [],
          examDate: DateTime.utc(2026, 9, 1),
          examUpdatedAt: DateTime.utc(2026, 6, 1),
        ),
        cloudProfile: const CloudProfile(),
        cloudSessions: const [],
        cloudSessionIds: const {},
      );

      expect(outcome.examDate, DateTime.utc(2026, 9, 1));
      expect(outcome.profile.examDate, DateTime.utc(2026, 9, 1));
    });
  });

  group('Cloud-Darstellung einer Sitzung', () {
    test('gibt die Kennzahlen verlustfrei zurück', () {
      final original = session('a', total: 5, correct: 3);
      final restored = CloudSession.fromSession(original).toSession();

      expect(restored.total, original.total);
      expect(restored.answeredCount, original.answeredCount);
      expect(restored.correctCount, original.correctCount);
      expect(restored.timeOnQuestions, original.timeOnQuestions);
      expect(
        restored.resultsBySubCategory.keys,
        original.resultsBySubCategory.keys,
      );
    });

    test('übersteht die Serialisierung', () {
      final original = CloudSession.fromSession(
        session('a', total: 5, correct: 3, mode: SessionMode.sprint),
      );

      final restored = CloudSession.fromJson('a', original.toJson());

      expect(restored, isNotNull);
      expect(restored!.mode, SessionMode.sprint);
      expect(restored.correct, 3);
      expect(restored.byTopic[SubCategory.arithmetic]?.total, 5);
    });

    test('meldet einen beschädigten Eintrag als null', () {
      expect(CloudSession.fromJson('a', const {'total': 3}), isNull);
    });
  });
}
