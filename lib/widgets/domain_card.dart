import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:einstellungstest_trainer/widgets/module_glyph.dart';
import 'package:flutter/material.dart';

/// Ein Bereich im Hauptmenü.
///
/// Zugeklappt zeigt die Karte nur, wie es um den Bereich steht. Erst beim
/// Antippen fährt aus, wie man ihn übt – so steht die Wahl des Modus dort,
/// wo man den Bereich schon gewählt hat, statt auf einem eigenen
/// Bildschirm.
class DomainCard extends StatelessWidget {
  const DomainCard({
    super.key,
    required this.module,
    required this.subtitle,
    required this.accuracy,
    required this.topicCount,
    required this.expanded,
    required this.onToggle,
    required this.onPractice,
    required this.onSprint,
    required this.onTopics,
  });

  final TrainingModule module;

  /// Umfang und Stand, etwa „142 Aufgaben · 64 % gemeistert".
  final String subtitle;

  /// Füllstand des Balkens, 0 bis 1.
  final double accuracy;

  final int topicCount;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onPractice;
  final VoidCallback onSprint;
  final VoidCallback onTopics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final palette = module.palette(context);

    return Container(
      decoration: BoxDecoration(
        color: tokens.raised,
        borderRadius: Radii.cardRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(Gap.cardWide),
              child: Row(
                children: [
                  ModuleGlyph(module: module),
                  const SizedBox(width: Gap.card),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.menuLabel,
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: Gap.xs),
                        Text(subtitle, style: theme.textTheme.labelMedium
                            ?.copyWith(color: theme.colorScheme.outline)),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: tokens.sunk,
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Der Balken sitzt zwischen Kopf und Modus-Zeilen: Er gehört zum
          // Stand, nicht zur Handlung.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.cardWide),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Radii.pill),
              child: LinearProgressIndicator(
                value: accuracy.clamp(0, 1),
                minHeight: 5,
                backgroundColor: tokens.sunk,
                valueColor: AlwaysStoppedAnimation<Color>(palette.accent),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Gap.cardWide,
                      Gap.card,
                      Gap.cardWide,
                      Gap.cardWide,
                    ),
                    child: Column(
                      children: [
                        _ModeRow(
                          label: 'Üben',
                          hint: 'ohne Zeitdruck',
                          background: palette.accent,
                          foreground: Colors.white,
                          onTap: onPractice,
                        ),
                        const SizedBox(height: Gap.sm),
                        _ModeRow(
                          label: 'Sprint',
                          hint: '60 Sekunden',
                          background: palette.soft,
                          foreground: palette.deep,
                          onTap: onSprint,
                        ),
                        const SizedBox(height: Gap.sm),
                        _ModeRow(
                          label: 'Kategorien',
                          hint: '$topicCount Themen',
                          background: tokens.sunk,
                          foreground: theme.colorScheme.onSurface,
                          hintColor: theme.colorScheme.outline,
                          onTap: onTopics,
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// Eine Modus-Zeile: Name links, Erläuterung rechts, beides in einer Pille.
class _ModeRow extends StatelessWidget {
  const _ModeRow({
    required this.label,
    required this.hint,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.hintColor,
  });

  final String label;
  final String hint;
  final Color background;
  final Color foreground;
  final Color? hintColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: background,
      borderRadius: Radii.buttonRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.buttonRadius,
        child: Container(
          height: Gap.control,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: foreground,
                  ),
                ),
              ),
              Text(
                hint,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: hintColor ?? foreground.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
