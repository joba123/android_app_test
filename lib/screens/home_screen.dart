import 'package:einstellungstest_trainer/data/question_pool.dart';
import 'package:einstellungstest_trainer/data/simulation_blueprints.dart';
import 'package:einstellungstest_trainer/models/exam_date.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/screens/module_screen.dart';
import 'package:einstellungstest_trainer/screens/practice_setup_screen.dart';
import 'package:einstellungstest_trainer/screens/pro_screen.dart';
import 'package:einstellungstest_trainer/screens/settings_screen.dart';
import 'package:einstellungstest_trainer/screens/simulation_screen.dart';
import 'package:einstellungstest_trainer/screens/sprint_setup_screen.dart';
import 'package:einstellungstest_trainer/screens/stats_screen.dart';
import 'package:einstellungstest_trainer/services/exam_date_controller.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/services/purchase/entitlement_controller.dart';
import 'package:einstellungstest_trainer/services/quiz_controller.dart';
import 'package:einstellungstest_trainer/widgets/module_card.dart';
import 'package:einstellungstest_trainer/widgets/review_card.dart';
import 'package:einstellungstest_trainer/widgets/stat_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = ref.watch(statsControllerProvider);
    final examDate = ref.watch(examDateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungstest Trainer'),
        actions: [
          IconButton(
            tooltip: 'Einstellungen',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Statistik',
            icon: const Icon(Icons.insights_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const StatsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Text(
              'Bereit für den nächsten Test?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Trainiere gezielt die Aufgabentypen, die in Einstellungs- und '
              'Eignungstests am häufigsten vorkommen.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            if (examDate != null) ...[
              const SizedBox(height: 18),
              _ExamCountdown(examDate: examDate),
            ],
            const SizedBox(height: 18),
            const ReviewCard(),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    value: '${stats.totalAnswered}',
                    label: 'Aufgaben gelöst',
                    icon: Icons.checklist_rtl,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    value: stats.totalAnswered == 0
                        ? '–'
                        : '${(stats.accuracy * 100).round()} %',
                    label: 'Trefferquote',
                    icon: Icons.percent,
                    color: const Color(0xFF0E9F6E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Text(
              'Schnellstart',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ModeCard(
              title: 'Übungsmodus',
              subtitle: 'Einzelnes Thema oder alle Kategorien gemischt – '
                  'mit Lösung und Rechenweg nach jeder Antwort.',
              meta: 'ohne Zeitdruck',
              icon: Icons.school_outlined,
              color: theme.colorScheme.primary,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PracticeSetupScreen(),
                ),
              ),
            ),
            ModeCard(
              title: 'Sprint-Modus',
              subtitle: '60 Sekunden auf einen Aufgabentyp – '
                  'Auswertung erst danach.',
              meta: '${QuizController.sprintSeconds} Sek',
              icon: Icons.bolt_outlined,
              color: const Color(0xFFD97706),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SprintSetupScreen(),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Module',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (final module in TrainingModule.values)
              ModuleCard(
                module: module,
                sizeLabel: QuestionPool.describeSize(module),
                accuracy: stats.forModule(module).accuracy,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ModuleScreen(module: module),
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Text(
              'Ernstfall',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ModeCard(
              title: SimulationBlueprints.full.title,
              subtitle: SimulationBlueprints.full.description,
              meta:
                  '${SimulationBlueprints.full.totalDuration.inMinutes} Min',
              icon: Icons.timer_outlined,
              color: theme.colorScheme.error,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SimulationScreen(
                    blueprint: SimulationBlueprints.full,
                  ),
                ),
              ),
            ),
            if (!ref.watch(isProProvider)) ...[
              const SizedBox(height: 20),
              const _ProHint(),
            ],
          ],
        ),
      ),
    );
  }
}

/// Ein Satz am Ende der Startseite – kein Banner, kein Dialog, kein Abfangen
/// beim Start. Wer mehr wissen will, tippt darauf.
class _ProHint extends StatelessWidget {
  const _ProHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ProScreen()),
      ),
      style: TextButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        foregroundColor: theme.colorScheme.onSurfaceVariant,
      ),
      child: const Text('Pro: mehr Aufgaben, keine Werbung'),
    );
  }
}

/// Countdown bis zum hinterlegten Testtermin.
///
/// Erscheint nur, wenn ein Termin gesetzt ist – ein leerer Platzhalter auf der
/// Startseite waere nur Rauschen.
class _ExamCountdown extends StatelessWidget {
  const _ExamCountdown({required this.examDate});

  final ExamDate examDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final past = examDate.isPast(now);
    final accent = past ? theme.colorScheme.outline : theme.colorScheme.primary;

    return Material(
      color: accent.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.event_available_outlined, color: accent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      examDate.describe(now),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        _formatDate(examDate.date),
                        if (examDate.label != null) examDate.label!,
                      ].join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }
}
