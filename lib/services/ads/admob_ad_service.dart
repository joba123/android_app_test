import 'dart:async';

import 'package:einstellungstest_trainer/services/ads/ad_config.dart';
import 'package:einstellungstest_trainer/services/ads/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Anzeigen über Google AdMob, mit Einwilligung über die User Messaging
/// Platform (UMP).
///
/// Die Einwilligung ist keine Kür: Ohne sie dürfen im EWR keine Anzeigen
/// ausgeliefert werden. Deshalb wird [canRequestAds] von UMP beantwortet und
/// nicht von der App geraten.
class AdMobAdService implements AdService {
  AdMobAdService();

  bool _initialized = false;
  bool _canRequestAds = false;
  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;

  @override
  bool get isAvailable => AdConfig.isSupportedPlatform;

  @override
  bool get canRequestAds => _canRequestAds;

  @override
  Future<AdConsentStatus> initialize() async {
    if (!isAvailable) return AdConsentStatus.notRequired;

    try {
      await _gatherConsent();
      if (!_initialized) {
        await MobileAds.instance.initialize();
        _initialized = true;
      }
      return _describeStatus(await ConsentInformation.instance
          .getConsentStatus());
    } catch (_) {
      // Anzeigen sind nichts, wofür die App scheitern darf.
      _canRequestAds = false;
      return AdConsentStatus.unknown;
    }
  }

  /// Holt den Einwilligungsstatus und zeigt bei Bedarf das Formular.
  Future<void> _gatherConsent() async {
    final completer = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        try {
          await ConsentForm.loadAndShowConsentFormIfRequired((error) {});
        } finally {
          if (!completer.isCompleted) completer.complete();
        }
      },
      (error) {
        if (!completer.isCompleted) completer.complete();
      },
    );

    await completer.future;
    _canRequestAds = await ConsentInformation.instance.canRequestAds();
  }

  @override
  Future<AdConsentStatus> showPrivacyOptions() async {
    if (!isAvailable) return AdConsentStatus.notRequired;

    try {
      await ConsentForm.showPrivacyOptionsForm((error) {});
      _canRequestAds = await ConsentInformation.instance.canRequestAds();

      return _describeStatus(
        await ConsentInformation.instance.getConsentStatus(),
      );
    } catch (_) {
      return AdConsentStatus.unknown;
    }
  }

  AdConsentStatus _describeStatus(ConsentStatus status) {
    return switch (status) {
      ConsentStatus.obtained => AdConsentStatus.granted,
      ConsentStatus.notRequired => AdConsentStatus.notRequired,
      ConsentStatus.required => AdConsentStatus.denied,
      ConsentStatus.unknown => AdConsentStatus.unknown,
    };
  }

  @override
  Future<void> preloadInterstitial() async {
    if (!_canRequestAds || _interstitial != null || _loadingInterstitial) {
      return;
    }

    _loadingInterstitial = true;
    await InterstitialAd.load(
      adUnitId: AdConfig.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _loadingInterstitial = false;
        },
        onAdFailedToLoad: (error) {
          // Kein Grund für eine Meldung: Dann gibt es eben keine Anzeige.
          _interstitial = null;
          _loadingInterstitial = false;
        },
      ),
    );
  }

  @override
  Future<bool> showInterstitial() async {
    final ad = _interstitial;
    if (ad == null || !_canRequestAds) {
      // Für das nächste Mal vorbereiten.
      unawaited(preloadInterstitial());
      return false;
    }

    _interstitial = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        unawaited(preloadInterstitial());
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        unawaited(preloadInterstitial());
      },
    );

    await ad.show();
    return true;
  }
}
