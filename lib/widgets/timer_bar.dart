import 'package:flutter/material.dart';

/// Formatiert Sekunden als "M:SS" bzw. "MM:SS".
String formatMmSs(int totalSeconds) {
  final safe = totalSeconds < 0 ? 0 : totalSeconds;
  final minutes = safe ~/ 60;
  final seconds = safe % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

/// Kompakte Dauer für die Auswertung: unter einer Minute in Sekunden,
/// darüber als "M:SS min".
String formatShortDuration(Duration duration) {
  final seconds = duration.inSeconds < 0 ? 0 : duration.inSeconds;
  return seconds < 60 ? '$seconds s' : '${formatMmSs(seconds)} min';
}

/// Countdown-Anzeige fuer Sprint und Testsimulation.
///
/// Faerbt sich in den letzten 10 Sekunden warnend ein - das ist der Moment,
/// in dem im echten Test die meisten Fehler passieren.
class TimerBar extends StatelessWidget {
  const TimerBar({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    this.label,
  });

  final int remainingSeconds;
  final int totalSeconds;
  final String? label;

  static const int warningThreshold = 10;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWarning = remainingSeconds <= warningThreshold;
    final color = isWarning ? theme.colorScheme.error : theme.colorScheme.primary;
    final progress = totalSeconds == 0
        ? 0.0
        : (remainingSeconds / totalSeconds).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label ?? 'Verbleibende Zeit',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              formatMmSs(remainingSeconds),
              style: theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
