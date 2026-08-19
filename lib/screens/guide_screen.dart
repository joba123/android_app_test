import 'package:einstellungstest_trainer/data/simulation_blueprints.dart';
import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/quiz_session.dart';
import 'package:einstellungstest_trainer/models/readiness.dart';
import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/screens/quiz_screen.dart';
import 'package:einstellungstest_trainer/screens/simulation_screen.dart';
import 'package:einstellungstest_trainer/screens/strike_out_screen.dart';
import 'package:einstellungstest_trainer/services/exam_plan_controller.dart';
import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:einstellungstest_trainer/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Der Leitfaden: was für diese Prüfung noch fehlt.
///
/// Die Liste ist nicht „alles, was die App kann", sondern das, was die
/// gewählte Fachrichtung verlangt. Jede Zeile sagt, woran es hakt – zu wenig
/// Aufgaben oder zu niedrige Quote – und startet mit einem Tipp die passende
/// Runde.
class GuideScreen extends ConsumerWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final plan = ref.watch(activeExamPlanProvider);
    final readiness = ref.watch(readinessProvider);
    final side = Gap.screenPadding(MediaQuery.sizeOf(context).width);

    return Scaffold(
      appBar: AppBar(title: const Text('Leitfaden')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(side, Gap.card, side, Gap.header),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(readiness.progress * 100).round()} %',
                    style: NumText.display.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: Gap.xs),
                  Text(
                    plan == null
                        ? readiness.summary
                        : '${plan.field.label} · ${readiness.summary}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Gap.card),
            ReadinessBar(readiness: readiness),
            const SizedBox(height: Gap.section),
            if (readiness.openSteps.isNotEmpty) ...[
              const SectionTitle('Das fehlt noch'),
              for (final step in readiness.openSteps)
                _StepRow(
                  step: step,
                  onTap: () => _start(context, step),
                ),
              const SizedBox(height: Gap.section),
            ],
            const SectionTitle('Der Ernstfall'),
            _SimulationStep(readiness: readiness),
            if (readiness.doneSteps.isNotEmpty) ...[
              const SizedBox(height: Gap.section),
              const SectionTitle('Sitzt'),
              for (final step in readiness.doneSteps)
                _StepRow(
                  step: step,
                  onTap: () => _start(context, step),
                ),
            ],
            const SizedBox(height: Gap.section),
            Text(
              'Ein Thema gilt als erledigt, wenn du mindestens '
              '${_requirementText(readiness)} und dabei '
              '${(Readiness.targetAccuracy * 100).round()} % erreicht hast. '
              'Dazu kommt eine Testsimulation mit mindestens '
              '${(Readiness.simulationTarget * 100).round()} %.',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  void _start(BuildContext context, TopicStep step) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => step.subCategory.hasOwnScreen
            ? const StrikeOutScreen()
            : QuizScreen(
                mode: SessionMode.practice,
                scope: PracticeScope.subCategory(step.subCategory),
              ),
      ),
    );
  }
}

/// Formuliert die Mengenanforderung – sie hängt am Gewicht des Themas.
String _requirementText(Readiness readiness) {
  final core = readiness.steps
      .where((step) => step.weight.requiredAnswers > 0)
      .map((step) => step.required)
      .toSet()
      .toList()
    ..sort();

  if (core.isEmpty) return '0 Aufgaben löst';
  if (core.length == 1) return '${core.first} Aufgaben löst';
  return '${core.first} bis ${core.last} Aufgaben löst';
}

/// Der Fortschrittsbalken des Leitfadens: erledigte Schritte gegen alle.
class ReadinessBar extends StatelessWidget {
  const ReadinessBar({super.key, required this.readiness});

  final Readiness readiness;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final done = readiness.doneSteps.length +
        (readiness.simulationPassed ? 1 : 0);
    final total = readiness.steps.length + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Radii.pill),
          child: LinearProgressIndicator(
            value: readiness.progress,
            minHeight: 8,
            backgroundColor: tokens.sunk,
            valueColor: AlwaysStoppedAnimation<Color>(
              readiness.isReady ? tokens.correct : theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: Gap.sm),
        Text(
          '$done von $total Schritten erledigt',
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.onTap});

  final TopicStep step;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final palette = tokens.paletteOf(step.subCategory.module.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Material(
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
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: step.isDone ? tokens.correct : palette.soft,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: step.isDone
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        )
                      : Text(
                          '${(step.progress * 100).round()}',
                          style: NumText.inline.copyWith(
                            fontSize: 11,
                            color: palette.deep,
                          ),
                        ),
                ),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.subCategory.label,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${step.weight.label} · ${step.advice}',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  '${step.answered}/${step.required}',
                  style: NumText.inline.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(width: Gap.sm),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Die Testsimulation als letzter Schritt des Leitfadens.
class _SimulationStep extends StatelessWidget {
  const _SimulationStep({required this.readiness});

  final Readiness readiness;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final score = readiness.simulationScore;

    return Material(
      color: tokens.raised,
      borderRadius: Radii.bandRadius,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const SimulationScreen(
              blueprint: SimulationBlueprints.full,
            ),
          ),
        ),
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
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: readiness.simulationPassed
                      ? tokens.correct
                      : tokens.sunk,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  readiness.simulationPassed
                      ? Icons.check_rounded
                      : Icons.timer_outlined,
                  size: 16,
                  color: readiness.simulationPassed
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gesamtsimulation bestehen',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      score == null
                          ? 'Noch kein Durchlauf'
                          : 'Bester Durchlauf: ${(score * 100).round()} %',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
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
