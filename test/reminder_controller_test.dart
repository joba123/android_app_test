import 'package:einstellungstest_trainer/services/exam_date_controller.dart';
import 'package:einstellungstest_trainer/services/notifications/reminder_controller.dart';
import 'package:einstellungstest_trainer/services/notifications/reminder_service.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/models/module_stats.dart';
import 'package:einstellungstest_trainer/services/sync/cloud_models.dart';
import 'package:einstellungstest_trainer/services/sync/sync_merge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late InMemoryReminderService service;
  late ProviderContainer container;

  Future<ProviderContainer> build() async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        reminderServiceProvider.overrideWithValue(service),
      ],
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    service = InMemoryReminderService();
    container = await build();
  });

  tearDown(() => container.dispose());

  ReminderController controller() =>
      container.read(reminderControllerProvider.notifier);

  ExamDateController examDate() => container.read(examDateProvider.notifier);

  /// Ein Termin weit genug in der Zukunft, dass alle Vorlaufzeiten greifen.
  final futureExam = DateTime.now().add(const Duration(days: 60));

  group('Einschalten', () {
    test('fragt die Berechtigung an und merkt sich den Schalter', () async {
      await examDate().set(futureExam);

      final outcome = await controller().enable();

      expect(outcome, PermissionOutcome.granted);
      expect(service.permissionRequested, isTrue);
      expect(container.read(reminderControllerProvider).enabled, isTrue);
    });

    test('bleibt aus, wenn die Berechtigung verweigert wird', () async {
      service.grantPermission = false;
      await examDate().set(futureExam);

      final outcome = await controller().enable();

      expect(outcome, PermissionOutcome.denied);
      expect(container.read(reminderControllerProvider).enabled, isFalse);
      expect(service.scheduled, isEmpty);
    });

    test('plant die Erinnerungen sofort', () async {
      await examDate().set(futureExam);
      await controller().enable();

      expect(service.scheduled.map((entry) => entry.leadDays), [7, 1]);
    });

    test('überdauert einen Neustart der App', () async {
      await examDate().set(futureExam);
      await controller().enable();
      await controller().toggleLead(14);

      container.dispose();
      container = await build();

      final restored = container.read(reminderControllerProvider);
      expect(restored.enabled, isTrue);
      expect(restored.leadDays, {14, 7, 1});
    });
  });

  group('Ausschalten', () {
    test('nimmt alle geplanten Erinnerungen zurück', () async {
      await examDate().set(futureExam);
      await controller().enable();
      expect(service.scheduled, isNotEmpty);

      await controller().disable();

      expect(service.scheduled, isEmpty);
      expect(service.cancelCalls, greaterThan(0));
    });
  });

  group('Änderungen am Termin', () {
    test('verschieben die Erinnerungen mit', () async {
      await examDate().set(futureExam);
      await controller().enable();
      final before = service.scheduled.map((entry) => entry.when).toList();

      await examDate().set(futureExam.add(const Duration(days: 14)));

      final after = service.scheduled.map((entry) => entry.when).toList();
      expect(after, isNot(before));
      expect(after.first.difference(before.first).inDays, 14);
    });

    test('ein entfernter Termin räumt die Erinnerungen ab', () async {
      await examDate().set(futureExam);
      await controller().enable();

      await examDate().clear();

      expect(service.scheduled, isEmpty);
      expect(container.read(reminderControllerProvider).enabled, isTrue);
    });

    test('ein aus der Cloud übernommener Termin plant neu', () async {
      // Genau der Fall, der beim Anmelden auf einem zweiten Geraet auftritt.
      await controller().enable();
      expect(service.scheduled, isEmpty);

      final fromCloud = futureExam;
      await examDate().applyFromSync(
        SyncOutcome(
          stats: TrainingStats.empty(),
          sessions: const [],
          toUpload: const [],
          profile: const CloudProfile(),
          examDate: fromCloud,
          examLabel: 'Bahn',
          examUpdatedAt: DateTime.now(),
          downloadedCount: 0,
        ),
      );

      expect(service.scheduled, hasLength(2));
      expect(service.scheduled.first.body, contains('Bahn'));
    });

    test('ein unveränderter Termin plant nicht erneut', () async {
      await examDate().set(futureExam);
      await controller().enable();
      final callsBefore = service.scheduleCalls;

      await examDate().applyFromSync(
        SyncOutcome(
          stats: TrainingStats.empty(),
          sessions: const [],
          toUpload: const [],
          profile: const CloudProfile(),
          examDate: futureExam,
          examLabel: null,
          examUpdatedAt: DateTime.now(),
          downloadedCount: 0,
        ),
      );

      expect(service.scheduleCalls, callsBefore);
    });
  });

  group('Vorlaufzeiten und Uhrzeit', () {
    test('eine zusätzliche Vorlaufzeit erzeugt eine Erinnerung mehr', () async {
      await examDate().set(futureExam);
      await controller().enable();

      await controller().toggleLead(30);

      expect(service.scheduled.map((entry) => entry.leadDays), [30, 7, 1]);
    });

    test('eine andere Uhrzeit verschiebt alle Erinnerungen', () async {
      await examDate().set(futureExam);
      await controller().enable();

      await controller().setTime(hour: 8, minute: 15);

      expect(
        service.scheduled.every(
          (entry) => entry.when.hour == 8 && entry.when.minute == 15,
        ),
        isTrue,
      );
    });
  });

  group('Abgeleitete Anzeige', () {
    test('zeigt, was tatsächlich geplant ist', () async {
      await examDate().set(futureExam);
      await controller().enable();

      final planned = container.read(plannedRemindersProvider);

      expect(
        planned.map((entry) => entry.id),
        service.scheduled.map((entry) => entry.id),
      );
    });

    test('ist leer, solange kein Termin gesetzt ist', () async {
      await controller().enable();

      expect(container.read(plannedRemindersProvider), isEmpty);
    });
  });

  group('Ohne Unterstützung', () {
    test('bleibt der Schalter aus und nichts schlägt fehl', () async {
      final prefs = await SharedPreferences.getInstance();
      final local = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(local.dispose);

      expect(local.read(reminderServiceProvider).isAvailable, isFalse);

      await local.read(examDateProvider.notifier).set(futureExam);
      final outcome =
          await local.read(reminderControllerProvider.notifier).enable();

      expect(outcome, PermissionOutcome.unsupported);
      expect(local.read(reminderControllerProvider).enabled, isFalse);
    });
  });
}
