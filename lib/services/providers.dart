import 'package:einstellungstest_trainer/models/answer_record.dart';
import 'package:einstellungstest_trainer/models/module_stats.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/services/question_repository.dart';
import 'package:einstellungstest_trainer/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wird in `main()` mit der tatsaechlichen Instanz ueberschrieben.
/// Der Fehlerfall hier ist Absicht: Er faellt sofort auf, wenn das Override
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

/// Haelt den persistierten Lernfortschritt und schreibt Aenderungen zurueck.
class StatsController extends Notifier<TrainingStats> {
  @override
  TrainingStats build() {
    return ref.watch(storageServiceProvider).loadStats();
  }

  /// Verbucht eine abgeschlossene Runde. Die Antworten werden nach Modul
  /// gruppiert, damit auch die modul-uebergreifende Gesamtsimulation
  /// korrekt einzahlt.
  Future<void> recordSession(
    List<AnswerRecord> answers, {
    int? sprintScore,
    TrainingModule? sprintModule,
  }) async {
    final grouped = <TrainingModule, List<AnswerRecord>>{};
    for (final answer in answers) {
      grouped.putIfAbsent(answer.question.module, () => []).add(answer);
    }

    var updated = state;
    for (final entry in grouped.entries) {
      final current = updated.forModule(entry.key);
      updated = updated.withModule(
        current.merge(
          addedAnswered: entry.value.where((answer) => answer.isAnswered).length,
          addedCorrect: entry.value.where((answer) => answer.isCorrect).length,
          sprintScore: entry.key == sprintModule ? sprintScore : null,
          completedSession: true,
        ),
      );
    }

    state = updated;
    await ref.read(storageServiceProvider).saveStats(updated);
  }

  Future<void> reset() async {
    state = TrainingStats.empty();
    await ref.read(storageServiceProvider).resetStats();
  }
}

final statsControllerProvider =
    NotifierProvider<StatsController, TrainingStats>(StatsController.new);
