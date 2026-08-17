/// Ob und wie Anzeigen ausgeliefert werden dürfen.
enum AdConsentStatus {
  /// Noch nicht gefragt oder Antwort steht aus.
  unknown,

  /// Der Nutzer hat personalisierte oder nicht-personalisierte Anzeigen
  /// zugelassen.
  granted,

  /// Abgelehnt – es werden keine Anzeigen angefordert.
  denied,

  /// Außerhalb des Geltungsbereichs (kein Einwilligungsdialog nötig).
  notRequired,
}

/// Anzeigen.
///
/// Wie bei Auth und Sync hängt die Oberfläche nur an dieser Schnittstelle:
/// Tests laufen ohne Platform-Channels, und ohne AdMob-Konfiguration bleibt
/// die App vollständig nutzbar – nur eben ohne Werbung.
abstract class AdService {
  bool get isAvailable;

  /// Ob nach Einwilligungslage Anzeigen angefordert werden dürfen.
  bool get canRequestAds;

  /// Startet das SDK und holt bei Bedarf die Einwilligung ein.
  Future<AdConsentStatus> initialize();

  /// Öffnet den Einwilligungsdialog erneut – gehört in die Einstellungen,
  /// weil eine Einwilligung jederzeit widerrufbar sein muss.
  Future<AdConsentStatus> showPrivacyOptions();

  /// Lädt eine Unterbrecher-Anzeige vor, damit sie später ohne Wartezeit
  /// erscheint. Ein Ladefehler ist kein Grund für eine Fehlermeldung.
  Future<void> preloadInterstitial();

  /// Zeigt die vorgeladene Unterbrechung. Gibt zurück, ob tatsächlich eine
  /// gezeigt wurde.
  Future<bool> showInterstitial();
}

/// Keine Anzeigen – Voreinstellung in Tests und ohne AdMob-Konfiguration.
class UnavailableAdService implements AdService {
  const UnavailableAdService();

  @override
  bool get isAvailable => false;

  @override
  bool get canRequestAds => false;

  @override
  Future<AdConsentStatus> initialize() async => AdConsentStatus.notRequired;

  @override
  Future<AdConsentStatus> showPrivacyOptions() async =>
      AdConsentStatus.notRequired;

  @override
  Future<void> preloadInterstitial() async {}

  @override
  Future<bool> showInterstitial() async => false;
}

/// Anzeigen-Attrappe für Tests.
class InMemoryAdService implements AdService {
  InMemoryAdService({this.consent = AdConsentStatus.granted});

  AdConsentStatus consent;

  int interstitialsShown = 0;
  int preloads = 0;
  int privacyOptionsOpened = 0;
  bool initialized = false;

  @override
  bool get isAvailable => true;

  @override
  bool get canRequestAds =>
      consent == AdConsentStatus.granted ||
      consent == AdConsentStatus.notRequired;

  @override
  Future<AdConsentStatus> initialize() async {
    initialized = true;
    return consent;
  }

  @override
  Future<AdConsentStatus> showPrivacyOptions() async {
    privacyOptionsOpened++;
    return consent;
  }

  @override
  Future<void> preloadInterstitial() async => preloads++;

  @override
  Future<bool> showInterstitial() async {
    if (!canRequestAds) return false;

    interstitialsShown++;
    return true;
  }
}
