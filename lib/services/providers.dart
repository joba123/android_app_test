import 'package:einstellungstest_trainer/models/module_stats.dart';
import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';
import 'package:einstellungstest_trainer/services/question_repository.dart';
import 'package:einstellungstest_trainer/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wird in `main()` mit der tatsächlichen Instanz überschrieben.
/// Der Fehlerfall hier ist Absicht: Er fällt sofort auf, wenn das Override
/// vergessen wurde, statt still ein Dummy-Verhalten zu erzeugen.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider muss überschrieben werden');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(sharedPreferencesProvider));
});

final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepository();
});

/// Verlauf der abgeschlossenen Sitzungen, neueste zuerst.
class SessionHistoryController extends Notifier<List<TrainingSession>> {
  @override
  List<TrainingSession> build() {
    return ref.watch(storageServiceProvider).loadSessions();
  }

  Future<void> add(TrainingSession session) async {
    state = await ref.read(storageServiceProvider).appendSession(session);
  }

  void clear() => state = const [];
}

final sessionHistoryProvider =
    NotifierProvider<SessionHistoryController, List<TrainingSession>>(
  SessionHistoryController.new,
);

/// Hält den persistierten Lernfortschritt und schreibt Änderungen zurück.
class StatsController extends Notifier<TrainingStats> {
  @override
  TrainingStats build() {
    return ref.watch(storageServiceProvider).loadStats();
  }

  /// Verbucht eine abgeschlossene Sitzung: aktualisiert die Zählerstände je
  /// Modul und hängt die Sitzung an den Verlauf an.
  ///
  /// Die Ergebnisse werden nach Modul gruppiert, damit auch die
  /// modulübergreifende Gesamtsimulation korrekt einzahlt.
  Future<void> record(TrainingSession session) async {
    final grouped = <TrainingModule, List<QuestionResult>>{};
    for (final result in session.results) {
      grouped.putIfAbsent(result.module, () => []).add(result);
    }

    var updated = state;
    for (final entry in grouped.entries) {
      final current = updated.forModule(entry.key);
      final isSprintForThisModule =
          session.mode == SessionMode.sprint && session.module == entry.key;

      updated = updated.withModule(
        current.merge(
          addedAnswered: entry.value.where((result) => result.answered).length,
          addedCorrect: entry.value.where((result) => result.correct).length,
          sprintScore: isSprintForThisModule ? session.correctCount : null,
          completedSession: true,
        ),
      );
    }

    state = updated;
    await ref.read(storageServiceProvider).saveStats(updated);
    await ref.read(sessionHistoryProvider.notifier).add(session);
  }

  Future<void> reset() async {
    state = TrainingStats.empty();
    ref.read(sessionHistoryProvider.notifier).clear();
    await ref.read(storageServiceProvider).resetStats();
  }
}

final statsControllerProvider =
    NotifierProvider<StatsController, TrainingStats>(StatsController.new);
