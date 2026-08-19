import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
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

/// Der Countdown als Pille in der Kopfzeile.
///
/// Faerbt sich in den letzten zehn Sekunden warnend ein – das ist der
/// Moment, in dem im echten Test die meisten Fehler passieren.
class TimerPill extends StatelessWidget {
  const TimerPill({super.key, required this.remainingSeconds});

  final int remainingSeconds;

  static const int warningThreshold = 10;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final isWarning = remainingSeconds <= warningThreshold;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isWarning ? tokens.wrong : tokens.sunk,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Text(
        formatMmSs(remainingSeconds),
        style: NumText.inline.copyWith(
          fontSize: 15,
          color: isWarning ? Colors.white : theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

/// Der Countdown eines Testteils: Zeile mit Namen, Zeit und Balken.
///
/// In der Simulation steht mehr Zeit auf der Uhr als im Sprint, und der
/// Teil hat einen Namen – deshalb hier die breite Form.
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
    final color =
        isWarning ? theme.colorScheme.error : theme.colorScheme.onSurface;
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
              style: NumText.inline.copyWith(fontSize: 16, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(Radii.pill),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: theme.colorScheme.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
