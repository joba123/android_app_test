import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';

/// Ein Balken je Aufgabe: Höhe ist die gebrauchte Zeit, Farbe das Ergebnis.
class TimeBar {
  const TimeBar({required this.seconds, required this.correct});

  final int seconds;
  final bool correct;
}

/// „Zeit pro Aufgabe" – die Verteilung einer Runde auf einen Blick.
///
/// Der Wert liegt im Muster, nicht in der einzelnen Zahl: Wo ein Balken weit
/// heraussteht, hat eine Aufgabe aufgehalten. Deshalb ohne Achsenbeschriftung,
/// aber mit dem längsten Wert als Bezugspunkt.
class TimePerQuestionChart extends StatelessWidget {
  const TimePerQuestionChart({super.key, required this.bars});

  final List<TimeBar> bars;

  static const double chartHeight = 96;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    if (bars.isEmpty) return const SizedBox.shrink();

    final longest = bars
        .map((bar) => bar.seconds)
        .reduce((value, element) => value > element ? value : element);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: chartHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var index = 0; index < bars.length; index++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == bars.length - 1 ? 0 : 3,
                    ),
                    child: Container(
                      // Auch die kürzeste Aufgabe bleibt sichtbar.
                      height: longest == 0
                          ? 6
                          : 6 +
                              (chartHeight - 6) *
                                  (bars[index].seconds / longest),
                      decoration: BoxDecoration(
                        color: bars[index].correct
                            ? tokens.correct
                            : tokens.wrong,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: Gap.sm),
        Row(
          children: [
            _LegendDot(color: tokens.correct, label: 'richtig'),
            const SizedBox(width: Gap.card),
            _LegendDot(color: tokens.wrong, label: 'falsch'),
            const Spacer(),
            Text(
              'längste $longest s',
              style: NumText.inline.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
