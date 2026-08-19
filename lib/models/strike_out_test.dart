import 'dart:math';

/// Ein Zeichen im Durchstreichtest.
///
/// Der d2-Test und seine Verwandten arbeiten mit Zeichen, die sich nur in
/// einem Detail unterscheiden: derselbe Buchstabe, aber ein Strich mehr oder
/// weniger. Genau das bildet [marks] ab – gesucht ist ein „d" mit zwei
/// Strichen, danebenstehen „d" mit einem oder drei Strichen und „p" mit
/// zweien.
class StrikeSymbol {
  const StrikeSymbol({required this.letter, required this.marks});

  final String letter;

  /// Anzahl der Striche über und unter dem Buchstaben, zusammen 1 bis 4.
  final int marks;

  bool get isTarget => letter == 'd' && marks == 2;

  @override
  bool operator ==(Object other) =>
      other is StrikeSymbol && other.letter == letter && other.marks == marks;

  @override
  int get hashCode => Object.hash(letter, marks);
}

/// Eine Zeile des Tests.
class StrikeRow {
  const StrikeRow({required this.symbols});

  final List<StrikeSymbol> symbols;

  int get targetCount => symbols.where((symbol) => symbol.isTarget).length;
}

/// Das Ergebnis eines Durchlaufs.
///
/// Die drei Zahlen sind die des d2: bearbeitete Zeichen als Maß für das
/// Tempo, Fehler durch falsches Antippen (Verwechslung) und Auslassungen
/// durch übersehene Ziele. Wer schnell und schlampig arbeitet, sieht das an
/// den Auslassungen; wer langsam und genau ist, an der Menge.
class StrikeResult {
  const StrikeResult({
    required this.processed,
    required this.hits,
    required this.wrongTaps,
    required this.missed,
    required this.duration,
  });

  /// Zeichen, die der Nutzer erreicht hat – alles bis zum letzten bearbeiteten
  /// Zeichen der letzten begonnenen Zeile.
  final int processed;

  /// Richtig angetippte Ziele.
  final int hits;

  /// Angetippte Zeichen, die keine Ziele waren.
  final int wrongTaps;

  /// Ziele, die im bearbeiteten Bereich übersehen wurden.
  final int missed;

  final Duration duration;

  int get errors => wrongTaps + missed;

  /// Konzentrationsleistung: bearbeitete Zeichen abzüglich aller Fehler.
  /// Diese Kennzahl entspricht dem KL-Wert des d2 und ist die
  /// aussagekräftigste Einzelzahl des Tests.
  int get score => processed - errors;

  /// Fehleranteil an den bearbeiteten Zeichen.
  double get errorRate => processed == 0 ? 0 : errors / processed;

  /// Zeichen pro Minute.
  double get pace {
    final seconds = duration.inMilliseconds / 1000;
    return seconds <= 0 ? 0 : processed / seconds * 60;
  }

  /// Kurze Einordnung – bewusst ohne Note und ohne Vergleich mit anderen.
  String get verdict {
    if (processed < 40) return 'Zu wenig bearbeitet für eine Aussage.';
    if (errorRate <= 0.03) return 'Sehr sorgfältig gearbeitet.';
    if (errorRate <= 0.08) return 'Solide – die Fehlerquote ist im Rahmen.';
    return 'Zu hastig: Die Fehler kosten mehr, als das Tempo einbringt.';
  }
}

/// Baut die Zeichenfläche eines Durchlaufs.
///
/// Rückwärts konstruiert wie die übrigen Generatoren: Erst steht fest, wie
/// viele Ziele eine Zeile enthält, dann wird der Rest aufgefüllt. Dadurch ist
/// die Zahl der Ziele immer exakt bekannt – ohne sie ließen sich Fehler und
/// Auslassungen nicht auseinanderhalten.
class StrikeOutBuilder {
  const StrikeOutBuilder();

  /// Anteil der Ziele an allen Zeichen. Der d2 liegt bei rund 45 Prozent;
  /// etwas darunter hält die Zeile lesbar.
  static const double targetShare = 0.4;

  static const List<String> _letters = ['d', 'p'];

  List<StrikeRow> build({
    required int rows,
    required int perRow,
    required Random random,
  }) {
    return [
      for (var row = 0; row < rows; row++) _buildRow(perRow, random),
    ];
  }

  StrikeRow _buildRow(int perRow, Random random) {
    final targets = (perRow * targetShare).round();
    final symbols = <StrikeSymbol>[
      for (var index = 0; index < targets; index++)
        const StrikeSymbol(letter: 'd', marks: 2),
      for (var index = targets; index < perRow; index++)
        _distractor(random),
    ]..shuffle(random);

    return StrikeRow(symbols: symbols);
  }

  /// Ein Zeichen, das dem Ziel ähnelt, aber keines ist: entweder der falsche
  /// Buchstabe oder die falsche Zahl an Strichen.
  StrikeSymbol _distractor(Random random) {
    final letter = _letters[random.nextInt(_letters.length)];
    if (letter == 'p') {
      return StrikeSymbol(letter: 'p', marks: 1 + random.nextInt(4));
    }
    // Ein "d" darf hier alles sein, nur nicht genau zwei Striche haben.
    final marks = [1, 3, 4][random.nextInt(3)];
    return StrikeSymbol(letter: 'd', marks: marks);
  }
}
