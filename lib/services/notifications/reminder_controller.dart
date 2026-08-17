import 'package:einstellungstest_trainer/models/reminder_settings.dart';
import 'package:einstellungstest_trainer/services/exam_date_controller.dart';
import 'package:einstellungstest_trainer/services/notifications/reminder_service.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wird in `main()` mit [LocalReminderService] überschrieben.
///
/// Voreinstellung ist der Ersatz ohne Benachrichtigungen: So laufen Tests
/// ohne Platform-Channels, und auf Plattformen ohne Unterstützung passiert
/// schlicht nichts.
final reminderServiceProvider = Provider<ReminderService>((ref) {
  return const UnavailableReminderService();
});

/// Die Erinnerungen, die zum aktuellen Stand gehören.
///
/// Abgeleitet aus Termin und Einstellungen – nicht gespeichert. Die
/// Oberfläche zeigt damit an, was tatsächlich geplant ist, ohne das System
/// befragen zu müssen.
final plannedRemindersProvider = Provider<List<ScheduledReminder>>((ref) {
  return planReminders(
    examDate: ref.watch(examDateProvider),
    settings: ref.watch(reminderControllerProvider),
    now: DateTime.now(),
  );
});

/// Einstellungen der Erinnerungen – und deren Umsetzung beim System.
///
/// Jede Änderung führt zu einem vollständigen Neuaufbau der geplanten
/// Benachrichtigungen. Das ist der einzige Weg, der auch dann richtig bleibt,
/// wenn sich der Termin verschiebt, Vorlaufzeiten wegfallen oder der
/// Cloud-Abgleich den Termin von einem anderen Gerät mitbringt.
class ReminderController extends Notifier<ReminderSettings> {
  @override
  ReminderSettings build() {
    return ref.watch(storageServiceProvider).loadReminderSettings();
  }

  /// Schaltet Erinnerungen ein und fragt dabei die Berechtigung an.
  ///
  /// Ohne Berechtigung bleibt der Schalter aus: Ein aktiver Schalter, der
  /// nichts auslöst, wäre ein Versprechen, das die App nicht halten kann.
  /// Der Rückgabewert sagt der Oberfläche, was zu melden ist.
  Future<PermissionOutcome> enable() async {
    final service = ref.read(reminderServiceProvider);
    final outcome = await service.requestPermission();

    if (outcome != PermissionOutcome.granted) {
      await _update(state.copyWith(enabled: false));
      return outcome;
    }

    await _update(state.copyWith(enabled: true));
    return outcome;
  }

  Future<void> disable() => _update(state.copyWith(enabled: false));

  Future<void> toggleLead(int days) => _update(state.toggleLead(days));

  Future<void> setTime({required int hour, required int minute}) =>
      _update(state.copyWith(hour: hour, minute: minute));

  /// Plant neu, ohne die Einstellungen zu ändern.
  ///
  /// Wird nach jeder Änderung am Testtermin aufgerufen – auch nach einem
  /// Abgleich mit der Cloud.
  Future<void> reschedule() => _applyToSystem(state);

  Future<void> _update(ReminderSettings settings) async {
    state = settings;
    await ref.read(storageServiceProvider).saveReminderSettings(settings);
    await _applyToSystem(settings);
  }

  Future<void> _applyToSystem(ReminderSettings settings) async {
    final service = ref.read(reminderServiceProvider);

    final reminders = planReminders(
      examDate: ref.read(examDateProvider),
      settings: settings,
      now: DateTime.now(),
    );

    if (reminders.isEmpty) {
      await service.cancelAll();
      return;
    }

    await service.schedule(reminders);
  }
}

final reminderControllerProvider =
    NotifierProvider<ReminderController, ReminderSettings>(
  ReminderController.new,
);
