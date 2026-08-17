import 'dart:io';

import 'package:flutter/foundation.dart';

/// Anzeigenblöcke von AdMob.
///
/// Voreingestellt sind **Googles offizielle Test-Kennungen**. Sie liefern
/// echte Test-Anzeigen und sind der einzige zulässige Weg, ohne fremde
/// Anzeigen zu vergüten – auf eigenen Blöcken zu testen führt zur Sperrung
/// des AdMob-Kontos.
///
/// Für ein Release werden die echten Kennungen über `--dart-define` gesetzt:
///
/// ```bash
/// flutter build apk --release \
///   --dart-define=ADMOB_BANNER_ANDROID=ca-app-pub-…/… \
///   --dart-define=ADMOB_INTERSTITIAL_ANDROID=ca-app-pub-…/…
/// ```
///
/// Die App-ID selbst steht im Android-Manifest und muss dort ersetzt werden.
class AdConfig {
  const AdConfig._();

  static const String _testBannerAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIos =
      'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIos =
      'ca-app-pub-3940256099942544/4411468910';

  static const String _bannerAndroid =
      String.fromEnvironment('ADMOB_BANNER_ANDROID');
  static const String _bannerIos = String.fromEnvironment('ADMOB_BANNER_IOS');
  static const String _interstitialAndroid =
      String.fromEnvironment('ADMOB_INTERSTITIAL_ANDROID');
  static const String _interstitialIos =
      String.fromEnvironment('ADMOB_INTERSTITIAL_IOS');

  /// Ob echte Anzeigenblöcke hinterlegt sind. Steht im Kauf-Screen nicht,
  /// wohl aber in den Einstellungen als Hinweis für Testbuilds.
  static bool get usesTestUnits => _bannerAndroid.isEmpty;

  static String get bannerUnitId {
    if (Platform.isIOS) {
      return _bannerIos.isEmpty ? _testBannerIos : _bannerIos;
    }
    return _bannerAndroid.isEmpty ? _testBannerAndroid : _bannerAndroid;
  }

  static String get interstitialUnitId {
    if (Platform.isIOS) {
      return _interstitialIos.isEmpty ? _testInterstitialIos : _interstitialIos;
    }
    return _interstitialAndroid.isEmpty
        ? _testInterstitialAndroid
        : _interstitialAndroid;
  }

  /// Anzeigen laufen nur auf Android und iOS.
  static bool get isSupportedPlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);
}
