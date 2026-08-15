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

/// Eine anklickbare Antwortmoeglichkeit mit Buchstaben-Marker (A, B, C, D).
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (Color background, Color border, Color foreground) = switch (state) {
      AnswerOptionState.idle => (
          scheme.surface,
          scheme.outlineVariant,
          scheme.onSurface,
        ),
      AnswerOptionState.selected => (
          scheme.primaryContainer,
          scheme.primary,
          scheme.onPrimaryContainer,
        ),
      AnswerOptionState.correct => (
          const Color(0xFFE3F6EC),
          const Color(0xFF0E9F6E),
          const Color(0xFF07543A),
        ),
      AnswerOptionState.wrong => (
          const Color(0xFFFDE8E8),
          scheme.error,
          const Color(0xFF7A1B1B),
        ),
      AnswerOptionState.dimmed => (
          scheme.surface,
          scheme.outlineVariant,
          scheme.onSurfaceVariant,
        ),
    };

    final trailingIcon = switch (state) {
      AnswerOptionState.correct => Icons.check_circle,
      AnswerOptionState.wrong => Icons.cancel,
      _ => null,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: 1.4),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: border.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: theme.textTheme.bodyLarge?.copyWith(color: foreground),
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  Icon(trailingIcon, color: border, size: 22),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
