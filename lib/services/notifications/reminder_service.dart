import 'package:einstellungstest_trainer/models/reminder_settings.dart';

/// Ergebnis einer Berechtigungsanfrage.
enum PermissionOutcome {
  granted,

  /// Abgelehnt – oder unter Android dauerhaft abgelehnt. Die Oberfläche
  /// verweist dann auf die Systemeinstellungen.
  denied,

  /// Auf dieser Plattform gibt es keine Benachrichtigungen (z. B. in Tests).
  unsupported,
}

/// Plant lokale Erinnerungen.
///
/// Die Oberfläche kennt nur diese Schnittstelle. Dadurch bleibt die Planung
/// ohne Platform-Channels testbar – und die Terminlogik in [planReminders]
/// bleibt von der Benachrichtigungs-Bibliothek unabhängig.
abstract class ReminderService {
  /// `false` in Umgebungen ohne Benachrichtigungen. Die Oberfläche blendet
  /// den Abschnitt dann nicht aus, sondern erklärt ihn – siehe
  /// SettingsScreen.
  bool get isAvailable;

  /// Fragt die Berechtigung an, falls nötig. Mehrfaches Aufrufen ist
  /// unbedenklich; Android zeigt den Dialog nur einmal.
  Future<PermissionOutcome> requestPermission();

  /// Ob die Berechtigung aktuell vorliegt – ohne einen Dialog zu zeigen.
  Future<bool> hasPermission();

  /// Ersetzt **alle** geplanten Erinnerungen durch die übergebenen.
  ///
  /// Vollständiges Ersetzen statt punktueller Änderungen: Der Termin kann
  /// sich verschieben, Vorlaufzeiten können wegfallen, und der Abgleich mit
  /// der Cloud kann beides von außen ändern. Ein Neuaufbau ist der einzige
  /// Weg, der in all diesen Fällen richtig bleibt.
  Future<void> schedule(List<ScheduledReminder> reminders);

  Future<void> cancelAll();

  /// Was tatsächlich beim System liegt – für die Anzeige und für Tests.
  Future<List<int>> pendingIds();
}

/// Erinnerungen, die es nicht gibt.
///
/// Wird in Tests und auf Plattformen ohne Unterstützung verwendet. Alle
/// Aufrufe laufen ins Leere, statt zu scheitern.
class UnavailableReminderService implements ReminderService {
  const UnavailableReminderService();

  @override
  bool get isAvailable => false;

  @override
  Future<PermissionOutcome> requestPermission() async =>
      PermissionOutcome.unsupported;

  @override
  Future<bool> hasPermission() async => false;

  @override
  Future<void> schedule(List<ScheduledReminder> reminders) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<List<int>> pendingIds() async => const [];
}

/// Erinnerungen im Speicher – für Tests.
class InMemoryReminderService implements ReminderService {
  InMemoryReminderService({this.grantPermission = true});

  bool grantPermission;

  /// Was zuletzt geplant wurde.
  List<ScheduledReminder> scheduled = const [];

  /// Wie oft neu geplant wurde – Tests prüfen damit, dass nicht bei jedem
  /// Rebuild neu geplant wird.
  int scheduleCalls = 0;
  int cancelCalls = 0;
  bool permissionRequested = false;

  bool _granted = false;

  @override
  bool get isAvailable => true;

  @override
  Future<PermissionOutcome> requestPermission() async {
    permissionRequested = true;
    _granted = grantPermission;
    return _granted ? PermissionOutcome.granted : PermissionOutcome.denied;
  }

  @override
  Future<bool> hasPermission() async => _granted;

  @override
  Future<void> schedule(List<ScheduledReminder> reminders) async {
    scheduleCalls++;
    scheduled = List.unmodifiable(reminders);
  }

  @override
  Future<void> cancelAll() async {
    cancelCalls++;
    scheduled = const [];
  }

  @override
  Future<List<int>> pendingIds() async =>
      scheduled.map((reminder) => reminder.id).toList();
}
