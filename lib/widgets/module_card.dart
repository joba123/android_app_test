import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';

/// Datenkarte: Haarlinie, Radius 10, kein Schatten.
///
/// Karten bekommt nur, was Daten trägt oder eine Handlung auslöst –
/// Verwaltungskram bleibt eine flache Listenzeile.
class DataCard extends StatelessWidget {
  const DataCard({
    super.key,
    required this.child,
    this.onTap,
    this.accent,
    this.padding = const EdgeInsets.all(Gap.card),
  });

  final Widget child;
  final VoidCallback? onTap;

  /// Modulfarbe als 3-dp-Oberkante. Nie als Flächenfüllung und nie als
  /// linker Akzentstreifen – so bleibt die Farbe eine Datenmarke und wird
  /// nicht zur Dekoration.
  final Color? accent;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (accent != null)
          Container(height: 3, color: accent),
        Padding(padding: padding, child: child),
      ],
    );

    return ClipRRect(
      borderRadius: Radii.cardRadius,
      child: Material(
        color: tokens.raised,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: Radii.cardRadius,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Einstiegskachel fuer ein Trainingsmodul auf der Startseite.
class ModuleCard extends StatelessWidget {
  const ModuleCard({
    super.key,
    required this.module,
    required this.sizeLabel,
    required this.accuracy,
    required this.onTap,
  });

  final TrainingModule module;

  /// Umfang des Moduls als Text – bei generierten Modulen wäre eine Zahl
  /// irreführend.
  final String sizeLabel;

  /// Trefferquote von 0.0 bis 1.0; 0 bedeutet "noch nicht trainiert".
  final double accuracy;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = module.resolveColor(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: DataCard(
        onTap: onTap,
        accent: color,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(module.label, style: theme.textTheme.titleSmall),
                  const SizedBox(height: Gap.xs),
                  Text(
                    module.description,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: Gap.sm),
                  Text(
                    sizeLabel,
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: Gap.md),
            // Die Quote steht in Mono: sie ist ein Messwert.
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  accuracy > 0 ? '${(accuracy * 100).round()} %' : '–',
                  style: MonoText.metric.copyWith(
                    color: accuracy > 0 ? color : theme.colorScheme.outline,
                  ),
                ),
                Text(
                  accuracy > 0 ? 'Quote' : 'kein Ergebnis',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Kachel fuer einen Trainingsmodus (Uebung / Sprint / Simulation).
class ModeCard extends StatelessWidget {
  const ModeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String meta;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: DataCard(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 22),
            const SizedBox(width: Gap.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title, style: theme.textTheme.titleSmall),
                      ),
                      const SizedBox(width: Gap.sm),
                      Text(meta, style: MonoText.inline.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                    ],
                  ),
                  const SizedBox(height: Gap.xs),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
