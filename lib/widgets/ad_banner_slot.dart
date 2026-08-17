import 'package:einstellungstest_trainer/services/ads/ad_config.dart';
import 'package:einstellungstest_trainer/services/ads/ad_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Banner am unteren Rand – nur in der kostenlosen Version.
///
/// Der Platz wird erst belegt, wenn tatsächlich eine Anzeige geladen ist.
/// Ein reservierter Leerraum „für den Fall der Fälle" würde die Aufgabe nach
/// oben drücken, ohne dass etwas dafür zu sehen wäre.
///
/// Bewusst **nicht** eingebunden im Sprint und in der Testsimulation: Dort
/// zählt jede Sekunde, und eine Anzeige neben einer laufenden Uhr wäre
/// gegenüber dem Nutzer unfair.
class AdBannerSlot extends ConsumerStatefulWidget {
  const AdBannerSlot({super.key});

  @override
  ConsumerState<AdBannerSlot> createState() => _AdBannerSlotState();
}

class _AdBannerSlotState extends ConsumerState<AdBannerSlot> {
  BannerAd? _banner;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadIfAllowed();
  }

  void _loadIfAllowed() {
    if (_banner != null || !ref.read(adsAllowedProvider)) return;
    if (!AdConfig.isSupportedPlatform) return;

    final banner = BannerAd(
      size: AdSize.banner,
      adUnitId: AdConfig.bannerUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          // Kein Fehlerhinweis: Ohne Anzeige ist die App vollständig
          // benutzbar, eine Meldung wäre nur Lärm.
          ad.dispose();
          if (mounted) {
            setState(() {
              _banner = null;
              _loaded = false;
            });
          }
        },
      ),
    );

    _banner = banner;
    banner.load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Nach einem Kauf verschwindet der Banner sofort.
    final allowed = ref.watch(adsAllowedProvider);
    if (!allowed) {
      _banner?.dispose();
      _banner = null;
      _loaded = false;
      return const SizedBox.shrink();
    }

    final banner = _banner;
    if (banner == null || !_loaded) return const SizedBox.shrink();

    return SafeArea(
      top: false,
      child: SizedBox(
        width: banner.size.width.toDouble(),
        height: banner.size.height.toDouble(),
        child: AdWidget(ad: banner),
      ),
    );
  }
}
