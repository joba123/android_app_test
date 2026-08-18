import 'package:flutter/material.dart';

/// Rollen, die Material 3 nicht kennt, das Design aber braucht.
///
/// Material bietet `surface`, `surfaceContainer*` und `outline` – aber keine
/// Begriffe für „Papier", „erhabene Datenkarte" und „eingelassene Rille". Der
/// Entwurf unterscheidet diese drei bewusst, weil die Rangfolge über Fläche
/// entsteht und nicht über Rahmen. Deshalb eine eigene Erweiterung statt einer
/// erzwungenen Zuordnung auf Material-Rollen.
@immutable
class ExamTokens extends ThemeExtension<ExamTokens> {
  const ExamTokens({
    required this.paper,
    required this.raised,
    required this.sunk,
    required this.ink,
    required this.onInk,
    required this.interactive,
    required this.correct,
    required this.wrong,
    required this.math,
    required this.logic,
    required this.language,
  });

  /// Papiergrund – die Grundfläche der App.
  final Color paper;

  /// Erhabene Datenkarte.
  final Color raised;

  /// Eingelassene Fläche: Rille, Balkengrund.
  final Color sunk;

  /// Tinte: dunkle Kopfflächen und die Hauptaktion.
  final Color ink;

  /// Schrift auf der Tinte.
  final Color onInk;

  /// Links und Fokus. Bewusst getrennt von [math], obwohl im Hellmodus
  /// dieselbe Farbe: Wenn Mathematik einmal eine andere Farbe bekommt, soll
  /// sich der Link nicht mitverschieben.
  final Color interactive;

  final Color correct;
  final Color wrong;

  final Color math;
  final Color logic;
  final Color language;

  static const ExamTokens light = ExamTokens(
    paper: Color(0xFFF7F5F1),
    raised: Color(0xFFFFFFFF),
    sunk: Color(0xFFEFEBE4),
    ink: Color(0xFF16233A),
    onInk: Color(0xFFF7F5F1),
    interactive: Color(0xFF2F6FED),
    correct: Color(0xFF146B45),
    wrong: Color(0xFFA61B1B),
    math: Color(0xFF2F6FED),
    logic: Color(0xFFC2410C),
    language: Color(0xFF0E9F6E),
  );

  static const ExamTokens dark = ExamTokens(
    paper: Color(0xFF0E1116),
    raised: Color(0xFF171B22),
    sunk: Color(0xFF1F242C),
    ink: Color(0xFFE7EAEF),
    onInk: Color(0xFF0E1116),
    interactive: Color(0xFF6C9BFF),
    correct: Color(0xFF2FA875),
    wrong: Color(0xFFF1705F),
    math: Color(0xFF6C9BFF),
    logic: Color(0xFFF08B4C),
    language: Color(0xFF37C79A),
  );

  /// Die Fläche, auf der die Testsimulation läuft.
  ///
  /// Der Ernstfall ist **in hell wie dunkel** schwarz – der Wechsel ins
  /// Dunkel ist der Vorhang vor der Prüfung. Deshalb eine feste Farbe und
  /// keine, die vom Modus abhängt.
  static const Color examSurface = Color(0xFF0E1116);
  static const Color examRaised = Color(0xFF171B22);
  static const Color onExam = Color(0xFFEDEFF2);
  static const Color onExamVariant = Color(0xFFA7B0BC);
  static const Color examOutline = Color(0xFF2C333D);

  /// Warme Papierfläche des Sprints. Hektik entsteht über Größe und
  /// Bewegung, nicht über eine rote Warnfarbe.
  static const Color sprintPaper = Color(0xFFFDF6F0);

  @override
  ExamTokens copyWith({
    Color? paper,
    Color? raised,
    Color? sunk,
    Color? ink,
    Color? onInk,
    Color? interactive,
    Color? correct,
    Color? wrong,
    Color? math,
    Color? logic,
    Color? language,
  }) {
    return ExamTokens(
      paper: paper ?? this.paper,
      raised: raised ?? this.raised,
      sunk: sunk ?? this.sunk,
      ink: ink ?? this.ink,
      onInk: onInk ?? this.onInk,
      interactive: interactive ?? this.interactive,
      correct: correct ?? this.correct,
      wrong: wrong ?? this.wrong,
      math: math ?? this.math,
      logic: logic ?? this.logic,
      language: language ?? this.language,
    );
  }

  @override
  ExamTokens lerp(ThemeExtension<ExamTokens>? other, double t) {
    if (other is! ExamTokens) return this;

    return ExamTokens(
      paper: Color.lerp(paper, other.paper, t)!,
      raised: Color.lerp(raised, other.raised, t)!,
      sunk: Color.lerp(sunk, other.sunk, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      onInk: Color.lerp(onInk, other.onInk, t)!,
      interactive: Color.lerp(interactive, other.interactive, t)!,
      correct: Color.lerp(correct, other.correct, t)!,
      wrong: Color.lerp(wrong, other.wrong, t)!,
      math: Color.lerp(math, other.math, t)!,
      logic: Color.lerp(logic, other.logic, t)!,
      language: Color.lerp(language, other.language, t)!,
    );
  }
}

/// Zugriff auf die Tokens ohne `Theme.of(context).extension<…>()!` an jeder
/// Stelle.
extension ExamTokensAccess on BuildContext {
  ExamTokens get tokens =>
      Theme.of(this).extension<ExamTokens>() ?? ExamTokens.light;
}

/// Eckradien. Vier statt einem: Ein kleiner Radius heißt „hier wird
/// eingegeben", ein großer „hier wird gestartet". Das ersetzt die
/// gleichförmigen Material-Karten als Rangordnung.
abstract final class Radii {
  /// Eingabefeld, Antwortoption.
  static const double input = 4;

  /// Datenkarte.
  static const double card = 10;

  /// Kopffläche, Hauptknopf.
  static const double surface = 20;

  /// Chip, Pille.
  static const double pill = 999;

  static const BorderRadius inputRadius = BorderRadius.all(
    Radius.circular(input),
  );
  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius surfaceRadius = BorderRadius.all(
    Radius.circular(surface),
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

  /// Karteninnenrand.
  static const double card = 16;

  /// Seitenrand des Screens.
  static const double screen = 20;

  /// Abschnitt zu Abschnitt.
  static const double section = 24;

  /// Vor dem Ende einer Kopffläche.
  static const double header = 32;

  /// Ab dieser Breite fällt der Seitenrand auf 16 und zweispaltige
  /// Kennzahlen brechen auf eine Spalte um.
  static const double narrowWidth = 360;

  static double screenPadding(double width) =>
      width < narrowWidth ? 16 : screen;
}
