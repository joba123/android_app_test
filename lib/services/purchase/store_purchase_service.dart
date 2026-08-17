import 'dart:async';

import 'package:einstellungstest_trainer/models/pro_entitlement.dart';
import 'package:einstellungstest_trainer/services/purchase/purchase_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Käufe über den Store des Geräts (Google Play, später App Store).
///
/// Bewusst `in_app_purchase` und kein Drittanbieter – die Begründung steht in
/// der README. Die Schnittstelle [PurchaseService] bleibt davon unberührt,
/// sodass ein Wechsel später nur diese Datei beträfe.
class StorePurchaseService implements PurchaseService {
  StorePurchaseService({InAppPurchase? store})
      : _store = store ?? InAppPurchase.instance {
    _subscription = _store.purchaseStream.listen(
      _handlePurchases,
      onError: (Object error) => _events.add(PurchaseFailed('$error')),
    );
  }

  final InAppPurchase _store;
  late final StreamSubscription<List<PurchaseDetails>> _subscription;

  final StreamController<PurchaseEvent> _events =
      StreamController<PurchaseEvent>.broadcast();

  bool _available = false;
  Map<String, ProductDetails> _products = const {};

  @override
  bool get isAvailable => _available;

  @override
  Stream<PurchaseEvent> get events => _events.stream;

  @override
  Future<List<ProOffer>> loadOffers() async {
    _available = await _store.isAvailable();
    if (!_available) return const [];

    final response = await _store.queryProductDetails(ProPlan.productIds);
    _products = {
      for (final product in response.productDetails) product.id: product,
    };

    final offers = <ProOffer>[];
    for (final plan in ProPlan.values) {
      final product = _products[plan.productId];
      // Ein im Store nicht (mehr) angelegtes Produkt wird schlicht nicht
      // angeboten – besser als ein Knopf, der ins Leere führt.
      if (product == null) continue;

      offers.add(
        ProOffer(
          plan: plan,
          price: product.price,
          rawPrice: product.rawPrice,
          currency: product.currencyCode,
        ),
      );
    }

    return offers;
  }

  @override
  Future<void> buy(ProPlan plan) async {
    final product = _products[plan.productId];
    if (product == null) {
      _events.add(
        const PurchaseFailed('Das Angebot ist gerade nicht verfügbar.'),
      );
      return;
    }

    final parameters = PurchaseParam(productDetails: product);

    // Abos und Einmalkäufe laufen beide über buyNonConsumable: Verbraucht
    // wird hier nichts, die Freischaltung bleibt bestehen.
    await _store.buyNonConsumable(purchaseParam: parameters);
  }

  @override
  Future<void> restore() => _store.restorePurchases();

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          // Nichts zu melden – der Store zeigt seinen eigenen Fortschritt.
          break;

        case PurchaseStatus.canceled:
          _events.add(const PurchaseCancelled());

        case PurchaseStatus.error:
          _events.add(
            PurchaseFailed(
              purchase.error?.message ?? 'Der Kauf konnte nicht abgeschlossen '
                  'werden.',
            ),
          );

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final entitlement = _toEntitlement(purchase);
          if (entitlement != null) {
            _events.add(
              PurchaseSucceeded(
                entitlement,
                restored: purchase.status == PurchaseStatus.restored,
              ),
            );
          }
      }

      // Muss in jedem Fall passieren, sonst liefert der Store denselben Kauf
      // bei jedem Start erneut aus.
      if (purchase.pendingCompletePurchase) {
        await _store.completePurchase(purchase);
      }
    }
  }

  ProEntitlement? _toEntitlement(PurchaseDetails purchase) {
    final plan = ProPlan.tryFromProductId(purchase.productID);
    if (plan == null) return null;

    final since = _parseTransactionDate(purchase.transactionDate);

    return ProEntitlement(
      plan: plan,
      since: since,
      // Ein verlässliches Ablaufdatum liefert nur die Play Developer API auf
      // dem Server. Lokal wird deshalb großzügig gerechnet und beim nächsten
      // Store-Abgleich korrigiert – zulasten des Anbieters, nicht des
      // Nutzers. Siehe README.
      expiresAt: plan.isSubscription
          ? since.add(
              plan == ProPlan.yearly
                  ? const Duration(days: 366)
                  : const Duration(days: 31),
            )
          : null,
    );
  }

  DateTime _parseTransactionDate(String? raw) {
    if (raw == null) return DateTime.now();

    // Android liefert Millisekunden seit Epoch, iOS je nach Fall einen
    // ISO-Zeitstempel.
    final millis = int.tryParse(raw);
    if (millis != null) {
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }

    return DateTime.tryParse(raw) ?? DateTime.now();
  }

  @override
  Future<void> dispose() async {
    await _subscription.cancel();
    await _events.close();
  }
}
