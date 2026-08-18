import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';

/// Kompakte Kennzahl-Kachel fuer Startseite, Statistik und Auswertung.
///
/// Die Zahl steht in Mono mit Tabellenziffern – sie ist ein Messwert und
/// soll beim Hochzählen nicht zappeln. Farbe trägt sie nur, wenn sie
/// ausdrücklich eine bekommt; sonst bleibt sie Tinte.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.color,
  });

  final String value;
  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return Container(
      padding: const EdgeInsets.all(Gap.card),
      decoration: BoxDecoration(
        color: tokens.raised,
        borderRadius: Radii.cardRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: MonoText.metric.copyWith(
              color: color ?? theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: Gap.xs),
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: Gap.xs),
              ],
              Expanded(
                child: Text(label, style: theme.textTheme.labelSmall),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
