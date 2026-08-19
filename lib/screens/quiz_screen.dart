import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/quiz_session.dart';
import 'package:einstellungstest_trainer/screens/result_screen.dart';
import 'package:einstellungstest_trainer/services/quiz_controller.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:einstellungstest_trainer/widgets/ad_banner_slot.dart';
import 'package:einstellungstest_trainer/widgets/answer_option_tile.dart';
import 'package:einstellungstest_trainer/widgets/feedback_sheet.dart';
import 'package:einstellungstest_trainer/widgets/numeric_answer_field.dart';
import 'package:einstellungstest_trainer/widgets/question_card.dart';
import 'package:einstellungstest_trainer/widgets/timer_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Gemeinsamer Screen für Übungs- und Sprint-Modus.
///
/// Die beiden Modi unterscheiden sich nur in Details (Countdown, sofortiges
/// Feedback), teilen sich aber Aufbau und Bedienung – deshalb ein Screen statt
/// zwei fast identischer Kopien.
class QuizScreen extends ConsumerWidget {
  const QuizScreen({
    super.key,
    required this.mode,
    required this.scope,
    this.length = QuizController.defaultPracticeLength,
    this.difficulty,
  });

  final SessionMode mode;
  final PracticeScope scope;

  /// Nur für den Übungsmodus relevant.
  final int length;

  /// Nur im Uebungsmodus gesetzt und nur mit Pro waehlbar.
  final Difficulty? difficulty;

  QuizConfig get _config =>
      (mode: mode, scope: scope, length: length, difficulty: difficulty);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(quizControllerProvider(_config));
    final controller = ref.read(quizControllerProvider(_config).notifier);

    if (session.status == SessionStatus.finished) {
      final summary = session.summary;
      if (summary != null) {
        return QuizResultScreen(
          mode: mode,
          scopeLabel: scope.label,
          summary: summary,
          answers: session.answers,
          previousSprintBest: session.previousSprintBest,
          onRetry: () => ref.invalidate(quizControllerProvider(_config)),
        );
      }
    }

    if (session.questions.isEmpty) {
      return _EmptyPool(scopeLabel: scope.label);
    }

    final tokens = context.tokens;
    final question = session.currentQuestion;
    final isSprint = mode == SessionMode.sprint;
    final palette = tokens.paletteOf(question.module.id);
    final side = Gap.screenPadding(MediaQuery.sizeOf(context).width);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(side, 0, side, Gap.sm),
              child: _Header(
                accent: palette.accent,
                modeLabel: isSprint ? 'Sprint' : 'Üben',
                progressLabel: isSprint
                    ? '${session.answers.length} bearbeitet'
                    : 'Aufgabe ${session.currentNumber}/'
                        '${session.totalQuestions}',
                progress: isSprint
                    ? 1 -
                        ((session.remainingSeconds ?? 0) /
                            QuizController.sprintSeconds)
                    : session.progress,
                remainingSeconds: isSprint ? session.remainingSeconds : null,
                onQuit: () => _confirmExit(context, controller),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(side, Gap.sm, side, Gap.card),
                children: [
                  QuestionCard(question: question),
                  const SizedBox(height: Gap.cardWide),
                  ..._buildAnswerArea(session, controller, palette),
                ],
              ),
            ),
            // Die Rückmeldung nimmt den Platz des Knopfes ein und fährt von
            // unten hoch. Die Aufgabe bleibt darüber stehen.
            if (session.revealed)
              FeedbackSheet(
                isCorrect:
                    session.answers.isNotEmpty && session.answers.last.isCorrect,
                explanation: question.explanation,
                isLast: session.isLastQuestion,
                onNext: controller.next,
              )
            else
              Padding(
                padding: EdgeInsets.fromLTRB(side, Gap.xs, side, Gap.md),
                child: OutlinedButton(
                  onPressed: controller.skip,
                  child: Text(isSprint ? 'Überspringen' : 'Weiß ich nicht'),
                ),
              ),
            // Nur im Uebungsmodus. Im Sprint laeuft eine Uhr - dort waere ein
            // Banner neben dem Countdown gegenueber dem Nutzer unfair.
            if (!isSprint) const AdBannerSlot(),
          ],
        ),
      ),
    );
  }

  /// Je nach Antwortformat der Aufgabe: Optionsliste oder Zahleneingabe.
  List<Widget> _buildAnswerArea(
    QuizSession session,
    QuizController controller,
    ModulePalette palette,
  ) {
    final question = session.currentQuestion;

    switch (question.answer) {
      case final MultipleChoice format:
        return [
          for (var index = 0; index < format.options.length; index++)
            AnswerOptionTile(
              label: String.fromCharCode(65 + index),
              text: format.options[index],
              accent: palette,
              state: _optionState(session, format, index),
              onTap:
                  session.revealed ? null : () => controller.selectOption(index),
            ),
        ];

      case final NumericInput format:
        if (session.revealed) {
          final record = session.answers.last;
          return [
            NumericAnswerSummary(
              format: format,
              givenText: record.responseText,
              isCorrect: record.isCorrect,
            ),
          ];
        }
        return [
          NumericAnswerField(
            // Neuer Key je Aufgabe, damit das Feld beim Weiterschalten leert.
            key: ValueKey('${session.currentIndex}_${question.id}'),
            format: format,
            onSubmit: controller.submitNumber,
          ),
        ];
    }
  }

  AnswerOptionState _optionState(
    QuizSession session,
    MultipleChoice format,
    int index,
  ) {
    if (!session.revealed) {
      return session.selectedOptionIndex == index
          ? AnswerOptionState.selected
          : AnswerOptionState.idle;
    }
    if (index == format.correctIndex) return AnswerOptionState.correct;
    if (index == session.selectedOptionIndex) return AnswerOptionState.wrong;
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
          'Dein bisheriger Fortschritt wird gewertet und du siehst die '
          'Auswertung.',
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

/// Die Kopfzeile einer laufenden Runde: Abbruch, Modus, Fortschritt, Uhr.
class _Header extends StatelessWidget {
  const _Header({
    required this.accent,
    required this.modeLabel,
    required this.progressLabel,
    required this.progress,
    required this.remainingSeconds,
    required this.onQuit,
  });

  final Color accent;
  final String modeLabel;
  final String progressLabel;
  final double progress;
  final int? remainingSeconds;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return SizedBox(
      height: 60,
      child: Row(
        children: [
          IconButton(
            onPressed: onQuit,
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Runde beenden',
          ),
          const SizedBox(width: Gap.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      modeLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: Gap.sm),
                    Expanded(
                      child: Text(
                        progressLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(Radii.pill),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    minHeight: 4,
                    backgroundColor: tokens.sunk,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
              ],
            ),
          ),
          if (remainingSeconds != null) ...[
            const SizedBox(width: Gap.md),
            TimerPill(remainingSeconds: remainingSeconds!),
          ],
        ],
      ),
    );
  }
}

/// Fällt nur an, wenn ein Thema wider Erwarten keine Aufgaben liefert.
class _EmptyPool extends StatelessWidget {
  const _EmptyPool({required this.scopeLabel});

  final String scopeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Üben')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 44,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: Gap.card),
              Text(
                'Für "$scopeLabel" liegen derzeit keine Aufgaben vor.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: Gap.cardWide),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Andere Auswahl treffen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
