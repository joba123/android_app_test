import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/simulation.dart';
import 'package:einstellungstest_trainer/screens/result_screen.dart';
import 'package:einstellungstest_trainer/services/simulation_controller.dart';
import 'package:einstellungstest_trainer/widgets/answer_option_tile.dart';
import 'package:einstellungstest_trainer/widgets/numeric_answer_field.dart';
import 'package:einstellungstest_trainer/widgets/question_card.dart';
import 'package:einstellungstest_trainer/widgets/timer_bar.dart';
import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Was beim Versuch, die Simulation zu verlassen, gewählt wurde.
enum _InterruptChoice { resume, pause, abort }

/// Führt durch eine mehrteilige Testsimulation.
///
/// Ablauf je Teil: Briefing (Zeit läuft noch nicht) → Bearbeitung mit
/// Countdown → automatischer Übergang zum nächsten Teil. Während des Laufs
/// gibt es keine Lösungen und keine Zwischenauswertung.
///
/// Verlassen ist nur über eine ausdrückliche Rückfrage möglich – auch über die
/// Zurück-Taste. Pausieren geht, wird aber deutlich als unrealistisch
/// gekennzeichnet und in der Auswertung vermerkt.
class SimulationScreen extends ConsumerWidget {
  const SimulationScreen({super.key, required this.blueprint});

  final SimulationBlueprint blueprint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = simulationControllerProvider(blueprint.id);
    final session = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    if (session.stage == SimulationStage.finished) {
      final summary = session.summary;
      if (summary != null) {
        return SimulationResultScreen(
          session: session,
          summary: summary,
          onRetry: () => ref.invalidate(provider),
        );
      }
    }

    // Der Ernstfall ist in hell wie dunkel schwarz. Der Wechsel ins Dunkel
    // ist der Vorhang vor der Prüfung: kein Papier, keine Karten mit Rand,
    // nur Trennlinien und Mono. Die Auswertung danach gehoert wieder zum
    // Ueben und bleibt deshalb im normalen Modus.
    return Theme(
      data: buildAppTheme(Brightness.dark),
      child: _buildRun(context, ref, session, controller),
    );
  }

  Widget _buildRun(
    BuildContext context,
    WidgetRef ref,
    SimulationSession session,
    SimulationController controller,
  ) {
    // Solange die Simulation läuft, ist ein stilles Verlassen nicht möglich –
    // sonst wäre der Durchlauf mit einem Wisch weg.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleInterrupt(context, controller, session);
      },
      child: switch (session.stage) {
        SimulationStage.briefing => _BriefingView(
            session: session,
            onStart: controller.startPart,
            onLeave: () => _handleInterrupt(context, controller, session),
          ),
        SimulationStage.running => _RunningView(
            session: session,
            onSelectOption: controller.selectOption,
            onSubmitNumber: controller.submitNumber,
            onSkip: controller.skip,
            onPause: () => _confirmPause(context, controller),
            onLeave: () => _handleInterrupt(context, controller, session),
          ),
        SimulationStage.paused => _PausedView(
            session: session,
            onResume: controller.resume,
            onAbort: () => _confirmAbort(context, controller),
          ),
        // Wird oben abgefangen; hier nur der Vollständigkeit halber.
        SimulationStage.finished => const SizedBox.shrink(),
      },
    );
  }

  /// Rückfrage beim Verlassen – über die Zurück-Taste wie über den Button.
  Future<void> _handleInterrupt(
    BuildContext context,
    SimulationController controller,
    SimulationSession session,
  ) async {
    final isRunning = session.stage == SimulationStage.running;

    final choice = await showDialog<_InterruptChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Simulation verlassen?'),
        content: Text(
          isRunning
              ? 'Die Uhr läuft. Im echten Einstellungstest gibt es weder Pause '
                  'noch Abbruch – beides verfälscht dein Ergebnis.'
              : 'Wenn du jetzt gehst, ist der Durchlauf beendet und wird mit '
                  'den bisherigen Antworten gewertet.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_InterruptChoice.resume),
            child: const Text('Weitermachen'),
          ),
          if (isRunning)
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_InterruptChoice.pause),
              child: const Text('Pausieren'),
            ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_InterruptChoice.abort),
            child: const Text('Abbrechen'),
          ),
        ],
      ),
    );

    switch (choice) {
      case _InterruptChoice.pause:
        controller.pause();
      case _InterruptChoice.abort:
        controller.abort();
      case _InterruptChoice.resume:
      case null:
        break;
    }
  }

  Future<void> _confirmPause(
    BuildContext context,
    SimulationController controller,
  ) async {
    final shouldPause = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Wirklich pausieren?'),
        content: const Text(
          'Im echten Einstellungstest kannst du nicht pausieren. '
          'Die Unterbrechung wird in deiner Auswertung vermerkt, damit du das '
          'Ergebnis richtig einordnen kannst.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Weitermachen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Trotzdem pausieren'),
          ),
        ],
      ),
    );

    if (shouldPause ?? false) controller.pause();
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
            child: const Text('Zurück'),
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

