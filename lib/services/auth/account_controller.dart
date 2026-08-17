import 'package:einstellungstest_trainer/services/auth/auth_service.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/services/sync/cloud_sync_service.dart';
import 'package:einstellungstest_trainer/services/sync/sync_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountState {
  const AccountState({this.busy = false, this.error, this.notice});

  final bool busy;
  final String? error;
  final String? notice;
}

/// Anmelden, Abmelden, Konto löschen.
///
/// Nach erfolgreicher Anmeldung wird sofort abgeglichen – genau das ist der
/// Moment, in dem lokal Geübtes in die Cloud wandert.
class AccountController extends Notifier<AccountState> {
  @override
  AccountState build() => const AccountState();

  Future<void> signIn(AuthProviderKind provider) async {
    if (state.busy) return;
    state = const AccountState(busy: true);

    try {
      final user = await ref.read(authServiceProvider).signIn(provider);
      // Den Stream anstossen, damit die Oberflaeche das Konto sieht ...
      ref.read(authUserProvider);
      // ... aber fuer den Abgleich das Konto direkt weiterreichen: Der Stream
      // meldet es erst im naechsten Tick.
      await ref.read(syncControllerProvider.notifier).syncNow(user: user);

      state = const AccountState(notice: 'Angemeldet und abgeglichen');
    } on AuthFailure catch (failure) {
      state = AccountState(error: failure.cancelled ? null : failure.message);
    } catch (error) {
      state = AccountState(error: 'Anmeldung fehlgeschlagen: $error');
    }
  }

  /// Meldet ab. Der lokale Fortschritt bleibt auf dem Gerät – abmelden ist
  /// kein Löschen.
  Future<void> signOut() async {
    if (state.busy) return;
    state = const AccountState(busy: true);

    try {
      // Vor dem Abmelden noch einmal sichern, damit nichts verloren geht.
      await ref.read(syncControllerProvider.notifier).syncNow();
      await ref.read(authServiceProvider).signOut();
      ref.read(syncControllerProvider.notifier).reset();

      state = const AccountState(
        notice: 'Abgemeldet. Dein Fortschritt bleibt auf diesem Gerät.',
      );
    } catch (error) {
      state = AccountState(error: 'Abmelden fehlgeschlagen: $error');
    }
  }

  /// Löscht Konto und Cloud-Daten (DSGVO Art. 17).
  ///
  /// Reihenfolge ist wichtig: erst die Firestore-Daten, dann das Konto. Nach
  /// dem Löschen des Kontos fehlt die Berechtigung für die eigenen Dokumente.
  Future<void> deleteAccount({bool alsoWipeLocal = true}) async {
    if (state.busy) return;

    final user = ref.read(authUserProvider).value;
    if (user == null) return;

    state = const AccountState(busy: true);

    try {
      await ref.read(cloudSyncServiceProvider).deleteEverything(user.uid);
      await ref.read(authServiceProvider).deleteAccount();

      if (alsoWipeLocal) {
        await ref.read(storageServiceProvider).resetEverything();
        ref.invalidate(statsControllerProvider);
        ref.invalidate(sessionHistoryProvider);
        ref.invalidate(examDateProvider);
      }
      ref.read(syncControllerProvider.notifier).reset();

      state = const AccountState(notice: 'Konto und Daten wurden gelöscht.');
    } on AuthFailure catch (failure) {
      state = AccountState(error: failure.message);
    } on SyncFailure catch (failure) {
      state = AccountState(error: failure.message);
    } catch (error) {
      state = AccountState(error: 'Löschen fehlgeschlagen: $error');
    }
  }

  void clearMessage() => state = const AccountState();
}

final accountControllerProvider =
    NotifierProvider<AccountController, AccountState>(AccountController.new);
