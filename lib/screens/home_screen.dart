import 'package:einstellungstest_trainer/data/simulation_blueprints.dart';
import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/quiz_session.dart';
import 'package:einstellungstest_trainer/models/todays_plan.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/screens/practice_setup_screen.dart';
import 'package:einstellungstest_trainer/screens/quiz_screen.dart';
import 'package:einstellungstest_trainer/screens/simulation_screen.dart';
import 'package:einstellungstest_trainer/screens/sprint_setup_screen.dart';
import 'package:einstellungstest_trainer/services/exam_date_controller.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:einstellungstest_trainer/widgets/exam_header.dart';
import 'package:einstellungstest_trainer/widgets/module_row.dart';
import 'package:einstellungstest_trainer/widgets/plan_card.dart';
import 'package:einstellungstest_trainer/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Die Startseite beantwortet **eine** Frage: Was soll ich jetzt tun?
///
/// Deshalb genau ein Vorschlag mit einem Knopf, darunter nur noch Datenzeilen.
/// Alles Erklärende ist verschwunden – wer wissen will, wie die App
/// funktioniert, findet die Einführung unter „Mehr".
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsControllerProvider);
    final examDate = ref.watch(examDateProvider);
    final book = ref.watch(reviewBookProvider);
    final side = Gap.screenPadding(MediaQuery.sizeOf(context).width);

    final plan = TodaysPlan.from(
      book: book,
      totalAnswered: stats.totalAnswered,
      now: DateTime.now(),
    );

    void open(Widget screen) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => screen),
      );
    }

    void startPractice(PracticeScope scope, int length) {
      open(
        QuizScreen(
          mode: SessionMode.practice,
          scope: scope,
          length: length,
        ),
      );
    }

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ExamHeader(
            examDate: examDate,
            accuracy: stats.totalAnswered == 0 ? null : stats.accuracy,
            answered: stats.totalAnswered,
            onTapDate: () => open(const PracticeSetupScreen()),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(side, Gap.section, side, Gap.section),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionTitle('Heute dran'),
                PlanCard(
                  plan: plan,
                  onStart: () => startPractice(plan.scope, plan.length),
                  onOther: () => open(const PracticeSetupScreen()),
                ),
                const SizedBox(height: Gap.md),
                _SprintRow(
                  best: stats.bestSprintOverall,
                  onTap: () => open(const SprintSetupScreen()),
                ),
                const SizedBox(height: Gap.section),
                const SectionTitle('Stand je Modul'),
                for (final module in TrainingModule.values)
                  ModuleRow(
                    module: module,
                    accuracy: stats.forModule(module).accuracy,
                    // Antippen startet sofort – kein Zwischenbildschirm.
                    onTap: () => startPractice(
                      PracticeScope.module(module),
                      TodaysPlan.regularLength,
                    ),
                  ),
                const SizedBox(height: Gap.section),
                const SectionTitle('Ernstfall'),
                // Erst der kurze Weg hinein, dann der lange. Wer 45 Minuten
                // am Stueck nicht aufbringt, soll das Format trotzdem einmal
                // erlebt haben.
                _TryoutRow(
                  onTap: () => open(
                    const SimulationScreen(
                      blueprint: SimulationBlueprints.tryout,
                    ),
                  ),
                ),
                const SizedBox(height: Gap.md),
                _SimulationRow(
                  onTap: () => open(
                    const SimulationScreen(
                      blueprint: SimulationBlueprints.full,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Der Sprint als eigene, kleinere Karte – mit seinem Bestwert, weil der
/// der eigentliche Anreiz ist.
class _SprintRow extends StatelessWidget {
  const _SprintRow({required this.best, required this.onTap});

  final int best;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return Material(
      color: tokens.raised,
      borderRadius: Radii.cardRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.cardRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Gap.card,
            vertical: Gap.md,
          ),
          decoration: BoxDecoration(
            borderRadius: Radii.cardRadius,
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(
                Icons.bolt_outlined,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Text('Sprint · 60 s', style: theme.textTheme.titleSmall),
              ),
              if (best > 0)
                Text(
                  'Bestwert $best',
                  style: MonoText.inline.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(width: Gap.sm),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Der Probelauf: dieselbe Mechanik wie die Simulation, aber auf Papier
/// statt in Tinte – er soll einladen, nicht einschüchtern.
class _TryoutRow extends StatelessWidget {
  const _TryoutRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    const blueprint = SimulationBlueprints.tryout;

    return Material(
      color: tokens.raised,
      borderRadius: Radii.cardRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.cardRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Gap.card,
            vertical: Gap.md,
          ),
          decoration: BoxDecoration(
            borderRadius: Radii.cardRadius,
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(blueprint.title, style: theme.textTheme.titleSmall),
                    Text(
                      'Ein Teil · '
                      '${blueprint.totalDuration.inMinutes} Min · '
                      'zum Kennenlernen',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Die Simulation als eine Zeile in Tinte.
class _SimulationRow extends StatelessWidget {
  const _SimulationRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    const blueprint = SimulationBlueprints.full;

    return Material(
      color: tokens.ink,
      borderRadius: Radii.cardRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.cardRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Gap.card,
            vertical: Gap.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blueprint.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: tokens.onInk,
                      ),
                    ),
                    Text(
                      '${blueprint.parts.length} Teile · '
                      '${blueprint.totalDuration.inMinutes} Min',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: tokens.onInk.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: tokens.onInk.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
