import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';

/// Zustand einer Antwortoption in der Darstellung.
enum AnswerOptionState {
  /// Noch nicht beantwortet.
  idle,

  /// Angetippt, Loesung noch nicht aufgedeckt (Sprint / Simulation).
  selected,

  /// Aufgedeckt und richtig.
  correct,

  /// Aufgedeckt, vom Nutzer gewaehlt und falsch.
  wrong,

  /// Aufgedeckt, nicht gewaehlt und falsch - visuell zurueckgenommen.
  dimmed,
}

/// Eine anklickbare Antwortmöglichkeit.
///
/// Der Zustand ist dreifach unterschieden: über die Fläche, über den
/// Buchstabenmarker und über eine Glyphe am Ende. Farbe allein trägt hier
/// nie eine Bedeutung – im Sonnenlicht und bei Farbfehlsichtigkeit bliebe
/// sonst nichts übrig.
///
/// Die Glyphen sind Material-Icons und keine Textzeichen: ✓ und ✕ fehlen in
/// den gebündelten Schriftschnitten.
class AnswerOptionTile extends StatelessWidget {
  const AnswerOptionTile({
    super.key,
    required this.label,
    required this.text,
    required this.state,
    this.accent,
    this.onTap,
  });

  final String label;
  final String text;
  final AnswerOptionState state;

  /// Die Farbe des Bereichs, zu dem die Aufgabe gehört. Ohne Angabe die
  /// Schriftfarbe – dann trägt nur die Form.
  final ModulePalette? accent;

  final VoidCallback? onTap;

  /// Das Wort, das den Zustand benennt – für Vorlesehilfen, nicht fürs Auge.
  /// Sichtbar tragen den Zustand Fläche, Rand und Glyphe.
  static String? wordFor(AnswerOptionState state) => switch (state) {
        AnswerOptionState.correct => 'richtig',
        AnswerOptionState.wrong => 'deine Antwort',
        AnswerOptionState.selected => 'gewählt',
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final palette = accent ?? tokens.math;

    // Fläche, Rand, Markerfläche, Markerschrift.
    final (Color background, Color border, Color badge, Color onBadge) =
        switch (state) {
      AnswerOptionState.idle => (
          tokens.raised,
          theme.colorScheme.outlineVariant,
          tokens.sunk,
          theme.colorScheme.outline,
        ),
      AnswerOptionState.selected => (
          palette.soft,
          palette.accent,
          palette.accent,
          Colors.white,
        ),
      AnswerOptionState.correct => (
          palette.soft,
          palette.accent,
          palette.accent,
          Colors.white,
        ),
      AnswerOptionState.wrong => (
          tokens.wrongSoft,
          tokens.wrong,
          tokens.wrong,
          Colors.white,
        ),
      AnswerOptionState.dimmed => (
          tokens.raised,
          theme.colorScheme.outlineVariant,
          tokens.sunk,
          theme.colorScheme.outline,
        ),
    };

    final mark = switch (state) {
      AnswerOptionState.correct => Icons.check_rounded,
      AnswerOptionState.wrong => Icons.close_rounded,
      _ => null,
    };

    final dimmed = state == AnswerOptionState.dimmed;

    final word = wordFor(state);

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Semantics(
        container: true,
        button: onTap != null,
        label: word == null ? '$label. $text' : '$label. $text, $word',
        child: ExcludeSemantics(
          child: Opacity(
            opacity: dimmed ? 0.55 : 1,
            child: Material(
              color: background,
              borderRadius: Radii.bandRadius,
              child: InkWell(
                onTap: onTap,
                borderRadius: Radii.bandRadius,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 60),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: Radii.bandRadius,
                    border: Border.all(color: border, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: badge,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: NumText.inline.copyWith(
                            fontSize: 13,
                            color: onBadge,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          text,
                          style: theme.textTheme.titleMedium?.copyWith(
                            height: 1.35,
                          ),
                        ),
                      ),
                      if (mark != null) ...[
                        const SizedBox(width: Gap.sm),
                        Icon(mark, size: 20, color: badge),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
