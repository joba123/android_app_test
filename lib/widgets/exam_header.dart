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
    this.trailing,
  });

  final ExamDate? examDate;
  final VoidCallback onTapDate;

  /// Aktionen oben rechts, etwa Einstellungen und Statistik.
  final Widget? trailing;

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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      date == null
                          ? 'Einstellungstest Trainer'
                          : 'Prüfungstermin · ${_formatDate(date.date)}',
                      style: MonoText.kicker.copyWith(
                        color: tokens.onInk.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: Gap.md),
              if (date == null)
                _NoDate(onTap: onTapDate)
              else
                _Countdown(examDate: date, now: now, onTap: onTapDate),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime value) {
    const months = [
      'Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun',
      'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez',
    ];
    return '${value.day}. ${months[value.month - 1]} ${value.year}';
  }
}

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
          if (examDate.label != null) ...[
            const SizedBox(height: Gap.xs),
            Text(
              examDate.label!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: tokens.onInk.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NoDate extends StatelessWidget {
  const _NoDate({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bereit für den nächsten Test?',
          style: theme.textTheme.headlineSmall?.copyWith(color: tokens.onInk),
        ),
        const SizedBox(height: Gap.sm),
        Text(
          'Trage deinen Prüfungstermin ein – dann siehst du hier, wie viel '
          'Zeit bleibt.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: tokens.onInk.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: Gap.md),
        OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: tokens.onInk,
            side: BorderSide(color: tokens.onInk.withValues(alpha: 0.4)),
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: Gap.card),
          ),
          child: const Text('Termin eintragen'),
        ),
      ],
    );
  }
}
