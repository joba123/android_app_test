/// Zählerstand für die Taktung der Unterbrecher-Werbung.
class AdFrequencyState {
  const AdFrequencyState({
    this.completedSprints = 0,
    this.sprintsSinceLastAd = 0,
    this.lastShownAt,
  });

  /// Wie viele Sprint-Runden insgesamt abgeschlossen wurden.
  final int completedSprints;

  /// Wie viele davon seit der letzten Unterbrechung.
  final int sprintsSinceLastAd;

  final DateTime? lastShownAt;

  AdFrequencyState afterSprint() => AdFrequencyState(
        completedSprints: completedSprints + 1,
        sprintsSinceLastAd: sprintsSinceLastAd + 1,
        lastShownAt: lastShownAt,
      );

  AdFrequencyState afterAd(DateTime now) => AdFrequencyState(
        completedSprints: completedSprints,
        sprintsSinceLastAd: 0,
        lastShownAt: now,
      );

  Map<String, dynamic> toJson() => {
        'completedSprints': completedSprints,
        'sprintsSinceLastAd': sprintsSinceLastAd,
        'lastShownAt': lastShownAt?.toUtc().toIso8601String(),
      };

  factory AdFrequencyState.fromJson(Map<String, dynamic> json) {
    final completed = json['completedSprints'];
    final since = json['sprintsSinceLastAd'];

    return AdFrequencyState(
      completedSprints: completed is int && completed >= 0 ? completed : 0,
      sprintsSinceLastAd: since is int && since >= 0 ? since : 0,
      lastShownAt:
          DateTime.tryParse(json['lastShownAt'] as String? ?? '')?.toLocal(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AdFrequencyState &&
      other.completedSprints == completedSprints &&
      other.sprintsSinceLastAd == sprintsSinceLastAd &&
      other.lastShownAt == lastShownAt;

  @override
  int get hashCode =>
      Object.hash(completedSprints, sprintsSinceLastAd, lastShownAt);
}

/// Entscheidet, ob nach einer Sprint-Runde eine Unterbrechung gezeigt wird.
///
/// Bewusst zurückhaltend – eine Lern-App, die nach jeder Minute Werbung
/// einblendet, wird deinstalliert. Drei Regeln, alle drei müssen erfüllt sein.
class InterstitialPolicy {
  const InterstitialPolicy._();

  /// Die allererste Runde bleibt frei. Der erste Eindruck einer Lern-App
  /// soll nicht eine Anzeige sein.
  static const int freeSprintsAtStart = 1;

  /// Danach höchstens jede dritte Runde.
  static const int sprintsBetweenAds = 3;

  /// Und nie zweimal kurz hintereinander, egal wie schnell geübt wird.
  static const Duration minimumGap = Duration(minutes: 5);

  static bool shouldShow({
    required AdFrequencyState state,
    required DateTime now,
  }) {
    if (state.completedSprints <= freeSprintsAtStart) return false;
    if (state.sprintsSinceLastAd < sprintsBetweenAds) return false;

    final last = state.lastShownAt;
    if (last != null && now.difference(last) < minimumGap) return false;

    return true;
  }
}
