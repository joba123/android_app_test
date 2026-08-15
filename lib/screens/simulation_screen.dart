import 'package:einstellungstest_trainer/models/simulation.dart';
import 'package:einstellungstest_trainer/screens/result_screen.dart';
import 'package:einstellungstest_trainer/services/simulation_controller.dart';
import 'package:einstellungstest_trainer/widgets/answer_option_tile.dart';
import 'package:einstellungstest_trainer/widgets/question_card.dart';
import 'package:einstellungstest_trainer/widgets/timer_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fuehrt durch eine mehrteilige Testsimulation.
///
/// Ablauf je Teil: Briefing (Zeit laeuft noch nicht) -> Bearbeitung mit
/// Countdown -> automatischer Uebergang zum naechsten Teil.
class SimulationScreen extends ConsumerWidget {
  const SimulationScreen({super.key, required this.blueprint});

  final SimulationBlueprint blueprint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = simulationControllerProvider(blueprint.id);
    final session = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    return switch (session.stage) {
      SimulationStage.briefing => _BriefingView(
          session: session,
          onStart: controller.startPart,
        ),
      SimulationStage.running => _RunningView(
          session: session,
          onAnswer: controller.answer,
          onSkip: controller.skip,
          onAbort: () => _confirmAbort(context, controller),
        ),
      SimulationStage.finished => SimulationResultScreen(
          session: session,
          onRetry: () => ref.invalidate(provider),
        ),
    };
  }

  Future<void> _confirmAbort(
    BuildContext context,
    SimulationController controller,
  ) async {
    final shouldAbort = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Simulation abbrechen?'),
        content: const Text(
          'Alle noch offenen Aufgaben werden als nicht beantwortet gewertet. '
          'Du siehst anschließend trotzdem die vollständige Auswertung.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Weitermachen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Abbrechen'),
          ),
        ],
      ),
    );

    if (shouldAbort ?? false) controller.abort();
  }
}

/// Briefing vor einem Testteil - hier laeuft die Uhr noch nicht.
class _BriefingView extends StatelessWidget {
  const _BriefingView({required this.session, required this.onStart});

  final SimulationSession session;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final part = session.currentPartSpec;
    final partNumber = session.partIndex + 1;
    final totalParts = session.loadedParts.length;
    final isFirst = session.partIndex == 0;

    return Scaffold(
      appBar: AppBar(title: Text(session.blueprint.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isFirst)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E9F6E).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Teil ${session.partIndex} abgeschlossen. '
                    'Kurz durchatmen – dann geht es weiter.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF07543A),
                    ),
                  ),
                ),
              Text(
                'Teil $partNumber von $totalParts',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                part.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    _BriefingRow(
                      icon: Icons.list_alt_outlined,
                      label: 'Aufgaben',
                      value: '${session.currentPart.questions.length}',
                    ),
                    const Divider(height: 20),
                    _BriefingRow(
                      icon: Icons.schedule_outlined,
                      label: 'Bearbeitungszeit',
                      value: '${part.duration.inMinutes} Minuten',
                    ),
                    const Divider(height: 20),
                    _BriefingRow(
                      icon: Icons.speed_outlined,
                      label: 'Ø pro Aufgabe',
                      value: '${part.timePerQuestion.inSeconds} Sekunden',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                part.instructions,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                'Der Countdown startet, sobald du auf "Teil starten" tippst. '
                'Ein Zurück gibt es nicht.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onStart,
                child: Text(isFirst ? 'Teil starten' : 'Nächsten Teil starten'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BriefingRow extends StatelessWidget {
  const _BriefingRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 19, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Bearbeitung eines Testteils unter Zeitdruck.
class _RunningView extends StatelessWidget {
  const _RunningView({
    required this.session,
    required this.onAnswer,
    required this.onSkip,
    required this.onAbort,
  });

  final SimulationSession session;
  final ValueChanged<int> onAnswer;
  final VoidCallback onSkip;
  final VoidCallback onAbort;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = session.currentQuestion;
    final part = session.currentPartSpec;

    return Scaffold(
      appBar: AppBar(
        title: Text('Teil ${session.partIndex + 1}: ${part.module.shortLabel}'),
        actions: [
          TextButton(
            onPressed: onAbort,
            child: const Text('Abbrechen'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: TimerBar(
                remainingSeconds: session.remainingSeconds,
                totalSeconds: part.duration.inSeconds,
                label: part.title,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Aufgabe ${session.questionIndex + 1} von '
                    '${session.currentPart.questions.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Teil ${session.partIndex + 1}/${session.loadedParts.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  QuestionCard(question: question),
                  const SizedBox(height: 18),
                  for (var index = 0; index < question.options.length; index++)
                    AnswerOptionTile(
                      label: String.fromCharCode(65 + index),
                      text: question.options[index],
                      state: session.selectedIndex == index
                          ? AnswerOptionState.selected
                          : AnswerOptionState.idle,
                      onTap: () => onAnswer(index),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: OutlinedButton(
                onPressed: onSkip,
                child: const Text('Überspringen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