/// Briefing vor einem Testteil – hier läuft die Uhr noch nicht.
class _BriefingView extends StatelessWidget {
  const _BriefingView({
    required this.session,
    required this.onStart,
    required this.onLeave,
  });

  final SimulationSession session;
  final VoidCallback onStart;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final part = session.currentPartSpec;
    final partNumber = session.partIndex + 1;
    final totalParts = session.loadedParts.length;
    final isFirst = session.partIndex == 0;
    // Der Probelauf besteht aus einem einzigen Teil – dann waere „Teil 1 von
    // 1" nur Buchhaltung.
    final isSinglePart = totalParts == 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(session.blueprint.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Simulation verlassen',
          onPressed: onLeave,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isFirst)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.08),
                    borderRadius: Radii.bandRadius,
                  ),
                  child: Text(
                    '${isSinglePart ? 'Ein Testteil' : '$totalParts Testteile'}, '
                    '${session.blueprint.totalDuration.inMinutes} Minuten, '
                    '${session.blueprint.totalQuestions} Aufgaben. '
                    'Keine Lösungen, keine Zwischenergebnisse – '
                    'die Auswertung kommt erst ganz am Ende.',
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.tokens.correct.withValues(alpha: 0.10),
                    borderRadius: Radii.bandRadius,
                  ),
                  child: Text(
                    'Teil ${session.partIndex} abgeschlossen. '
                    'Kurz durchatmen – dann geht es weiter.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.tokens.logic.deep,
                    ),
                  ),
                ),
              if (!isSinglePart) ...[
                Text(
                  'Teil $partNumber von $totalParts',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Text(
                isSinglePart ? session.blueprint.title : part.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: Radii.bandRadius,
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
                    const Divider(height: 20),
                    _BriefingRow(
                      icon: Icons.category_outlined,
                      label: 'Bereiche',
                      value: part.moduleLabel,
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
                child: Text(
                  isFirst ? 'Teil starten' : 'Nächsten Teil starten',
                ),
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
    required this.onSelectOption,
    required this.onSubmitNumber,
    required this.onSkip,
    required this.onPause,
    required this.onLeave,
  });

  final SimulationSession session;
  final ValueChanged<int> onSelectOption;
  final bool Function(String input) onSubmitNumber;
  final VoidCallback onSkip;
  final VoidCallback onPause;
  final VoidCallback onLeave;

  /// Je nach Antwortformat der Aufgabe: Optionsliste oder Zahleneingabe.
  /// In der Simulation gibt es kein Feedback – die Lösung bleibt verdeckt.
  List<Widget> _buildAnswerArea() {
    final question = session.currentQuestion;

    return switch (question.answer) {
      final MultipleChoice format => [
          for (var index = 0; index < format.options.length; index++)
            AnswerOptionTile(
              label: String.fromCharCode(65 + index),
              text: format.options[index],
              state: session.selectedOptionIndex == index
                  ? AnswerOptionState.selected
                  : AnswerOptionState.idle,
              onTap: () => onSelectOption(index),
            ),
        ],
      final NumericInput format => [
          NumericAnswerField(
            key: ValueKey(
              '${session.partIndex}_${session.questionIndex}_${question.id}',
            ),
            format: format,
            onSubmit: onSubmitNumber,
          ),
        ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = session.currentQuestion;
    final part = session.currentPartSpec;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          session.loadedParts.length == 1
              ? session.blueprint.title
              : 'Teil ${session.partIndex + 1}: ${part.moduleLabel}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.pause_circle_outline),
            tooltip: 'Pausieren',
            onPressed: onPause,
          ),
          TextButton(
            onPressed: onLeave,
            child: const Text('Beenden'),
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
                  if (session.loadedParts.length > 1)
                    Text(
                      'Teil ${session.partIndex + 1}/'
                      '${session.loadedParts.length}',
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
                  ..._buildAnswerArea(),
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

/// Unterbrochene Simulation – bewusst unbequem gestaltet.
class _PausedView extends StatelessWidget {
  const _PausedView({
    required this.session,
    required this.onResume,
    required this.onAbort,
  });

  final SimulationSession session;
  final VoidCallback onResume;
  final VoidCallback onAbort;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.pause_circle_outline,
                size: 56,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 18),
              Text(
                'Simulation pausiert',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Im echten Einstellungstest gibt es diese Möglichkeit nicht. '
                'Deine Auswertung vermerkt die Unterbrechung, damit du das '
                'Ergebnis richtig einordnen kannst.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: Radii.bandRadius,
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    _BriefingRow(
                      icon: Icons.flag_outlined,
                      label: 'Aktueller Teil',
                      value: '${session.partIndex + 1} '
                          'von ${session.loadedParts.length}',
                    ),
                    const Divider(height: 20),
                    _BriefingRow(
                      icon: Icons.schedule_outlined,
                      label: 'Restzeit im Teil',
                      value: formatMmSs(session.remainingSeconds),
                    ),
                    const Divider(height: 20),
                    _BriefingRow(
                      icon: Icons.pause_outlined,
                      label: 'Unterbrechungen',
                      value: '${session.pauseCount}',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: onResume,
                child: const Text('Weiter im Test'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: onAbort,
                child: const Text('Simulation abbrechen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
