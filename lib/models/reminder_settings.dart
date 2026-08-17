import 'package:einstellungstest_trainer/models/exam_date.dart';

/// Eine geplante Erinnerung.
///
/// Enthält bereits den fertigen Text: Die Formulierung hängt davon ab, wie
/// weit der Termin noch weg ist, und das ist Terminlogik, keine Sache der
/// Benachrichtigungs-Schicht.
class ScheduledReminder {
  const ScheduledReminder({
    required this.id,
    required this.when,
    required this.title,
    required this.body,
    required this.leadDays,
  });

  /// Stabile Kennung. Gleicher Vorlauf ⇒ gleiche Kennung, damit ein erneutes
  /// Planen den bestehenden Eintrag ersetzt statt zu verdoppeln.
  final int id;

  final DateTime when;
  final String title;
  final String body;

  /// Wie viele Tage vor dem Termin diese Erinnerung liegt.
  final int leadDays;

  @override
  bool operator ==(Object other) =>
      other is ScheduledReminder && other.id == id && other.when == when;

  @override
  int get hashCode => Object.hash(id, when);

  @override
  String toString() => 'ScheduledReminder($leadDays Tage vorher, $when)';
}

/// Einstellungen für die Erinnerungen zum Testtermin.
class ReminderSettings {
  const ReminderSettings({
    this.enabled = false,
    this.leadDays = defaultLeadDays,
    this.hour = 18,
    this.minute = 0,
  });

  /// Erinnerungen sind standardmäßig **aus**. Benachrichtigungen ungefragt zu
  /// verschicken wäre übergriffig – und unter Android 13+ müsste ohnehin erst
  /// die Berechtigung erfragt werden.
  final bool enabled;

  /// Vorlaufzeiten in Tagen. Voreinstellung: eine Woche vorher und der Tag
  /// davor – früh genug zum Üben, nah genug zum Erinnern.
  final Set<int> leadDays;

  /// Uhrzeit der Erinnerung. Abends, wenn Zeit zum Üben ist.
  final int hour;
  final int minute;

  static const Set<int> defaultLeadDays = {7, 1};

  /// Zur Auswahl stehende Vorlaufzeiten.
  static const List<int> selectableLeadDays = [30, 14, 7, 3, 1];

  ReminderSettings copyWith({
    bool? enabled,
    Set<int>? leadDays,
    int? hour,
    int? minute,
  }) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      leadDays: leadDays ?? this.leadDays,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  /// Schaltet eine Vorlaufzeit an oder aus.
  ///
  /// Die letzte kann nicht entfernt werden: „an, aber ohne Zeitpunkt" wäre ein
  /// Zustand, der nichts tut und trotzdem aktiv aussieht.
  ReminderSettings toggleLead(int days) {
    if (!selectableLeadDays.contains(days)) return this;

    final updated = Set<int>.from(leadDays);
    if (!updated.remove(days)) {
      updated.add(days);
    } else if (updated.isEmpty) {
      return this;
    }

    return copyWith(leadDays: updated);
  }

  String get timeLabel =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'leadDays': leadDays.toList()..sort(),
        'hour': hour,
        'minute': minute,
      };

  factory ReminderSettings.fromJson(Map<String, dynamic> json) {
    final rawLeadDays = json['leadDays'];
    final leadDays = <int>{};
    if (rawLeadDays is List) {
      for (final entry in rawLeadDays) {
        if (entry is int && selectableLeadDays.contains(entry)) {
          leadDays.add(entry);
        }
      }
    }

    final hour = json['hour'];
    final minute = json['minute'];

    return ReminderSettings(
      enabled: json['enabled'] as bool? ?? false,
      leadDays: leadDays.isEmpty ? defaultLeadDays : leadDays,
      hour: hour is int && hour >= 0 && hour <= 23 ? hour : 18,
      minute: minute is int && minute >= 0 && minute <= 59 ? minute : 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReminderSettings &&
      other.enabled == enabled &&
      other.hour == hour &&
      other.minute == minute &&
      other.leadDays.length == leadDays.length &&
      other.leadDays.containsAll(leadDays);

  @override
  int get hashCode => Object.hash(
        enabled,
        hour,
        minute,
        Object.hashAllUnordered(leadDays),
      );
}

/// Berechnet die Erinnerungen zu einem Termin.
///
/// Bewusst eine reine Funktion ohne Plattformbezug: Das ist der Teil, der
/// stimmen muss, und so lässt er sich ohne Emulator prüfen.
///
/// Übersprungen wird, was bereits vorbei ist – eine Erinnerung für gestern
/// würde beim Planen entweder abgelehnt oder sofort ausgelöst.
List<ScheduledReminder> planReminders({
  required ExamDate? examDate,
  required ReminderSettings settings,
  required DateTime now,
}) {
  if (examDate == null || !settings.enabled) return const [];

  final reminders = <ScheduledReminder>[];
  final leadDays = settings.leadDays.toList()..sort((a, b) => b.compareTo(a));

  for (final days in leadDays) {
    final day = DateTime(
      examDate.date.year,
      examDate.date.month,
      examDate.date.day,
    ).subtract(Duration(days: days));

    final when = DateTime(
      day.year,
      day.month,
      day.day,
      settings.hour,
      settings.minute,
    );

    if (!when.isAfter(now)) continue;

    reminders.add(
      ScheduledReminder(
        id: _reminderIdBase + days,
        when: when,
        leadDays: days,
        title: _title(days),
        body: _body(days, examDate.label),
      ),
    );
  }

  return reminders;
}

/// Fester Bereich für die Kennungen, damit sie sich nicht mit später
/// hinzukommenden Benachrichtigungen überschneiden.
const int _reminderIdBase = 1000;

String _title(int days) {
  return switch (days) {
    1 => 'Morgen ist dein Einstellungstest',
    7 => 'Noch eine Woche bis zum Einstellungstest',
    _ => 'Noch $days Tage bis zum Einstellungstest',
  };
}

String _body(int days, String? label) {
  final suffix = label == null ? '' : ' ($label)';

  return switch (days) {
    1 => 'Heute noch eine kurze Runde – morgen zählt es$suffix.',
    <= 3 => 'Jetzt lohnt sich eine Testsimulation unter Zeitdruck$suffix.',
    _ => 'Eine Übungsrunde am Tag hält dich im Rhythmus$suffix.',
  };
}
