import 'package:einstellungstest_trainer/models/progress_trend.dart';
import 'package:flutter/material.dart';

/// Trefferquote je Woche als Balken.
///
/// Eine einzelne Messreihe über die Zeit – deshalb **eine** Farbe statt einer
/// Palette und keine Legende: Die Überschrift benennt, was gezeigt wird.
///
/// Wochen ohne Übung bleiben als leerer Platzhalter stehen. Eine Lücke ist
/// eine Aussage; sie zu überspringen würde den Verlauf schöner aussehen
/// lassen, als er war.
class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.points,
    this.height = 132,
  });

  final List<TrendPoint> points;
  final double height;

  /// Balken unter dieser Antwortzahl gelten als nicht aussagekräftig und
  /// werden gedämpft dargestellt – eine Quote aus zwei Aufgaben ist Zufall.
  static const int _meaningful = ProgressTrend.minimumAnswersPerPeriod;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Bezugspunkt der Balkenhöhe. Bei durchweg hohen Quoten waere eine
    // 0–100-Skala flach und nichtssagend, deshalb wird nach oben gedehnt –
    // aber nie unter 100 %, damit kein Balken die Skala sprengt.
    final best = points
        .where((point) => point.answered >= _meaningful)
        .fold<double>(0, (max, point) => point.accuracy > max ? point.accuracy : max);
    final scale = best <= 0 ? 1.0 : best;

    // Nur der jüngste aussagekräftige Balken wird beschriftet. Eine Zahl über
    // jedem Balken waere Rauschen.
    final labelledIndex = points.lastIndexWhere(
      (point) => point.answered >= _meaningful,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var index = 0; index < points.length; index++) ...[
                if (index > 0) const SizedBox(width: 4),
                Expanded(
                  child: _Bar(
                    point: points[index],
                    scale: scale,
                    showValue: index == labelledIndex,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var index = 0; index < points.length; index++) ...[
              if (index > 0) const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _weekLabel(points[index], isLast: index == points.length - 1),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _weekLabel(TrendPoint point, {required bool isLast}) {
    if (isLast) return 'jetzt';
    return '${point.start.day}.${point.start.month}.';
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.point,
    required this.scale,
    required this.showValue,
  });

  final TrendPoint point;
  final double scale;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meaningful = point.answered >= TrendChart._meaningful;

    // Ohne Daten bleibt ein flacher Stummel stehen, damit die Woche sichtbar
    // bleibt, statt einfach zu fehlen.
    final fraction = meaningful ? (point.accuracy / scale).clamp(0.06, 1.0) : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showValue) ...[
          Text(
            '${(point.accuracy * 100).round()} %',
            style: theme.textTheme.labelSmall?.copyWith(
              // Zahlen tragen Text-Farben, nicht die Farbe des Balkens.
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 3),
        ],
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barHeight = meaningful
                  ? constraints.maxHeight * fraction
                  : 3.0;

              return Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: meaningful
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                    // Abgerundetes Ende oben, an der Grundlinie verankert.
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
