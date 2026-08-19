import 'package:flutter/material.dart';

/// Die Farben eines Bereichs.
///
/// Jeder Bereich trägt seine Farbe durch die ganze App: Kachel im Hauptmenü,
/// Knopf für den Modus, Rand der richtigen Antwort, Balken in der Statistik.
/// Drei Abstufungen reichen dafür — kräftig für Flächen, zart als Untergrund,
/// dunkel für Schrift auf dem zarten Untergrund.
@immutable
class ModulePalette {
  const ModulePalette({
    required this.accent,
    required this.soft,
    required this.deep,
  });

  /// Volle Fläche: Knopf „Üben", Fortschrittsbalken, Markierung.
  final Color accent;

  /// Zarter Untergrund: Glyphenkachel, ausgewählte Antwort.
  final Color soft;

  /// Schrift und Glyphe auf [soft].
  final Color deep;

  static ModulePalette lerp(ModulePalette a, ModulePalette b, double t) {
    return ModulePalette(
      accent: Color.lerp(a.accent, b.accent, t)!,
      soft: Color.lerp(a.soft, b.soft, t)!,
      deep: Color.lerp(a.deep, b.deep, t)!,
    );
  }
}

/// Rollen, die Material 3 nicht kennt, das Design aber braucht.
///
/// Der Entwurf arbeitet mit warmem Papier, weißen Karten darauf und einer
/// eingelassenen Stufe dazwischen. Material bietet dafür nur `surface` und
/// `surfaceContainer*` — Begriffe, die nicht sagen, wofür sie da sind.
/// Deshalb eigene Namen.
@immutable
class ExamTokens extends ThemeExtension<ExamTokens> {
  const ExamTokens({
    required this.paper,
    required this.raised,
    required this.sunk,
    required this.band,
    required this.ink,
    required this.onInk,
    required this.correct,
    required this.wrong,
    required this.wrongSoft,
    required this.math,
    required this.logic,
    required this.language,
    required this.english,
    required this.concentration,
    required this.personality,
  });

  /// Papiergrund – die Grundfläche der App.
  final Color paper;

  /// Weiße Karte auf dem Papier.
  final Color raised;

  /// Eingelassene Stufe: Balkengrund, ruhiger Knopf, Glyphenkreis.
  final Color sunk;

  /// Etwas kräftiger als [sunk]: das Band mit dem Countdown.
  final Color band;

  /// Tinte: die Testsimulation und die Hauptaktion.
  final Color ink;

  /// Schrift auf der Tinte.
  final Color onInk;

  /// Richtig beantwortet. Ist absichtlich das Grün der Logik: Grün heißt in
  /// dieser App „stimmt", auch wenn gerade Mathematik geübt wird.
  final Color correct;

  final Color wrong;

  /// Untergrund der falsch gewählten Antwort.
  final Color wrongSoft;

  final ModulePalette math;
  final ModulePalette logic;
  final ModulePalette language;
  final ModulePalette english;
  final ModulePalette concentration;
  final ModulePalette personality;

