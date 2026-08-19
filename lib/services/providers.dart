import 'package:einstellungstest_trainer/models/module_stats.dart';
import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/review_book.dart';
import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';
import 'package:einstellungstest_trainer/services/purchase/entitlement_controller.dart';
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

/// Was die App über die eigenen Schwachstellen weiß.
///
/// Wird bei jeder abgeschlossenen Sitzung fortgeschrieben – siehe
/// [StatsController.record].
class ReviewController extends Notifier<ReviewBook> {
  @override
  ReviewBook build() => ref.watch(storageServiceProvider).loadReviewBook();

  Future<void> apply(TrainingSession session) async {
    final updated = state.applySession(session);

    state = updated;
    await ref.read(storageServiceProvider).saveReviewBook(updated);
  }

  Future<void> reset() async {
    state = const ReviewBook.empty();
    await ref.read(storageServiceProvider).saveReviewBook(state);
  }
}

final reviewBookProvider =
    NotifierProvider<ReviewController, ReviewBook>(ReviewController.new);

/// Wie viele Aufgaben gerade zur Wiederholung anstehen.
final dueReviewCountProvider = Provider<int>((ref) {
  return ref.watch(reviewBookProvider).dueCount(DateTime.now());
});

/// Zieht Aufgaben – mit oder ohne Pro-Bestand.
///
/// Die Freischaltung sitzt hier und nicht an den Aufrufstellen: Wird Pro
/// gekauft, wird der Provider neu gebaut und jede folgende Runde zieht
/// automatisch aus dem groesseren Bestand.
final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepository(proUnlocked: ref.watch(isProProvider));
});

/// Verlauf der abgeschlossenen Sitzungen, neueste zuerst.
class SessionHistoryController extends Notifier<List<TrainingSession>> {
  @override
  List<TrainingSession> build() {
    return ref.watch(storageServiceProvider).loadSessions();
  }

  Future<void> add(TrainingSession session) async {
    state = await ref.read(storageServiceProvider).appendSession(
          session,
          limit: ref.read(historyLimitProvider),
        );
  }

  void clear() => state = const [];
}

final sessionHistoryProvider =
    NotifierProvider<SessionHistoryController, List<TrainingSession>>(
  SessionHistoryController.new,
);

/// Trefferquote des letzten Simulationsdurchlaufs – `null`, solange es
/// keinen gab. Steht auf der Karte im Hauptmenü, damit der Ernstfall einen
/// Bezugspunkt hat.
final lastSimulationScoreProvider = Provider<double?>((ref) {
  for (final session in ref.watch(sessionHistoryProvider)) {
    if (session.mode == SessionMode.simulation) return session.accuracy;
  }
  return null;
});

/// Durchschnittliche Zeit je beantworteter Aufgabe über alle gespeicherten
/// Sitzungen. `null`, solange nichts beantwortet wurde.
final averagePaceProvider = Provider<Duration?>((ref) {
  var answered = 0;
  var seconds = 0;

  for (final session in ref.watch(sessionHistoryProvider)) {
    for (final result in session.results) {
      if (!result.answered) continue;
      answered += 1;
      seconds += result.timeSpent.inSeconds;
    }
  }

  if (answered == 0) return null;
  return Duration(seconds: seconds ~/ answered);
});

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
  ///
  /// [scope] wird für Sprint-Bestwerte gebraucht: Die werden je Aufgabentyp
  /// geführt, und diese Information steckt nicht in der [TrainingSession].
  Future<void> record(TrainingSession session, {PracticeScope? scope}) async {
    final grouped = <TrainingModule, List<QuestionResult>>{};
    for (final result in session.results) {
      grouped.putIfAbsent(result.module, () => []).add(result);
    }

    var updated = state;
    for (final entry in grouped.entries) {
      final current = updated.forModule(entry.key);

      updated = updated.withModule(
        current.merge(
          addedAnswered: entry.value.where((result) => result.answered).length,
          addedCorrect: entry.value.where((result) => result.correct).length,
          completedSession: true,
        ),
      );
    }

    if (session.mode == SessionMode.sprint && scope != null) {
      updated = updated.withSprintResult(scope, session.correctCount);
    }

    state = updated;
    await ref.read(storageServiceProvider).saveStats(updated);
    await ref.read(sessionHistoryProvider.notifier).add(session);
    // Fehler und Themenstaerke fortschreiben – die Grundlage fuer die
    // Wiederholung und den Schwachstellen-Hinweis auf der Startseite.
    await ref.read(reviewBookProvider.notifier).apply(session);
  }

  Future<void> reset() async {
    state = TrainingStats.empty();
    ref.read(sessionHistoryProvider.notifier).clear();
    await ref.read(reviewBookProvider.notifier).reset();
    await ref.read(storageServiceProvider).resetStats();
  }
}

final statsControllerProvider =
    NotifierProvider<StatsController, TrainingStats>(StatsController.new);
