/// Die angebotenen Tarife.
///
/// Die Produkt-Kennungen müssen genauso in der Google Play Console angelegt
/// sein – siehe README.
enum ProPlan {
  lifetime(
    productId: 'pro_lifetime',
    label: 'Einmalkauf',
    description: 'Einmal zahlen, dauerhaft behalten. Kein Abo, keine '
        'Verlängerung.',
    isSubscription: false,
  ),
  monthly(
    productId: 'pro_monthly',
    label: 'Monatlich',
    description: 'Monatlich kündbar – sinnvoll, wenn dein Test bald ansteht.',
    isSubscription: true,
  ),
  yearly(
    productId: 'pro_yearly',
    label: 'Jährlich',
    description: 'Günstiger pro Monat als das Monatsabo.',
    isSubscription: true,
  );

  const ProPlan({
    required this.productId,
    required this.label,
    required this.description,
    required this.isSubscription,
  });

  final String productId;
  final String label;
  final String description;
  final bool isSubscription;

  static ProPlan? tryFromProductId(String id) {
    for (final plan in values) {
      if (plan.productId == id) return plan;
    }
    return null;
  }

  /// Alle Produkt-Kennungen – für die Abfrage beim Store.
  static Set<String> get productIds =>
      {for (final plan in values) plan.productId};
}

/// Ein Angebot, wie es der Store zurückliefert.
///
/// Der Preis kommt als fertig formatierter Text vom Store und wird nie selbst
/// zusammengebaut: Währung, Format und Steuern hängen vom Land ab.
class ProOffer {
  const ProOffer({
    required this.plan,
    required this.price,
    this.rawPrice,
    this.currency,
  });

  final ProPlan plan;
  final String price;
  final double? rawPrice;
  final String? currency;

  /// Preis pro Monat, sofern berechenbar – nur zur Einordnung beim
  /// Jahresabo, nie als Abrechnungsgrundlage.
  String? get pricePerMonth {
    if (plan != ProPlan.yearly || rawPrice == null || currency == null) {
      return null;
    }

    final monthly = rawPrice! / 12;
    return '${monthly.toStringAsFixed(2).replaceAll('.', ',')} $currency';
  }
}

/// Die erworbene Berechtigung.
///
/// [expiresAt] ist nur bei Abos gesetzt. Bei einem Einmalkauf gibt es kein
/// Ablaufdatum – deshalb ein eigenes Feld statt eines Ablaufs „in ferner
/// Zukunft", der irgendwann doch eintritt.
class ProEntitlement {
  const ProEntitlement({
    required this.plan,
    required this.since,
    this.expiresAt,
  });

  final ProPlan plan;
  final DateTime since;
  final DateTime? expiresAt;

  /// Ob die Berechtigung gilt.
  ///
  /// Läuft ein Abo ab, ohne dass die App davon erfährt (kein Netz, keine
  /// Store-Antwort), gilt es weiter. Das ist Absicht: Im Zweifel zugunsten
  /// des Nutzers, der bezahlt hat. Der Store korrigiert das beim nächsten
  /// erfolgreichen Abgleich.
  bool isActive(DateTime now) {
    final expiry = expiresAt;
    return expiry == null || expiry.isAfter(now);
  }

  Map<String, dynamic> toJson() => {
        'plan': plan.productId,
        'since': since.toUtc().toIso8601String(),
        'expiresAt': expiresAt?.toUtc().toIso8601String(),
      };

  static ProEntitlement? fromJson(Map<String, dynamic> json) {
    final plan = ProPlan.tryFromProductId(json['plan'] as String? ?? '');
    final since = DateTime.tryParse(json['since'] as String? ?? '');
    if (plan == null || since == null) return null;

    return ProEntitlement(
      plan: plan,
      since: since.toLocal(),
      expiresAt:
          DateTime.tryParse(json['expiresAt'] as String? ?? '')?.toLocal(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ProEntitlement &&
      other.plan == plan &&
      other.since == since &&
      other.expiresAt == expiresAt;

  @override
  int get hashCode => Object.hash(plan, since, expiresAt);
}

/// Was Pro freischaltet – an einer Stelle, damit Kauf-Screen und Sperren
/// nicht auseinanderlaufen können.
class ProBenefits {
  const ProBenefits._();

  static const List<String> all = [
    'Keine Werbung – weder Banner noch Unterbrechungen',
    'Zusätzliche Aufgaben in Logik und Sprache',
    'Schwierigkeitsgrad gezielt wählbar – auch nur schwere Aufgaben',
    'Längerer Sitzungsverlauf für die Auswertung über Wochen',
  ];

  /// Nichts, was in der kostenlosen Version heute funktioniert, wird durch
  /// Pro weggenommen. Diese Zusage steht auch im Kauf-Screen.
  static const String promise =
      'Alle drei Module, alle Rundenlängen und alle Testsimulationen bleiben '
      'kostenlos. Pro kommt obendrauf.';

  /// Verlaufslänge. Free bleibt bei dem, was bisher galt.
  static const int freeHistoryLimit = 50;
  static const int proHistoryLimit = 200;
}
