import 'package:einstellungstest_trainer/models/training_session.dart';
import 'package:einstellungstest_trainer/models/user_profile.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Name und Tagesziel.
class ProfileController extends Notifier<UserProfile> {
  @override
  UserProfile build() => ref.watch(storageServiceProvider).loadProfile();

  Future<void> setName(String? name) async {
    final trimmed = name?.trim();
    state = trimmed == null || trimmed.isEmpty
        ? state.copyWith(clearName: true)
        : state.copyWith(name: trimmed);
    await _save();
  }

  Future<void> setDailyGoal(int goal) async {
    if (goal <= 0) return;

    state = state.copyWith(dailyGoal: goal);
    await _save();
  }

  Future<void> _save() =>
      ref.read(storageServiceProvider).saveProfile(state);
}

final profileProvider =
    NotifierProvider<ProfileController, UserProfile>(ProfileController.new);

/// Wie viele Aufgaben heute beantwortet wurden.
///
/// Gezählt wird über den Sitzungsverlauf, nicht über einen eigenen Zähler:
/// Ein zweiter Zähler könnte auseinanderlaufen, der Verlauf ist die
/// Wahrheit. Übersprungene Aufgaben zählen nicht mit – ein Tagesziel misst
/// Arbeit, nicht Durchklicken.
final answeredTodayProvider = Provider<int>((ref) {
  final sessions = ref.watch(sessionHistoryProvider);
  final now = DateTime.now();

  bool isToday(TrainingSession session) {
    final at = session.finishedAt.toLocal();
    return at.year == now.year && at.month == now.month && at.day == now.day;
  }

  return sessions
      .where(isToday)
      .fold<int>(0, (sum, session) => sum + session.answeredCount);
});
