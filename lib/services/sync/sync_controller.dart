import 'package:einstellungstest_trainer/models/exam_date.dart';
import 'package:einstellungstest_trainer/services/auth/auth_service.dart';
import 'package:einstellungstest_trainer/services/auth/firebase_auth_service.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/services/sync/cloud_sync_service.dart';
import 'package:einstellungstest_trainer/services/sync/firestore_sync_service.dart';
import 'package:einstellungstest_trainer/services/sync/sync_merge.dart';
import 'package:einstellungstest_trainer/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ob Firebase beim Start erfolgreich initialisiert werden konnte.
///
/// Wird in `main()` überschrieben. Ohne Konfiguration bleibt der Wert `false`
/// und die App läuft im lokalen Modus – auch in Tests, die dadurch ohne
/// Platform-Channels auskommen.
final firebaseReadyProvider = Provider<bool>((ref) => false);

final authServiceProvider = Provider<AuthService>((ref) {
  return ref.watch(firebaseReadyProvider)
      ? FirebaseAuthService()
      : const UnavailableAuthService();
});

final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  return ref.watch(firebaseReadyProvider)
      ? FirestoreSyncService()
      : InMemoryCloudSyncService();
});

/// Das aktuell angemeldete Konto, `null` im lokalen Modus.
final authUserProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

/// Der hinterlegte Testtermin.
class ExamDateController extends Notifier<ExamDate?> {
  @override
  ExamDate? build() => ref.watch(storageServiceProvider).loadExamDate();

  Future<void> set(DateTime date, {String? label}) async {
    final entry = ExamDate(
      date: date,
      updatedAt: DateTime.now(),
      label: (label != null && label.trim().isEmpty) ? null : label?.trim(),
    );

    state = entry;
    await ref.read(storageServiceProvider).saveExamDate(entry);
  }

  Future<void> clear() async {
    state = null;
    await ref.read(storageServiceProvider).saveExamDate(null);
  }

  /// Übernimmt das Ergebnis eines Abgleichs, ohne erneut zu schreiben, was
  /// ohnehin schon lokal stand.
  Future<void> applyFromSync(SyncOutcome outcome) async {
    final date = outcome.examDate;
    if (date == null) return;

    final entry = ExamDate(
      date: date,
      updatedAt: outcome.examUpdatedAt ?? DateTime.now(),
      label: outcome.examLabel,
    );

    state = entry;
    await ref.read(storageServiceProvider).saveExamDate(entry);
  }
}

final examDateProvider =
    NotifierProvider<ExamDateController, ExamDate?>(ExamDateController.new);

enum SyncStatus { idle, running, success, failed }

class SyncState {
  const SyncState({
    this.status = SyncStatus.idle,
    this.lastSyncedAt,
    this.uploaded = 0,
    this.downloaded = 0,
    this.error,
  });

  final SyncStatus status;
  final DateTime? lastSyncedAt;
  final int uploaded;
  final int downloaded;
  final String? error;

  bool get isRunning => status == SyncStatus.running;
}

/// Gleicht den lokalen Stand mit der Cloud ab.
///
/// Der Abgleich ist bewusst so gebaut, dass er jederzeit wiederholbar ist:
/// Die Zusammenführung in [mergeForSync] lädt nur hoch, was der Cloud fehlt.
class SyncController extends Notifier<SyncState> {
  @override
  SyncState build() => const SyncState();

  /// Führt einen vollständigen Abgleich durch. Ohne Anmeldung passiert nichts.
  ///
  /// [user] wird direkt nach der Anmeldung übergeben: Der Auth-Stream meldet
  /// das neue Konto erst im nächsten Tick, und darauf zu warten wäre ein
  /// Rennen, das der erste Abgleich verlieren würde.
  Future<void> syncNow({AuthUser? user}) async {
    final account = user ?? ref.read(authUserProvider).value;
    if (account == null || state.isRunning) return;

    state = SyncState(
      status: SyncStatus.running,
      lastSyncedAt: state.lastSyncedAt,
    );

    final cloud = ref.read(cloudSyncServiceProvider);
    final storage = ref.read(storageServiceProvider);

    try {
      final profile = await cloud.loadProfile(account.uid);
      final sessionIds = await cloud.loadSessionIds(account.uid);
      final cloudSessions = await cloud.loadSessions(
        account.uid,
        limit: StorageService.maxStoredSessions,
      );

      final outcome = mergeForSync(
        local: LocalSnapshot(
          stats: ref.read(statsControllerProvider),
          sessions: ref.read(sessionHistoryProvider),
          examDate: ref.read(examDateProvider)?.date,
          examLabel: ref.read(examDateProvider)?.label,
          examUpdatedAt: ref.read(examDateProvider)?.updatedAt,
        ),
        cloudProfile: profile,
        cloudSessions: cloudSessions,
        cloudSessionIds: sessionIds,
        historyLimit: StorageService.maxStoredSessions,
      );

      await cloud.uploadSessions(account.uid, outcome.toUpload);
      await cloud.saveProfile(account.uid, outcome.profile);

      // Lokalen Stand nachziehen.
      await storage.saveStats(outcome.stats);
      await storage.replaceSessions(outcome.sessions);
      await ref.read(examDateProvider.notifier).applyFromSync(outcome);

      ref.invalidate(statsControllerProvider);
      ref.invalidate(sessionHistoryProvider);

      state = SyncState(
        status: SyncStatus.success,
        lastSyncedAt: DateTime.now(),
        uploaded: outcome.uploadedCount,
        downloaded: outcome.downloadedCount,
      );
    } on SyncFailure catch (failure) {
      state = SyncState(
        status: SyncStatus.failed,
        lastSyncedAt: state.lastSyncedAt,
        error: failure.message,
      );
    } catch (error) {
      state = SyncState(
        status: SyncStatus.failed,
        lastSyncedAt: state.lastSyncedAt,
        error: 'Abgleich fehlgeschlagen: $error',
      );
    }
  }

  void reset() => state = const SyncState();
}

final syncControllerProvider =
    NotifierProvider<SyncController, SyncState>(SyncController.new);
