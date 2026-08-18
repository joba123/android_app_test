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
/// Jeder Zustand ist **vierfach** unterschieden: über die Farbe, über die
/// Glyphe im Marker, über ein Wort am Ende und über die Textauszeichnung. So
/// bleibt die Rückmeldung auch bei Farbfehlsichtigkeit und im Sonnenlicht
/// lesbar – Farbe allein trägt hier nie eine Bedeutung.
///
/// Die Glyphen sind Material-Icons und keine Textzeichen: ✓ und ✕ fehlen im
/// gebündelten Schriftschnitt und würden auf eine Systemschrift zurückfallen.
class AnswerOptionTile extends StatelessWidget {
  const AnswerOptionTile({
    super.key,
    required this.label,
    required this.text,
    required this.state,
    this.onTap,
  });

  final String label;
  final String text;
  final AnswerOptionState state;
  final VoidCallback? onTap;

  /// Das Wort, das den Zustand benennt. `null` heißt: nichts zu sagen.
  static String? wordFor(AnswerOptionState state) => switch (state) {
        AnswerOptionState.correct => 'richtig',
        AnswerOptionState.wrong => 'deine Antwort',
        AnswerOptionState.selected => 'gewählt',
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = context.tokens;

    final (Color background, Color accent, Color foreground) = switch (state) {
      AnswerOptionState.idle => (
          tokens.raised,
          scheme.outlineVariant,
          scheme.onSurface,
        ),
      AnswerOptionState.selected => (
          tokens.sunk,
          tokens.ink,
          scheme.onSurface,
        ),
      AnswerOptionState.correct => (
          tokens.raised,
          tokens.correct,
          tokens.correct,
        ),
      AnswerOptionState.wrong => (
          tokens.raised,
          tokens.wrong,
          tokens.wrong,
        ),
      AnswerOptionState.dimmed => (
          tokens.raised,
          scheme.outlineVariant,
          scheme.onSurfaceVariant,
        ),
    };

    // Der Marker traegt entweder den Buchstaben oder die Zustandsglyphe.
    final markerIcon = switch (state) {
      AnswerOptionState.correct => Icons.check,
      AnswerOptionState.wrong => Icons.close,
      _ => null,
    };

    final word = wordFor(state);
    final emphasised =
        state == AnswerOptionState.correct || state == AnswerOptionState.wrong;

    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Material(
        color: background,
        borderRadius: Radii.inputRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: Radii.inputRadius,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Gap.md,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              borderRadius: Radii.inputRadius,
              border: Border.all(
                color: accent,
                width: state == AnswerOptionState.idle ? 1 : 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _Marker(
                  label: label,
                  icon: markerIcon,
                  accent: accent,
                  filled: emphasised || state == AnswerOptionState.selected,
                ),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Text(
                    text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: foreground,
                      fontWeight:
                          emphasised ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (word != null) ...[
                  const SizedBox(width: Gap.sm),
                  Text(
                    word,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: emphasised ? accent : scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Buchstaben-Marker, im aufgedeckten Zustand mit Glyphe statt Buchstabe.
class _Marker extends StatelessWidget {
  const _Marker({
    required this.label,
    required this.icon,
    required this.accent,
    required this.filled,
  });

  final String label;
  final IconData? icon;
  final Color accent;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? accent : Colors.transparent,
        borderRadius: Radii.inputRadius,
        border: Border.all(color: accent),
      ),
      child: icon != null
          ? Icon(
              icon,
              size: 18,
              color: filled
                  ? theme.colorScheme.surface
                  : accent,
            )
          : Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: filled ? theme.colorScheme.surface : accent,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
