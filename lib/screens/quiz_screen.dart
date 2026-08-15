import 'package:einstellungstest_trainer/models/quiz_session.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/screens/result_screen.dart';
import 'package:einstellungstest_trainer/services/quiz_controller.dart';
import 'package:einstellungstest_trainer/widgets/answer_option_tile.dart';
import 'package:einstellungstest_trainer/widgets/question_card.dart';
import 'package:einstellungstest_trainer/widgets/timer_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Gemeinsamer Screen fuer Uebungs- und Sprint-Modus.
///
/// Die beiden Modi unterscheiden sich nur in Details (Countdown, sofortiges
/// Feedback), teilen sich aber Aufbau und Bedienung - deshalb ein Screen
/// statt zwei fast identischer Kopien.
class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key, required this.mode, required this.module});

  final SessionMode mode;
  final TrainingModule module;

  QuizConfig get _config => (mode: mode, module: module);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(quizControllerProvider(_config));
    final controller = ref.read(quizControllerProvider(_config).notifier);

    if (session.status == SessionStatus.finished) {
      return QuizResultScreen(
        mode: mode,
        module: module,
        answers: session.answers,
        onRetry: () => ref.invalidate(quizControllerProvider(_config)),
      );
    }

    final theme = Theme.of(context);
    final question = session.currentQuestion;
    final isSprint = mode == SessionMode.sprint;

    return Scaffold(
      appBar: AppBar(
        title: Text('${module.shortLabel} · ${mode.label}'),
        actions: [
          TextButton(
            onPressed: () => _confirmExit(context, controller),
            child: const Text('Beenden'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: isSprint
                  ? TimerBar(
                      remainingSeconds: session.remainingSeconds ?? 0,
                      totalSeconds: QuizController.sprintSeconds,
                      label: 'Sprint läuft',
                    )
                  : _PracticeProgress(session: session),
            ),
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
                      state: _optionState(session, index),
                      onTap: session.revealed
                          ? null
                          : () => controller.answer(index),
                    ),
                  if (session.revealed) ...[
                    const SizedBox(height: 6),
                    ExplanationBox(
                      explanation: question.explanation,
                      isCorrect: session.selectedIndex == question.correctIndex,
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: session.revealed
                  ? FilledButton(
                      onPressed: controller.next,
                      child: Text(
                        session.isLastQuestion ? 'Auswertung' : 'Weiter',
                      ),
                    )
                  : OutlinedButton(
                      onPressed: controller.skip,
                      child: Text(
                        isSprint ? 'Überspringen' : 'Weiß ich nicht',
                      ),
                    ),
            ),
            if (isSprint)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  '${session.correctCount} richtig · '
                  '${session.answers.length} bearbeitet',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  AnswerOptionState _optionState(QuizSession session, int index) {
    if (!session.revealed) {
      return session.selectedIndex == index
          ? AnswerOptionState.selected
          : AnswerOptionState.idle;
    }
    if (index == session.currentQuestion.correctIndex) {
      return AnswerOptionState.correct;
    }
    if (index == session.selectedIndex) return AnswerOptionState.wrong;
    return AnswerOptionState.dimmed;
  }

  Future<void> _confirmExit(
    BuildContext context,
    QuizController controller,
  ) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Runde beenden?'),
        content: const Text(
          'Dein bisheriger Fortschritt wird gewertet und du siehst die Auswertung.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Weitertrainieren'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Beenden'),
          ),
        ],
      ),
    );

    if (shouldExit ?? false) controller.finishEarly();
  }
}

class _PracticeProgress extends StatelessWidget {
  const _PracticeProgress({required this.session});

  final QuizSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aufgabe ${session.currentIndex + 1} von ${session.questions.length}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${session.correctCount} richtig',
              style: theme.textTheme.labelMedium?.copyWith(
                color: const Color(0xFF0E9F6E),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: session.progress,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}
