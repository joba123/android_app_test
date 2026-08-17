import 'dart:async';

import 'package:einstellungstest_trainer/models/pro_entitlement.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/services/purchase/purchase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wird in `main()` mit [StorePurchaseService] überschrieben.
final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  return const UnavailablePurchaseService();
});

/// Die aktuell geltende Berechtigung, `null` in der kostenlosen Version.
class EntitlementController extends Notifier<ProEntitlement?> {
  StreamSubscription<PurchaseEvent>? _subscription;

  @override
  ProEntitlement? build() {
    final stored = ref.watch(storageServiceProvider).loadEntitlement();

    // Der Store meldet Käufe auch dann, wenn sie woanders ausgelöst wurden –
    // etwa eine Verlängerung oder eine Rückerstattung.
    _subscription = ref.read(purchaseServiceProvider).events.listen(_apply);
    ref.onDispose(() => _subscription?.cancel());

    // Abgelaufene Abos gelten nicht mehr; der Eintrag bleibt aber liegen,
    // bis der Store etwas Neues sagt.
    if (stored != null && !stored.isActive(DateTime.now())) return null;
    return stored;
  }

  void _apply(PurchaseEvent event) {
    if (event is! PurchaseSucceeded) return;

    state = event.entitlement;
    unawaited(
      ref.read(storageServiceProvider).saveEntitlement(event.entitlement),
    );
  }

  /// Setzt die lokale Kopie zurück – nur für den Fall, dass der Store eine
  /// Berechtigung nicht mehr bestätigt.
  Future<void> clear() async {
    state = null;
    await ref.read(storageServiceProvider).saveEntitlement(null);
  }
}

final entitlementProvider =
    NotifierProvider<EntitlementController, ProEntitlement?>(
  EntitlementController.new,
);

/// Die eine Frage, die der Rest der App stellt.
///
/// Alles, was Pro betrifft – Werbefreiheit, Zusatzinhalte, Verlaufslänge –
/// hängt an diesem einen Provider, damit die Sperren nicht auseinanderlaufen.
final isProProvider = Provider<bool>((ref) {
  final entitlement = ref.watch(entitlementProvider);
  return entitlement != null && entitlement.isActive(DateTime.now());
});

/// Wie viele Sitzungen im Verlauf bleiben.
final historyLimitProvider = Provider<int>((ref) {
  return ref.watch(isProProvider)
      ? ProBenefits.proHistoryLimit
      : ProBenefits.freeHistoryLimit;
});

/// Zustand des Kauf-Screens.
class PurchaseUiState {
  const PurchaseUiState({
    this.offers = const [],
    this.loading = true,
    this.busyPlan,
    this.error,
    this.notice,
  });

  final List<ProOffer> offers;
  final bool loading;

  /// Welcher Tarif gerade gekauft wird – nur dieser Knopf zeigt einen
  /// Fortschritt, die anderen bleiben bedienbar aussehend inaktiv.
  final ProPlan? busyPlan;

  final String? error;
  final String? notice;

  bool get busy => busyPlan != null;

  PurchaseUiState copyWith({
    List<ProOffer>? offers,
    bool? loading,
    ProPlan? busyPlan,
    String? error,
    String? notice,
    bool clearBusy = false,
  }) {
    return PurchaseUiState(
      offers: offers ?? this.offers,
      loading: loading ?? this.loading,
      busyPlan: clearBusy ? null : (busyPlan ?? this.busyPlan),
      error: error,
      notice: notice,
    );
  }
}

/// Steuert den Kauf-Screen.
class PurchaseController extends Notifier<PurchaseUiState> {
  StreamSubscription<PurchaseEvent>? _subscription;

  @override
  PurchaseUiState build() {
    _subscription = ref.read(purchaseServiceProvider).events.listen(_onEvent);
    ref.onDispose(() => _subscription?.cancel());

    unawaited(loadOffers());
    return const PurchaseUiState();
  }

  Future<void> loadOffers() async {
    final service = ref.read(purchaseServiceProvider);

    try {
      final offers = await service.loadOffers();
      state = state.copyWith(offers: offers, loading: false);
    } catch (error) {
      state = state.copyWith(
        loading: false,
        error: 'Die Angebote konnten nicht geladen werden.',
      );
    }
  }

  Future<void> buy(ProPlan plan) async {
    if (state.busy) return;
    state = state.copyWith(busyPlan: plan, loading: false);

    try {
      await ref.read(purchaseServiceProvider).buy(plan);
    } catch (error) {
      state = state.copyWith(
        clearBusy: true,
        error: 'Der Kauf konnte nicht gestartet werden.',
      );
    }
  }

  Future<void> restore() async {
    if (state.busy) return;

    try {
      await ref.read(purchaseServiceProvider).restore();

      // Hat der Store nichts gemeldet, gibt es auch nichts – das ist eine
      // Auskunft und kein Fehler.
      if (!ref.read(isProProvider)) {
        state = state.copyWith(
          notice: 'Für dieses Konto liegt kein früherer Kauf vor.',
        );
      }
    } catch (error) {
      state = state.copyWith(
        error: 'Die Wiederherstellung ist fehlgeschlagen.',
      );
    }
  }

  void _onEvent(PurchaseEvent event) {
    state = switch (event) {
      PurchaseSucceeded(restored: final restored) => state.copyWith(
          clearBusy: true,
          notice: restored ? 'Pro wiederhergestellt.' : 'Danke – Pro ist aktiv.',
        ),
      PurchaseCancelled() => state.copyWith(clearBusy: true),
      PurchaseFailed(message: final message) =>
        state.copyWith(clearBusy: true, error: message),
    };
  }

  void clearMessages() => state = state.copyWith();
}

final purchaseControllerProvider =
    NotifierProvider<PurchaseController, PurchaseUiState>(
  PurchaseController.new,
);