  /// Die Farben des Entwurfs, umgerechnet aus OKLCH.
  ///
  /// Blau, Grün und Orange liegen alle auf L 0,62 / C 0,15 — dadurch wirkt
  /// keine der drei Flächen schwerer als die andere. Grün und Orange liegen
  /// unter Deuteranopie mit ΔE 6,0 dicht beieinander; die App nennt deshalb
  /// überall den Bereichsnamen neben der Farbe und verlässt sich nie auf die
  /// Farbe allein.
  static const ExamTokens light = ExamTokens(
    paper: Color(0xFFFAF7F4),
    raised: Color(0xFFFFFFFF),
    sunk: Color(0xFFF2ECE8),
    band: Color(0xFFECE5E0),
    ink: Color(0xFF1C1B1A),
    onInk: Color(0xFFFFFFFF),
    correct: Color(0xFF0FA05C),
    wrong: Color(0xFFC1453F),
    wrongSoft: Color(0xFFF7EEEA),
    math: ModulePalette(
      accent: Color(0xFF4087DE),
      soft: Color(0xFFDAEDFF),
      deep: Color(0xFF17559B),
    ),
    logic: ModulePalette(
      accent: Color(0xFF0FA05C),
      soft: Color(0xFFD7F4E0),
      deep: Color(0xFF005F2E),
    ),
    language: ModulePalette(
      accent: Color(0xFFCD632D),
      soft: Color(0xFFFFE4D6),
      deep: Color(0xFF8D3700),
    ),
    english: ModulePalette(
      accent: Color(0xFF00A0A2),
      soft: Color(0xFFCDF4F3),
      deep: Color(0xFF00696B),
    ),
    concentration: ModulePalette(
      accent: Color(0xFFA98000),
      soft: Color(0xFFF5EBCE),
      deep: Color(0xFF714F00),
    ),
    personality: ModulePalette(
      accent: Color(0xFF956ED2),
      soft: Color(0xFFEFE6FF),
      deep: Color(0xFF614092),
    ),
  );

  /// Im Dunkeln bleibt das Warme erhalten: die Grundfläche ist die Tinte des
  /// Entwurfs, die Karten sind eine Spur heller. Die Bereichsfarben werden
  /// aufgehellt, sonst versinken sie im Grund.
  static const ExamTokens dark = ExamTokens(
    paper: Color(0xFF1C1B1A),
    raised: Color(0xFF262523),
    sunk: Color(0xFF302E2B),
    band: Color(0xFF35322F),
    ink: Color(0xFFFAF7F4),
    onInk: Color(0xFF1C1B1A),
    correct: Color(0xFF3FC584),
    wrong: Color(0xFFE98A84),
    wrongSoft: Color(0xFF3A2523),
    math: ModulePalette(
      accent: Color(0xFF74AAEE),
      soft: Color(0xFF23303F),
      deep: Color(0xFFBBD8F7),
    ),
    logic: ModulePalette(
      accent: Color(0xFF3FC584),
      soft: Color(0xFF1E332A),
      deep: Color(0xFFAEECC9),
    ),
    language: ModulePalette(
      accent: Color(0xFFF19266),
      soft: Color(0xFF3A1E11),
      deep: Color(0xFFFFC2A3),
    ),
    english: ModulePalette(
      accent: Color(0xFF00C7C7),
      soft: Color(0xFF002E2E),
      deep: Color(0xFF89E7E6),
    ),
    concentration: ModulePalette(
      accent: Color(0xFFCEAA3E),
      soft: Color(0xFF302504),
      deep: Color(0xFFEBD28F),
    ),
    personality: ModulePalette(
      accent: Color(0xFFBB9AF4),
      soft: Color(0xFF2A203B),
      deep: Color(0xFFDDC7FF),
    ),
  );

  /// Die Fläche der Testsimulation.
  ///
  /// Der Ernstfall ist in hell wie dunkel schwarz – der Wechsel ins Dunkel
  /// ist der Vorhang vor der Prüfung. Deshalb feste Werte statt Tokens.
  static const Color examSurface = Color(0xFF1C1B1A);
  static const Color examRaised = Color(0xFF262523);
  static const Color onExam = Color(0xFFFAF7F4);
  static const Color onExamVariant = Color(0xFF9E9892);
  static const Color examOutline = Color(0xFF35322F);

  ModulePalette paletteOf(String moduleId) => switch (moduleId) {
        'logic' => logic,
        'language' => language,
        'english' => english,
        'concentration' => concentration,
        'personality' => personality,
        _ => math,
      };

