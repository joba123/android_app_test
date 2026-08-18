import 'package:einstellungstest_trainer/models/exam_date.dart';
import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';

/// Die dunkle Kopffläche der Startseite.
///
/// Wer einen Prüfungstermin hinterlegt hat, öffnet die App wegen des
/// Countdowns – deshalb sitzt er hier oben in der Tinte und nicht in einer
/// Karte unter anderen. Ohne Termin trägt die Fläche stattdessen die
/// Einladung, einen zu setzen.
class ExamHeader extends StatelessWidget {
  const ExamHeader({
    super.key,
    required this.examDate,
    required this.onTapDate,
    this.accuracy,
    this.answered = 0,
    this.streak = 0,
  });

  final ExamDate? examDate;
  final VoidCallback onTapDate;

  /// Gesamtquote, `null` solange nichts geuebt wurde.
  final double? accuracy;
  final int answered;

  /// Uebungstage in Folge – tritt an die Stelle des Countdowns, wenn kein
  /// Termin hinterlegt ist.
  final int streak;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final date = examDate;
    final now = DateTime.now();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: tokens.ink,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(Radii.surface),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Gap.screen,
            Gap.card,
            Gap.screen,
            Gap.header,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // Versalien wie bei allen Abschnittsbeschriftungen – der
                // Kicker ist eine Beschriftung, kein Satz.
                (date == null ? 'Deine Übung' : 'Bis zur Prüfung')
                    .toUpperCase(),
                style: MonoText.kicker.copyWith(
                  color: tokens.onInk.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: Gap.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: date == null
                        ? _Streak(days: streak, onTap: onTapDate)
                        : _Countdown(
                            examDate: date,
                            now: now,
                            onTap: onTapDate,
                          ),
                  ),
                  if (answered > 0) _Quota(accuracy: accuracy, answered: answered),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}.'
    '${value.month.toString().padLeft(2, '0')}.${value.year}';

class _Countdown extends StatelessWidget {
  const _Countdown({
    required this.examDate,
    required this.now,
    required this.onTap,
  });

  final ExamDate examDate;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final days = examDate.daysUntil(now);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Die Zahl steht in Mono, das Wort daneben in Prosa.
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (days >= 0) ...[
                Text(
                  '$days',
                  style: MonoText.display.copyWith(color: tokens.onInk),
                ),
                const SizedBox(width: Gap.sm),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    days == 1 ? 'Tag' : 'Tage',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: tokens.onInk.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ] else
                Text(
                  'Termin liegt zurück',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: tokens.onInk,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            [
              _date(examDate.date),
              if (examDate.label != null) examDate.label!,
            ].join(' · '),
            style: theme.textTheme.labelSmall?.copyWith(
              color: tokens.onInk.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ohne Termin zaehlt die Serie – auch ohne Pruefungsdruck ein Grund,
/// wiederzukommen.
class _Streak extends StatelessWidget {
  const _Streak({required this.days, required this.onTap});

  final int days;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    if (days == 0) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Text(
          'Leg los',
          style: theme.textTheme.headlineSmall?.copyWith(color: tokens.onInk),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text('$days', style: MonoText.display.copyWith(color: tokens.onInk)),
        const SizedBox(width: Gap.sm),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            days == 1 ? 'Tag in Folge' : 'Tage in Folge',
            style: theme.textTheme.titleMedium?.copyWith(
              color: tokens.onInk.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}

/// Die Gesamtquote rechts in der Kopfflaeche – zwei Zeilen, keine Kachel.
class _Quota extends StatelessWidget {
  const _Quota({required this.accuracy, required this.answered});

  final double? accuracy;
  final int answered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          accuracy == null ? '–' : '${(accuracy! * 100).round()} %',
          style: MonoText.metric.copyWith(color: tokens.onInk),
        ),
        Text(
          'Quote · $answered Aufg.',
          style: theme.textTheme.labelSmall?.copyWith(
            color: tokens.onInk.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
