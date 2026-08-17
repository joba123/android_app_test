import 'dart:async';

import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';
import 'package:einstellungstest_trainer/services/auth/account_controller.dart';
import 'package:einstellungstest_trainer/services/auth/auth_service.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/services/sync/cloud_sync_service.dart';
import 'package:einstellungstest_trainer/services/sync/sync_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Anmeldung ohne Firebase: kontrolliert steuerbar, ohne Platform-Channels.
class FakeAuthService implements AuthService {
  FakeAuthService();

  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();

  AuthUser? _user;
  bool failNextSignIn = false;
  bool deleted = false;

  @override
  bool get isAvailable => true;

  @override
  AuthUser? get currentUser => _user;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield _user;
    yield* _controller.stream;
  }

  @override
  Future<AuthUser> signIn(AuthProviderKind provider) async {
    if (failNextSignIn) throw const AuthFailure.cancelled();

    _user = AuthUser(uid: 'uid-1', provider: provider, displayName: 'Testerin');
    _controller.add(_user);
    return _user!;
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }

  @override
  Future<void> deleteAccount() async {
    deleted = true;
    _user = null;
    _controller.add(null);
  }
}

TrainingSession session(String id, {DateTime? finishedAt}) {
  final end = finishedAt ?? DateTime.utc(2026, 3, 1);
  return TrainingSession(
    id: id,
    mode: SessionMode.practice,
    module: TrainingModule.math,
    startedAt: end.subtract(const Duration(minutes: 4)),
    finishedAt: end,
    results: [
      for (var index = 0; index < 4; index++)
        QuestionResult(
          questionId: '$id-$index',
          subCategory: SubCategory.arithmetic,
          answered: true,
          correct: index < 3,
          timeSpent: const Duration(seconds: 9),
        ),
    ],
  );
}

