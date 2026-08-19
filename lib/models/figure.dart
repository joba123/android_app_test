/// Formen, die die App zeichnet, statt sie als Bild mitzuliefern.
///
/// Figurenaufgaben ohne Bilder sind sprachlich nur behelfsmäßig zu
/// beschreiben („ein Quadrat, darin drei Punkte …"). Gezeichnete Figuren
/// lösen das ohne Asset-Pflege: Die Aufgabe trägt eine Beschreibung, das
/// Zeichnen übernimmt ein Painter. Nebenbei bleibt die App klein und die
/// Figuren skalieren auf jedem Display sauber.
enum FigureShape {
  circle('Kreis'),
  square('Quadrat'),
  triangle('Dreieck'),
  diamond('Raute'),
  pentagon('Fünfeck'),
  star('Stern');

  const FigureShape(this.label);

  final String label;

  /// Plural für die Erklärtexte.
  String get plural => switch (this) {
        FigureShape.circle => 'Kreise',
        FigureShape.square => 'Quadrate',
        FigureShape.triangle => 'Dreiecke',
        FigureShape.diamond => 'Rauten',
        FigureShape.pentagon => 'Fünfecke',
        FigureShape.star => 'Sterne',
      };
}

/// Eine gezeichnete Zelle: gleiche Form, ein- bis fünfmal wiederholt.
class FigureCell {
  const FigureCell({
    required this.shape,
    this.count = 1,
    this.filled = false,
    this.quarterTurns = 0,
  })  : assert(count >= 1 && count <= 6, 'Eine Zelle fasst ein bis sechs Formen'),
        assert(quarterTurns >= 0 && quarterTurns < 4, 'Nur 0 bis 3 Vierteldrehungen');

  final FigureShape shape;

  /// Wie viele Formen in der Zelle liegen.
  final int count;

  /// Ausgefüllt oder nur Kontur.
  final bool filled;

  /// Drehung in Vierteln – nur bei Formen sichtbar, die nicht rund sind.
  final int quarterTurns;

  /// Beschreibung für Vorlesehilfen und Erklärtexte.
  String describe() {
    final form = count == 1 ? shape.label : '$count ${shape.plural}';
    final fill = filled ? 'ausgefüllt' : 'nicht ausgefüllt';
    if (shape == FigureShape.circle || quarterTurns == 0) {
      return '$form, $fill';
    }
    return '$form, $fill, um ${quarterTurns * 90} Grad gedreht';
  }

  FigureCell copyWith({
    FigureShape? shape,
    int? count,
    bool? filled,
    int? quarterTurns,
  }) {
    return FigureCell(
      shape: shape ?? this.shape,
      count: count ?? this.count,
      filled: filled ?? this.filled,
      quarterTurns: quarterTurns ?? this.quarterTurns,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FigureCell &&
      other.shape == shape &&
      other.count == count &&
      other.filled == filled &&
      other.quarterTurns == quarterTurns;

  @override
  int get hashCode => Object.hash(shape, count, filled, quarterTurns);
}
