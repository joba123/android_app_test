import 'package:einstellungstest_trainer/models/progress_trend.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/widgets/trend_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// „Bin ich besser geworden?" – die Frage, die vor einer Prüfung zählt.
///
/// Der Abschnitt erscheint erst, wenn genug Verlauf vorliegt. Aus einer
/// einzelnen Übungsrunde eine Entwicklung abzuleiten wäre erfunden.
class ProgressSection extends ConsumerWidget {
  const ProgressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final trend = ProgressTrend(ref.watch(sessionHistoryProvider));

    if (!trend.hasEnoughHistory()) return const SizedBox.shrink();

    final comparison = trend.compareWindows();
    final streak = trend.streak();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 26),
        Text(
          'Entwicklung',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        if (comparison.isComparable) _ComparisonCard(comparison: comparison),
        if (streak >= 2) ...[
          const SizedBox(height: 10),
          _StreakRow(days: streak, activeDays: trend.activeDays),
        ],
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trefferquote je Woche',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Wochen ohne Übung bleiben leer.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TrendChart(points: trend.weeklyPoints()),
            ],
          ),
        ),
      ],
    );
  }
}

/// Der direkte Vergleich zweier Wochen – als Satz, nicht als Zahlenkolonne.
class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({required this.comparison});

  final TrendComparison comparison;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final delta = comparison.accuracyDelta;
    final points = (delta * 100).round().abs();

    final (icon, accent, headline) = switch (comparison) {
      final c when c.improved => (
          Icons.trending_up,
          const Color(0xFF0E9F6E),
          'Du bist besser geworden',
        ),
      final c when c.declined => (
          Icons.trending_down,
          theme.colorScheme.error,
          'Zuletzt lief es schwächer',
        ),
      _ => (
          Icons.trending_flat,
          theme.colorScheme.onSurfaceVariant,
          'Dein Stand bleibt stabil',
        ),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Symbol und Text tragen die Aussage – nicht die Farbe allein.
          Icon(icon, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _describe(points),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _describe(int points) {
    final current = (comparison.current.accuracy * 100).round();
    final previous = (comparison.previous.accuracy * 100).round();

    final change = switch (comparison) {
      final c when c.improved => '$points Punkte mehr',
      final c when c.declined => '$points Punkte weniger',
      _ => 'kaum verändert',
    };

    return 'Letzte 7 Tage: $current % · die 7 davor: $previous % '
        '($change).\n'
        '${comparison.current.answered} Aufgaben in diesem Zeitraum.';
  }
}

class _StreakRow extends StatelessWidget {
  const _StreakRow({required this.days, required this.activeDays});

  final int days;
  final int activeDays;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.local_fire_department_outlined,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$days Tage in Folge geübt · $activeDays Übungstage insgesamt',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
