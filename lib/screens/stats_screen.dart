import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/widgets/progress_section.dart';
import 'package:einstellungstest_trainer/widgets/timer_bar.dart';
import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:einstellungstest_trainer/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Uebersicht ueber den gespeicherten Lernfortschritt.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = ref.watch(statsControllerProvider);
    final averagePace = ref.watch(averagePaceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiken'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Fortschritt zurücksetzen',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmReset(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            Gap.screenPadding(MediaQuery.sizeOf(context).width),
            Gap.sm,
            Gap.screenPadding(MediaQuery.sizeOf(context).width),
            Gap.header,
          ),
          children: [
            // Drei Zahlen, die den Stand beschreiben: Menge, Treffer, Tempo.
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Gap.card,
                vertical: Gap.card,
              ),
              decoration: BoxDecoration(
                color: context.tokens.sunk,
                borderRadius: Radii.bandRadius,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _Headline(
                      value: '${stats.totalAnswered}',
                      label: 'Aufgaben',
                    ),
                  ),
                  Expanded(
                    child: _Headline(
                      value: stats.totalAnswered == 0
                          ? '–'
                          : '${(stats.accuracy * 100).round()} %',
                      label: 'Trefferquote',
                    ),
                  ),
                  Expanded(
                    child: _Headline(
                      value: averagePace == null
                          ? '–'
                          : formatShortDuration(averagePace),
                      label: 'Ø Tempo',
                    ),
                  ),
                ],
              ),
            ),
            const ProgressSection(),
            const SizedBox(height: Gap.section),
            const SectionTitle('Nach Bereich'),
            for (final module in TrainingModule.values)
              _ModuleStatsCard(module: module),
            const _SessionHistorySection(),
            if (stats.totalAnswered == 0) ...[
              const SizedBox(height: Gap.cardWide),
              Text(
                'Noch keine Daten. Starte eine Übungsrunde – die Ergebnisse '
                'werden automatisch auf diesem Gerät gespeichert.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Fortschritt zurücksetzen?'),
        content: const Text(
          'Alle gespeicherten Ergebnisse und Bestwerte werden gelöscht. '
          'Das lässt sich nicht rückgängig machen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (shouldReset ?? false) {
      await ref.read(statsControllerProvider.notifier).reset();
    }
  }
}

class _ModuleStatsCard extends ConsumerWidget {
  const _ModuleStatsCard({required this.module});

  final TrainingModule module;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = ref.watch(statsControllerProvider).forModule(module);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: Radii.bandRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(module.icon, size: 20, color: module.color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  module.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                stats.answered == 0
                    ? '–'
                    : '${(stats.accuracy * 100).round()} %',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: module.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.pill),
            child: LinearProgressIndicator(
              value: stats.accuracy,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(module.color),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MiniStat(
                label: 'gelöst',
                value: '${stats.answered}',
              ),
              _MiniStat(
                label: 'richtig',
                value: '${stats.correct}',
              ),
              _MiniStat(
                label: 'Sprint-Best',
                value: '${ref.watch(statsControllerProvider).bestSprintInModule(module)}',
              ),
              _MiniStat(
                label: 'Runden',
                value: '${stats.sessionsCompleted}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Die zuletzt abgeschlossenen Sitzungen aus dem gespeicherten Verlauf.
class _SessionHistorySection extends ConsumerWidget {
  const _SessionHistorySection();

  /// Wie viele Einträge angezeigt werden. Gespeichert werden mehr – hier soll
  /// nur der jüngste Verlauf sichtbar sein.
  static const int visibleCount = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sessions = ref.watch(sessionHistoryProvider);

    if (sessions.isEmpty) return const SizedBox.shrink();

    final visible = sessions.take(visibleCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Text(
          'Letzte Sitzungen',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        for (final session in visible) _SessionTile(session: session),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

  final TrainingSession session;

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day.$month. · $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = session.module?.color ?? theme.colorScheme.primary;
    final label = session.module?.shortLabel ?? 'Alle Module';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: Radii.bandRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label · ${session.mode.label}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatDate(session.finishedAt)} · '
                  '${formatMmSs(session.duration.inSeconds)} min · '
                  'Ø ${session.averageTimePerQuestion.inSeconds} s/Aufgabe',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${session.correctCount}/${session.total}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Eine der drei Kopfzahlen der Statistik.
class _Headline extends StatelessWidget {
  const _Headline({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: NumText.metric.copyWith(color: theme.colorScheme.onSurface),
        ),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
