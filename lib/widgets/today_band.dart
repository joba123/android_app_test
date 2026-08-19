import 'package:einstellungstest_trainer/models/exam_date.dart';
import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';

/// Das Band unter der Begrüßung: was heute ansteht.
///
/// Ein Band, zwei Lesarten. Mit hinterlegtem Termin zählt links die Zahl der
/// Tage – das ist der Grund, aus dem die App überhaupt geöffnet wird. Ohne
/// Termin steht dort, wie viele Aufgaben heute schon geschafft sind. Der
/// Balken zum Tagesziel läuft in beiden Fällen mit, damit das Ziel nicht nur
/// in den Einstellungen existiert.
class TodayBand extends StatelessWidget {
  const TodayBand({
    super.key,
    required this.examDate,
    required this.answeredToday,
    required this.goal,
    required this.onTap,
  });

  final ExamDate? examDate;
  final int answeredToday;
  final int goal;
  final VoidCallback onTap;

  bool get _reached => goal > 0 && answeredToday >= goal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final date = examDate;
    final days = date?.daysUntil(DateTime.now());
    final progress = goal <= 0 ? 0.0 : (answeredToday / goal).clamp(0.0, 1.0);

    final String tileValue;
    final String tileUnit;
    if (date == null) {
      tileValue = '$answeredToday';
      tileUnit = 'AUFG.';
    } else if (days! < 0) {
      tileValue = '–';
      tileUnit = 'TAGE';
    } else {
      tileValue = '$days';
      tileUnit = days == 1 ? 'TAG' : 'TAGE';
    }

    final String title;
    if (date == null) {
      title = _reached ? 'Tagesziel geschafft' : 'Aufgaben heute';
    } else if (days! < 0) {
      title = 'Termin liegt zurück';
    } else {
      title = 'bis zum Testtermin';
    }

    return Material(
      color: tokens.band,
      borderRadius: Radii.bandRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.bandRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Gap.card,
            vertical: 14,
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: tokens.raised,
                  borderRadius: Radii.tileRadius,
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (date == null && _reached)
                      Icon(Icons.check_rounded, size: 24, color: tokens.correct)
                    else ...[
                      Text(
                        tileValue,
                        style: NumText.band.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tileUnit,
                        style: NumText.unit.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: Gap.card),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: Gap.sm),
                    if (date != null)
                      Text(
                        [
                          _formatDate(date.date),
                          if (date.label != null) date.label!,
                        ].join(' · '),
                        style: theme.textTheme.bodySmall,
                      ),
                    if (date != null) const SizedBox(height: Gap.sm),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Radii.pill),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 5,
                              backgroundColor: tokens.raised,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _reached
                                    ? tokens.correct
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: Gap.sm),
                        Text(
                          '$answeredToday/$goal',
                          style: NumText.inline.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}.'
    '${value.month.toString().padLeft(2, '0')}.${value.year}';
