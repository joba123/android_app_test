import 'dart:async';

import 'package:einstellungstest_trainer/models/pro_entitlement.dart';

/// Ergebnis eines Kaufvorgangs, so wie ihn der Store meldet.
sealed class PurchaseEvent {
  const PurchaseEvent();
}

/// Kauf erfolgreich – oder eine frühere Berechtigung wiederhergestellt.
class PurchaseSucceeded extends PurchaseEvent {
  const PurchaseSucceeded(this.entitlement, {this.restored = false});

  final ProEntitlement entitlement;
  final bool restored;
}

class PurchaseCancelled extends PurchaseEvent {
  const PurchaseCancelled();
}

class PurchaseFailed extends PurchaseEvent {
  const PurchaseFailed(this.message);

  final String message;
}

/// Zugang zum Store.
///
/// Die Oberfläche kennt nur diese Schnittstelle. Dadurch bleibt der gesamte
/// Kauf- und Freischaltweg ohne Platform-Channels prüfbar – und ein Wechsel
/// der Abrechnungs-Bibliothek (etwa zu RevenueCat) beträfe nur die
/// Implementierung, nicht die App.
abstract class PurchaseService {
  /// `false`, wenn kein Store erreichbar ist. Die Oberfläche erklärt das,
  /// statt Kaufknöpfe anzubieten, die nur scheitern können.
  bool get isAvailable;

  Future<List<ProOffer>> loadOffers();

  /// Startet den Kauf. Das Ergebnis kommt über [events] – der Store kann den
  /// Vorgang aussetzen und später fortsetzen.
  Future<void> buy(ProPlan plan);

  /// Stellt frühere Käufe wieder her (Gerätewechsel, Neuinstallation).
  Future<void> restore();

  Stream<PurchaseEvent> get events;

  Future<void> dispose();
}

/// Kein Store vorhanden.
class UnavailablePurchaseService implements PurchaseService {
  const UnavailablePurchaseService();

  @override
  bool get isAvailable => false;

  @override
  Future<List<ProOffer>> loadOffers() async => const [];

  @override
  Future<void> buy(ProPlan plan) async {}

  @override
  Future<void> restore() async {}

  @override
  Stream<PurchaseEvent> get events => const Stream.empty();

  @override
  Future<void> dispose() async {}
}

/// Store-Ersatz für Tests.
class InMemoryPurchaseService implements PurchaseService {
  InMemoryPurchaseService({this.offers = defaultOffers});

  static const List<ProOffer> defaultOffers = [
    ProOffer(plan: ProPlan.lifetime, price: '9,99 €', rawPrice: 9.99,
        currency: 'EUR'),
    ProOffer(plan: ProPlan.monthly, price: '2,99 €', rawPrice: 2.99,
        currency: 'EUR'),
    ProOffer(plan: ProPlan.yearly, price: '19,99 €', rawPrice: 19.99,
        currency: 'EUR'),
  ];

  final List<ProOffer> offers;

  final StreamController<PurchaseEvent> _events =
      StreamController<PurchaseEvent>.broadcast();

  /// Steuert, wie der nächste Kauf ausgeht.
  PurchaseEvent Function(ProPlan plan)? nextOutcome;

  /// Was `restore()` liefert.
  ProEntitlement? restorable;

  ProPlan? lastPurchased;
  int restoreCalls = 0;

  @override
  bool get isAvailable => true;

  @override
  Future<List<ProOffer>> loadOffers() async => offers;

  @override
  Future<void> buy(ProPlan plan) async {
    lastPurchased = plan;

    final outcome = nextOutcome?.call(plan) ??
        PurchaseSucceeded(
          ProEntitlement(
            plan: plan,
            since: DateTime.now(),
            expiresAt: plan.isSubscription
                ? DateTime.now().add(const Duration(days: 30))
                : null,
          ),
        );

    _events.add(outcome);
  }

  @override
  Future<void> restore() async {
    restoreCalls++;

    final entitlement = restorable;
    if (entitlement != null) {
      _events.add(PurchaseSucceeded(entitlement, restored: true));
    }
  }

  @override
  Stream<PurchaseEvent> get events => _events.stream;

  @override
  Future<void> dispose() async => _events.close();
}
