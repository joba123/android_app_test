import 'dart:async';

import 'package:einstellungstest_trainer/models/ad_frequency.dart';
import 'package:einstellungstest_trainer/services/ads/ad_service.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/services/purchase/entitlement_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wird in `main()` mit [AdMobAdService] überschrieben.
final adServiceProvider = Provider<AdService>((ref) {
  return const UnavailableAdService();
});

/// Ob überhaupt Anzeigen gezeigt werden dürfen.
///
/// Drei Bedingungen: Pro ist nicht aktiv, die Plattform kann Anzeigen, und
/// die Einwilligung liegt vor. Der Rest der App fragt nur diesen Provider.
final adsAllowedProvider = Provider<bool>((ref) {
  if (ref.watch(isProProvider)) return false;

  final service = ref.watch(adServiceProvider);
  return service.isAvailable && service.canRequestAds;
});

/// Verwaltet die Taktung der Unterbrecher-Werbung.
class AdController extends Notifier<AdFrequencyState> {
  @override
  AdFrequencyState build() {
    return ref.watch(storageServiceProvider).loadAdFrequency();
  }

  /// Wird nach jeder abgeschlossenen Sprint-Runde aufgerufen und entscheidet,
  /// ob unterbrochen wird.
  ///
  /// Gibt zurück, ob eine Anzeige gezeigt wurde – die Oberfläche wartet
  /// darauf, bevor sie zur Auswertung wechselt.
  Future<bool> onSprintFinished() async {
    var next = state.afterSprint();
    final now = DateTime.now();

    if (!ref.read(adsAllowedProvider) ||
        !InterstitialPolicy.shouldShow(state: next, now: now)) {
      await _persist(next);
      return false;
    }

    final shown = await ref.read(adServiceProvider).showInterstitial();
    if (shown) next = next.afterAd(now);

    await _persist(next);
    return shown;
  }

  /// Lädt die nächste Anzeige vor, solange der Nutzer noch übt.
  void preload() {
    if (!ref.read(adsAllowedProvider)) return;
    unawaited(ref.read(adServiceProvider).preloadInterstitial());
  }

  Future<void> _persist(AdFrequencyState next) async {
    state = next;
    await ref.read(storageServiceProvider).saveAdFrequency(next);
  }
}

final adControllerProvider =
    NotifierProvider<AdController, AdFrequencyState>(AdController.new);