  @override
  ExamTokens copyWith({
    Color? paper,
    Color? raised,
    Color? sunk,
    Color? band,
    Color? ink,
    Color? onInk,
    Color? correct,
    Color? wrong,
    Color? wrongSoft,
    ModulePalette? math,
    ModulePalette? logic,
    ModulePalette? language,
    ModulePalette? english,
    ModulePalette? concentration,
    ModulePalette? personality,
  }) {
    return ExamTokens(
      paper: paper ?? this.paper,
      raised: raised ?? this.raised,
      sunk: sunk ?? this.sunk,
      band: band ?? this.band,
      ink: ink ?? this.ink,
      onInk: onInk ?? this.onInk,
      correct: correct ?? this.correct,
      wrong: wrong ?? this.wrong,
      wrongSoft: wrongSoft ?? this.wrongSoft,
      math: math ?? this.math,
      logic: logic ?? this.logic,
      language: language ?? this.language,
      english: english ?? this.english,
      concentration: concentration ?? this.concentration,
      personality: personality ?? this.personality,
    );
  }

  @override
  ExamTokens lerp(ThemeExtension<ExamTokens>? other, double t) {
    if (other is! ExamTokens) return this;

    return ExamTokens(
      paper: Color.lerp(paper, other.paper, t)!,
      raised: Color.lerp(raised, other.raised, t)!,
      sunk: Color.lerp(sunk, other.sunk, t)!,
      band: Color.lerp(band, other.band, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      onInk: Color.lerp(onInk, other.onInk, t)!,
      correct: Color.lerp(correct, other.correct, t)!,
      wrong: Color.lerp(wrong, other.wrong, t)!,
      wrongSoft: Color.lerp(wrongSoft, other.wrongSoft, t)!,
      math: ModulePalette.lerp(math, other.math, t),
      logic: ModulePalette.lerp(logic, other.logic, t),
      language: ModulePalette.lerp(language, other.language, t),
      english: ModulePalette.lerp(english, other.english, t),
      concentration:
          ModulePalette.lerp(concentration, other.concentration, t),
      personality: ModulePalette.lerp(personality, other.personality, t),
    );
  }
}

/// Zugriff auf die Tokens ohne `Theme.of(context).extension<…>()!` an jeder
/// Stelle.
extension ExamTokensAccess on BuildContext {
  ExamTokens get tokens =>
      Theme.of(this).extension<ExamTokens>() ?? ExamTokens.light;
}

/// Eckradien. Der Entwurf rundet großzügig: Karten sind Kissen, Knöpfe sind
/// Pillen. Klein wird nur, was Text aufnimmt.
abstract final class Radii {
  /// Eingabefeld.
  static const double input = 16;

  /// Glyphenkachel, kleine Marke.
  static const double tile = 18;

  /// Band mit dem Countdown, Antwortoption.
  static const double band = 24;

  /// Karte im Hauptmenü.
  static const double card = 28;

  /// Knopf – gleich dem Kartenradius, damit ein Knopf in einer Karte wie ihr
  /// Inneres wirkt.
  static const double button = 28;

  /// Pille, Fortschrittsbalken.
  static const double pill = 999;

  static const BorderRadius inputRadius = BorderRadius.all(
    Radius.circular(input),
  );
  static const BorderRadius tileRadius = BorderRadius.all(
    Radius.circular(tile),
  );
  static const BorderRadius bandRadius = BorderRadius.all(
    Radius.circular(band),
  );
  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(button),
  );
}

/// Abstandsraster in Schritten von 4.
abstract final class Gap {
  /// Glyphe zu Wort.
  static const double xs = 4;

  /// Zeile zu Zeile.
  static const double sm = 8;

  /// Karten im Stapel.
  static const double md = 12;

  /// Karteninnenrand, Seitenrand des Screens.
  static const double card = 16;

  /// Innenrand einer großen Karte.
  static const double cardWide = 20;

  /// Abschnitt zu Abschnitt.
  static const double section = 24;

  /// Vor einer Überschrift.
  static const double header = 32;

  /// Höhe eines Knopfes und einer Modus-Zeile.
  static const double control = 56;

  /// Ab dieser Breite fällt der Seitenrand auf 12.
  static const double narrowWidth = 360;

  static double screenPadding(double width) => width < narrowWidth ? 12 : card;
}
