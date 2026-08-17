import 'package:einstellungstest_trainer/models/exam_date.dart';
import 'package:einstellungstest_trainer/models/reminder_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ExamDate examOn(DateTime date, {String? label}) =>
      ExamDate(date: date, updatedAt: DateTime(2026, 1, 1), label: label);

  const enabled = ReminderSettings(enabled: true);

  group('Planung', () {
    test('plant je Vorlaufzeit eine Erinnerung', () {
      final reminders = planReminders(
        examDate: examOn(DateTime(2026, 6, 20)),
        settings: enabled,
        now: DateTime(2026, 6, 1, 9),
      );

      expect(reminders.map((entry) => entry.leadDays), [7, 1]);
      expect(reminders.first.when, DateTime(2026, 6, 13, 18));
      expect(reminders.last.when, DateTime(2026, 6, 19, 18));
    });

    test('nutzt die eingestellte Uhrzeit', () {
      final reminders = planReminders(
        examDate: examOn(DateTime(2026, 6, 20)),
        settings: enabled.copyWith(hour: 7, minute: 30, leadDays: {1}),
        now: DateTime(2026, 6, 1),
      );

      expect(reminders.single.when, DateTime(2026, 6, 19, 7, 30));
    });

    test('plant nichts ohne Termin', () {
      expect(
        planReminders(
          examDate: null,
          settings: enabled,
          now: DateTime(2026, 6, 1),
        ),
        isEmpty,
      );
    });

    test('plant nichts, solange die Erinnerungen aus sind', () {
      expect(
        planReminders(
          examDate: examOn(DateTime(2026, 6, 20)),
          settings: const ReminderSettings(),
          now: DateTime(2026, 6, 1),
        ),
        isEmpty,
      );
    });

    test('überspringt Zeitpunkte, die schon vorbei sind', () {
      // Zwei Tage vor dem Termin: Die 7-Tage-Erinnerung ist gelaufen.
      final reminders = planReminders(
        examDate: examOn(DateTime(2026, 6, 20)),
        settings: enabled,
        now: DateTime(2026, 6, 18, 12),
      );

      expect(reminders.map((entry) => entry.leadDays), [1]);
    });

    test('überspringt den heutigen Zeitpunkt, wenn er verstrichen ist', () {
      final reminders = planReminders(
        examDate: examOn(DateTime(2026, 6, 20)),
        settings: enabled.copyWith(leadDays: {1}),
        // Am 19.6. um 20 Uhr – die Erinnerung um 18 Uhr ist durch.
        now: DateTime(2026, 6, 19, 20),
      );

      expect(reminders, isEmpty);
    });

    test('plant nichts für einen vergangenen Termin', () {
      expect(
        planReminders(
          examDate: examOn(DateTime(2026, 6, 1)),
          settings: enabled,
          now: DateTime(2026, 6, 10),
        ),
        isEmpty,
      );
    });

    test('vergibt je Vorlaufzeit dieselbe Kennung', () {
      // Stabile Kennungen sind die Voraussetzung dafuer, dass erneutes Planen
      // ersetzt statt zu verdoppeln.
      List<int> idsFor(DateTime examDay) => planReminders(
            examDate: examOn(examDay),
            settings: enabled,
            now: DateTime(2026, 6, 1),
          ).map((entry) => entry.id).toList();

      expect(idsFor(DateTime(2026, 6, 20)), idsFor(DateTime(2026, 7, 20)));
      expect(idsFor(DateTime(2026, 6, 20)).toSet(), hasLength(2));
    });

    test('formuliert je nach Abstand unterschiedlich', () {
      final reminders = planReminders(
        examDate: examOn(DateTime(2026, 6, 20)),
        settings: enabled.copyWith(leadDays: {7, 3, 1}),
        now: DateTime(2026, 6, 1),
      );

      expect(reminders[0].title, contains('eine Woche'));
      expect(reminders[2].title, 'Morgen ist dein Einstellungstest');
      expect(reminders[1].body, contains('Testsimulation'));
    });

    test('nimmt die Beschriftung des Termins mit auf', () {
      final reminders = planReminders(
        examDate: examOn(DateTime(2026, 6, 20), label: 'Polizei NRW'),
        settings: enabled.copyWith(leadDays: {7}),
        now: DateTime(2026, 6, 1),
      );

      expect(reminders.single.body, contains('Polizei NRW'));
    });
  });

  group('Einstellungen', () {
    test('sind zu Beginn aus, mit sinnvollen Vorlaufzeiten', () {
      const settings = ReminderSettings();

      expect(settings.enabled, isFalse);
      expect(settings.leadDays, {7, 1});
      expect(settings.timeLabel, '18:00');
    });

    test('schalten eine Vorlaufzeit an und aus', () {
      const settings = ReminderSettings();

      expect(settings.toggleLead(3).leadDays, {7, 3, 1});
      expect(settings.toggleLead(7).leadDays, {1});
    });

    test('behalten mindestens eine Vorlaufzeit', () {
      // Sonst waere der Schalter an, ohne dass je etwas passiert.
      const settings = ReminderSettings(leadDays: {1});

      expect(settings.toggleLead(1).leadDays, {1});
    });

    test('ignorieren unbekannte Vorlaufzeiten', () {
      const settings = ReminderSettings();

      expect(settings.toggleLead(5).leadDays, {7, 1});
    });

    test('überstehen die Serialisierung', () {
      const settings = ReminderSettings(
        enabled: true,
        leadDays: {14, 3},
        hour: 7,
        minute: 45,
      );

      expect(ReminderSettings.fromJson(settings.toJson()), settings);
    });

    test('fangen beschädigte Daten ab', () {
      final restored = ReminderSettings.fromJson(const {
        'enabled': true,
        'leadDays': ['sieben', 99],
        'hour': 42,
        'minute': -1,
      });

      expect(restored.leadDays, ReminderSettings.defaultLeadDays);
      expect(restored.hour, 18);
      expect(restored.minute, 0);
    });
  });
}
