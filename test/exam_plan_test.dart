import 'package:einstellungstest_trainer/models/exam_plan.dart';
import 'package:einstellungstest_trainer/models/field_of_study.dart';
import 'package:einstellungstest_trainer/services/exam_date_controller.dart';
import 'package:einstellungstest_trainer/services/exam_plan_controller.dart';
import 'package:einstellungstest_trainer/services/notifications/reminder_controller.dart';
import 'package:einstellungstest_trainer/services/notifications/reminder_service.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';



void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Eine Prüfung als Datensatz', () {
    test('überlebt den Weg durch JSON', () {
      final plan = ExamPlan(
        id: 'plan_7',
        title: 'Polizei Niedersachsen',
        field: FieldOfStudy.police,
        date: DateTime(2026, 11, 3),
        createdAt: DateTime(2026, 8, 19, 12),
      );

      final restored = ExamPlan.fromJson(plan.toJson());

      expect(restored.id, plan.id);
      expect(restored.title, plan.title);
      expect(restored.field, FieldOfStudy.police);
      expect(restored.date, plan.date);
      expect(restored.createdAt, plan.createdAt);
    });

    test('kommt ohne Termin aus', () {
      final plan = ExamPlan(
        id: 'plan_8',
        title: 'Noch offen',
        field: FieldOfStudy.general,
        createdAt: DateTime(2026, 8, 19),
      );

      expect(plan.date, isNull);
      expect(plan.daysUntil(DateTime(2026, 8, 19)), isNull);
      expect(ExamPlan.fromJson(plan.toJson()).date, isNull);
    });

    test('zählt die Tage bis zum Termin', () {
      final plan = ExamPlan(
        id: 'plan_9',
        title: 'Bahn',
        field: FieldOfStudy.transport,
        date: DateTime(2026, 9, 1),
        createdAt: DateTime(2026, 8, 1),
      );

      expect(plan.daysUntil(DateTime(2026, 8, 19, 23)), 13);
      expect(plan.daysUntil(DateTime(2026, 9, 1, 6)), 0);
      expect(plan.daysUntil(DateTime(2026, 9, 5)), -4);
    });
  });

  group('Prüfungen verwalten', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          reminderServiceProvider.overrideWithValue(InMemoryReminderService()),
        ],
      );
      addTearDown(container.dispose);
    });

    test('beim ersten Start steht genau eine Prüfung bereit', () {
      final plans = container.read(examPlansProvider);

      expect(plans.plans, hasLength(1));
      expect(plans.active, isNotNull);
      expect(plans.active!.field, FieldOfStudy.general);
      expect(plans.active!.date, isNull);
    });

    test('eine weitere Prüfung wird sofort die aktive', () async {
      await container.read(examPlansProvider.notifier).add(
            title: 'Feuerwehr Bremen',
            field: FieldOfStudy.fireBrigade,
            date: DateTime(2026, 12, 1),
          );

      final plans = container.read(examPlansProvider);
      expect(plans.plans, hasLength(2));
      expect(plans.active!.title, 'Feuerwehr Bremen');
      expect(plans.active!.field, FieldOfStudy.fireBrigade);
    });

    test('der Termin der aktiven Prüfung wird durchgeschrieben', () async {
      await container.read(examPlansProvider.notifier).add(
            title: 'Bahn',
            field: FieldOfStudy.transport,
            date: DateTime(2026, 10, 5),
          );

      // Erinnerungen und Cloud-Abgleich haengen weiter am Testtermin.
      expect(container.read(examDateProvider)?.date, DateTime(2026, 10, 5));

      await container.read(examPlansProvider.notifier).add(
            title: 'Ohne Termin',
            field: FieldOfStudy.general,
          );

      expect(container.read(examDateProvider), isNull);
    });

    test('der Wechsel bringt den Termin der gewählten Prüfung mit', () async {
      final notifier = container.read(examPlansProvider.notifier);
      final firstId = container.read(examPlansProvider).activeId;

      await notifier.add(
        title: 'Mit Termin',
        field: FieldOfStudy.banking,
        date: DateTime(2027, 1, 15),
      );
      expect(container.read(examDateProvider)?.date, DateTime(2027, 1, 15));

      await notifier.select(firstId);
      expect(container.read(examDateProvider), isNull);
    });

    test('die letzte Prüfung lässt sich nicht entfernen', () async {
      final notifier = container.read(examPlansProvider.notifier);
      final id = container.read(examPlansProvider).activeId;

      await notifier.remove(id);

      expect(container.read(examPlansProvider).plans, hasLength(1));
    });

    test('nach dem Entfernen ist wieder eine Prüfung aktiv', () async {
      final notifier = container.read(examPlansProvider.notifier);
      await notifier.add(title: 'Zweite', field: FieldOfStudy.health);

      final activeId = container.read(examPlansProvider).activeId;
      await notifier.remove(activeId);

      final plans = container.read(examPlansProvider);
      expect(plans.plans, hasLength(1));
      expect(plans.active, isNotNull);
      expect(plans.activeId, plans.active!.id);
    });

    test('Änderungen überleben einen Neustart', () async {
      await container.read(examPlansProvider.notifier).add(
            title: 'Verwaltung Hamburg',
            field: FieldOfStudy.publicService,
          );

      final prefs = await SharedPreferences.getInstance();
      final fresh = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          reminderServiceProvider.overrideWithValue(InMemoryReminderService()),
        ],
      );
      addTearDown(fresh.dispose);

      final plans = fresh.read(examPlansProvider);
      expect(plans.plans, hasLength(2));
      expect(plans.active!.title, 'Verwaltung Hamburg');
      expect(plans.active!.field, FieldOfStudy.publicService);
    });
  });
}
