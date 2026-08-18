import 'package:einstellungstest_trainer/data/question_pool.dart';
import 'package:einstellungstest_trainer/data/simulation_blueprints.dart';
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
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:einstellungstest_trainer/widgets/exam_header.dart';
import 'package:einstellungstest_trainer/widgets/module_card.dart';
import 'package:einstellungstest_trainer/widgets/review_card.dart';
import 'package:einstellungstest_trainer/widgets/section_title.dart';
import 'package:einstellungstest_trainer/widgets/stat_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsControllerProvider);
    final examDate = ref.watch(examDateProvider);
    final width = MediaQuery.sizeOf(context).width;
    final side = Gap.screenPadding(width);

    void open(Widget screen) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => screen),
      );
    }

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Der Termin ist der Anker: Er sitzt in der dunklen Kopffläche,
          // nicht in einer Karte unter anderen.
          ExamHeader(
            examDate: examDate,
            onTapDate: () => open(const SettingsScreen()),
            trailing: Row(
              children: [
                _HeaderAction(
                  tooltip: 'Statistik',
                  icon: Icons.insights_outlined,
                  onPressed: () => open(const StatsScreen()),
                ),
                _HeaderAction(
                  tooltip: 'Einstellungen',
                  icon: Icons.settings_outlined,
                  onPressed: () => open(const SettingsScreen()),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(side, Gap.section, side, Gap.section),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ReviewCard(),
                _StatRow(
                  answered: stats.totalAnswered,
                  accuracy: stats.accuracy,
                  narrow: width < Gap.narrowWidth,
                ),
                const SizedBox(height: Gap.section),
                const SectionTitle('Schnellstart'),
                ModeCard(
                  title: 'Übungsmodus',
                  subtitle: 'Einzelnes Thema oder alle Kategorien gemischt – '
                      'mit Lösung und Rechenweg nach jeder Antwort.',
                  meta: 'ohne Zeit',
                  icon: Icons.school_outlined,
                  color: Colors.transparent,
                  onTap: () => open(const PracticeSetupScreen()),
                ),
                ModeCard(
                  title: 'Sprint-Modus',
                  subtitle: '60 Sekunden auf einen Aufgabentyp – '
                      'Auswertung erst danach.',
                  meta: '${QuizController.sprintSeconds} Sek',
                  icon: Icons.bolt_outlined,
                  color: Colors.transparent,
                  onTap: () => open(const SprintSetupScreen()),
                ),
                const SizedBox(height: Gap.md),
                const SectionTitle('Module', trailing: 'alle Themen'),
                for (final module in TrainingModule.values)
                  ModuleCard(
                    module: module,
                    sizeLabel: QuestionPool.describeSize(module),
                    accuracy: stats.forModule(module).accuracy,
                    onTap: () => open(ModuleScreen(module: module)),
                  ),
                const SizedBox(height: Gap.md),
                const SectionTitle('Ernstfall'),
                _SimulationCard(
                  onTap: () => open(
                    const SimulationScreen(
                      blueprint: SimulationBlueprints.full,
                    ),
                  ),
                ),
                if (!ref.watch(isProProvider)) ...[
                  const SizedBox(height: Gap.card),
                  const _ProHint(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Aktionsknopf in der dunklen Kopffläche.
class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon),
      color: context.tokens.onInk.withValues(alpha: 0.8),
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
    );
  }
}

/// Die beiden Kennzahlen. Ab 360 dp Breite nebeneinander, darunter
/// untereinander.
class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.answered,
    required this.accuracy,
    required this.narrow,
  });

  final int answered;
  final double accuracy;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      StatTile(
        value: '$answered',
        label: 'Aufgaben gelöst',
        icon: Icons.checklist_rtl,
      ),
      StatTile(
        value: answered == 0 ? '–' : '${(accuracy * 100).round()} %',
        label: 'Trefferquote',
        icon: Icons.percent,
      ),
    ];

    if (narrow) {
      return Column(
        children: [
          tiles.first,
          const SizedBox(height: Gap.md),
          tiles.last,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: tiles.first),
        const SizedBox(width: Gap.md),
        Expanded(child: tiles.last),
      ],
    );
  }
}

/// Der Ernstfall bekommt eine eigene Karte in Tinte – schon auf der
/// Startseite ist sichtbar, dass hier ein anderes Register beginnt.
class _SimulationCard extends StatelessWidget {
  const _SimulationCard({required this.onTap});

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
          padding: const EdgeInsets.all(Gap.card),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                blueprint.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: tokens.onInk,
                ),
              ),
              const SizedBox(height: Gap.xs),
              Text(
                '${blueprint.parts.length} Teile · '
                '${blueprint.totalDuration.inMinutes} Minuten · '
                'keine Lösungen während des Tests',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: tokens.onInk.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
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
    return TextButton(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ProScreen()),
      ),
      style: TextButton.styleFrom(minimumSize: const Size.fromHeight(44)),
      child: const Text('Pro: mehr Aufgaben, keine Werbung'),
    );
  }
}
