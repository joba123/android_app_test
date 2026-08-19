import 'package:einstellungstest_trainer/models/simulation.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';

/// Die Testsimulation – die einzige dunkle Fläche der App.
///
/// Das ist Absicht: Alles andere ist Üben auf Papier, das hier ist der
/// Ernstfall. Die Karte nennt ihren Umfang, den letzten Versuch und hat
/// einen eigenen Knopf, damit sie nicht versehentlich startet.
class SimulationCard extends StatelessWidget {
  const SimulationCard({
    super.key,
    required this.blueprint,
    required this.onStart,
    this.lastScore,
  });

  final SimulationBlueprint blueprint;
  final VoidCallback onStart;

  /// Trefferquote des letzten Durchlaufs, 0 bis 1. `null`, wenn es noch
  /// keinen gab.
  final double? lastScore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = blueprint.parts.length;

    return Container(
      decoration: const BoxDecoration(
        color: ExamTokens.examSurface,
        borderRadius: Radii.cardRadius,
      ),
      padding: const EdgeInsets.all(Gap.cardWide),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            blueprint.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: ExamTokens.onExam,
            ),
          ),
          const SizedBox(height: Gap.sm),
          Text(
            parts == 1
                ? 'Ein Testteil, ${blueprint.totalDuration.inMinutes} Minuten, '
                    '${blueprint.totalQuestions} Aufgaben.'
                : 'Alle drei Bereiche, ${blueprint.totalQuestions} Aufgaben, '
                    '${blueprint.totalDuration.inMinutes} Minuten – '
                    'wie am echten Testtag.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: ExamTokens.onExamVariant,
            ),
          ),
          const SizedBox(height: Gap.card),
          Row(
            children: [
              Expanded(
                child: Text(
                  lastScore == null
                      ? 'Noch kein Versuch'
                      : 'Letzter Versuch: '
                          '${(lastScore! * 100).round()} %',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: ExamTokens.onExamVariant,
                  ),
                ),
              ),
              Material(
                color: ExamTokens.onExam,
                borderRadius: Radii.buttonRadius,
                child: InkWell(
                  onTap: onStart,
                  borderRadius: Radii.buttonRadius,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 14,
                    ),
                    child: Text(
                      'Starten',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: ExamTokens.examSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Der Probelauf als schmale Zeile unter der Simulation.
class TryoutRow extends StatelessWidget {
  const TryoutRow({
    super.key,
    required this.blueprint,
    required this.onTap,
  });

  final SimulationBlueprint blueprint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return Material(
      color: tokens.raised,
      borderRadius: Radii.bandRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.bandRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Gap.card,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: Radii.bandRadius,
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(blueprint.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      'Ein Teil · ${blueprint.totalDuration.inMinutes} Min · '
                      'zum Kennenlernen',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