void main() {
  late FakeAuthService auth;
  late InMemoryCloudSyncService cloud;
  late ProviderContainer container;

  Future<ProviderContainer> build() async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authServiceProvider.overrideWithValue(auth),
        cloudSyncServiceProvider.overrideWithValue(cloud),
      ],
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    auth = FakeAuthService();
    cloud = InMemoryCloudSyncService();
    container = await build();
  });

  tearDown(() => container.dispose());

  Future<void> signIn() async {
    await container
        .read(accountControllerProvider.notifier)
        .signIn(AuthProviderKind.google);
  }

  group('Abgleich', () {
    test('passiert ohne Anmeldung nicht', () async {
      await container.read(syncControllerProvider.notifier).syncNow();

      expect(container.read(syncControllerProvider).status, SyncStatus.idle);
      expect(cloud.uploadCalls, 0);
    });

    test('lädt beim Anmelden den lokalen Fortschritt hoch', () async {
      await container
          .read(statsControllerProvider.notifier)
          .record(session('a'));

      await signIn();

      expect(container.read(syncControllerProvider).status, SyncStatus.success);
      expect(cloud.uploadedSessionCount, 1);
      expect(await cloud.loadSessionIds('uid-1'), {'a'});

      final profile = await cloud.loadProfile('uid-1');
      expect(profile?.progress[TrainingModule.math]?.answered, 4);
      expect(profile?.progress[TrainingModule.math]?.correct, 3);
    });

    test('ist wiederholbar, ohne den Fortschritt zu verdoppeln', () async {
      await container
          .read(statsControllerProvider.notifier)
          .record(session('a'));
      await signIn();

      final uploadedAfterFirst = cloud.uploadedSessionCount;
      await container.read(syncControllerProvider.notifier).syncNow();
      await container.read(syncControllerProvider.notifier).syncNow();

      expect(cloud.uploadedSessionCount, uploadedAfterFirst);
      expect(
        container.read(statsControllerProvider).forModule(TrainingModule.math)
            .answered,
        4,
      );
      final profile = await cloud.loadProfile('uid-1');
      expect(profile?.progress[TrainingModule.math]?.answered, 4);
    });

    test('holt Sitzungen aus der Cloud auf das Gerät', () async {
      // Erstes Geraet legt eine Sitzung ab ...
      await container
          .read(statsControllerProvider.notifier)
          .record(session('vom-anderen-geraet'));
      await signIn();

      // ... ein frisch installiertes Geraet meldet sich am selben Konto an.
      container.dispose();
      SharedPreferences.setMockInitialValues({});
      auth = FakeAuthService();
      container = await build();

      await signIn();

      final history = container.read(sessionHistoryProvider);
      expect(history.map((entry) => entry.id), ['vom-anderen-geraet']);
      expect(
        container.read(statsControllerProvider).forModule(TrainingModule.math)
            .answered,
        4,
      );
      expect(container.read(syncControllerProvider).downloaded, 1);
    });

    test('meldet einen Fehlschlag, ohne lokale Daten anzutasten', () async {
      await container
          .read(statsControllerProvider.notifier)
          .record(session('a'));

      container.dispose();
      cloud = _FailingCloudSyncService();
      container = await build();
      await signIn();

      expect(container.read(syncControllerProvider).status, SyncStatus.failed);
      expect(container.read(syncControllerProvider).error, isNotNull);
      expect(container.read(sessionHistoryProvider), isNotEmpty);
    });
  });

  group('Testtermin', () {
    test('wandert mit in die Cloud', () async {
      await container
          .read(examDateProvider.notifier)
          .set(DateTime.utc(2026, 11, 3), label: 'Polizei');

      await signIn();

      final profile = await cloud.loadProfile('uid-1');
      expect(profile?.examDate, DateTime.utc(2026, 11, 3));
      expect(profile?.examLabel, 'Polizei');
    });

    test('kommt beim Anmelden auf ein leeres Gerät zurück', () async {
      await container
          .read(examDateProvider.notifier)
          .set(DateTime.utc(2026, 11, 3), label: 'Polizei');
      await signIn();

      container.dispose();
      SharedPreferences.setMockInitialValues({});
      auth = FakeAuthService();
      container = await build();
      await signIn();

      final examDate = container.read(examDateProvider);
      expect(examDate?.date.toUtc(), DateTime.utc(2026, 11, 3));
      expect(examDate?.label, 'Polizei');
    });

    test('wird lokal gespeichert und wieder geladen', () async {
      await container
          .read(examDateProvider.notifier)
          .set(DateTime.utc(2026, 12, 24));

      final reloaded = container.read(storageServiceProvider).loadExamDate();
      expect(reloaded?.date.toUtc(), DateTime.utc(2026, 12, 24));

      await container.read(examDateProvider.notifier).clear();
      expect(container.read(storageServiceProvider).loadExamDate(), isNull);
      expect(container.read(examDateProvider), isNull);
    });
  });

  group('Konto', () {
    test('Abbruch der Anmeldung erzeugt keine Fehlermeldung', () async {
      auth.failNextSignIn = true;

      await signIn();

      expect(container.read(accountControllerProvider).error, isNull);
      expect(container.read(authUserProvider).value, isNull);
    });

    test('Abmelden behält den lokalen Fortschritt', () async {
      await container
          .read(statsControllerProvider.notifier)
          .record(session('a'));
      await signIn();

      await container.read(accountControllerProvider.notifier).signOut();

      expect(container.read(authUserProvider).value, isNull);
      expect(container.read(sessionHistoryProvider), hasLength(1));
      expect(container.read(syncControllerProvider).status, SyncStatus.idle);
    });

    test('Löschen räumt Cloud, Konto und Gerät ab', () async {
      await container
          .read(statsControllerProvider.notifier)
          .record(session('a'));
      await container
          .read(examDateProvider.notifier)
          .set(DateTime.utc(2026, 11, 3));
      await signIn();

      await container.read(accountControllerProvider.notifier).deleteAccount();

      expect(auth.deleted, isTrue);
      expect(await cloud.loadProfile('uid-1'), isNull);
      expect(await cloud.loadSessionIds('uid-1'), isEmpty);
      expect(container.read(sessionHistoryProvider), isEmpty);
      expect(container.read(statsControllerProvider).totalAnswered, 0);
      expect(container.read(examDateProvider), isNull);
    });
  });

  group('Lokaler Modus', () {
    test('ohne Firebase gibt es keine Anmeldung', () async {
      final prefs = await SharedPreferences.getInstance();
      final local = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(local.dispose);

      expect(local.read(authServiceProvider).isAvailable, isFalse);
      expect(await local.read(authUserProvider.future), isNull);

      await local
          .read(accountControllerProvider.notifier)
          .signIn(AuthProviderKind.google);

      expect(local.read(accountControllerProvider).error, isNotNull);
    });

    test('Üben und Speichern funktionieren unverändert', () async {
      final prefs = await SharedPreferences.getInstance();
      final local = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(local.dispose);

      await local.read(statsControllerProvider.notifier).record(session('a'));

      expect(local.read(statsControllerProvider).totalAnswered, 4);
      expect(local.read(sessionHistoryProvider), hasLength(1));
    });
  });
}

/// Cloud, die nicht erreichbar ist.
class _FailingCloudSyncService extends InMemoryCloudSyncService {
  @override
  Future<Never> loadProfile(String uid) async {
    throw const SyncFailure('Die Cloud ist gerade nicht erreichbar.');
  }
}
