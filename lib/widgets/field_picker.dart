import 'package:einstellungstest_trainer/models/field_of_study.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';

/// Auswahl der Fachrichtung.
///
/// Eine Liste statt eines Rasters: Die Namen sind unterschiedlich lang, und
/// jede Zeile trägt eine kurze Erläuterung – ohne die wäre „Allgemein" nicht
/// von „Verwaltung" zu unterscheiden.
class FieldPicker extends StatelessWidget {
  const FieldPicker({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final FieldOfStudy selected;
  final ValueChanged<FieldOfStudy> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return Column(
      children: [
        for (final field in FieldOfStudy.values)
          Padding(
            padding: const EdgeInsets.only(bottom: Gap.sm),
            child: Material(
              color: field == selected ? tokens.ink : tokens.raised,
              borderRadius: Radii.bandRadius,
              child: InkWell(
                borderRadius: Radii.bandRadius,
                onTap: () => onSelect(field),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Gap.card,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: Radii.bandRadius,
                    border: Border.all(
                      color: field == selected
                          ? tokens.ink
                          : theme.colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              field.label,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: field == selected
                                    ? tokens.onInk
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              field.description,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: field == selected
                                    ? tokens.onInk.withValues(alpha: 0.7)
                                    : theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (field == selected)
                        Icon(
                          Icons.check_rounded,
                          size: 20,
                          color: tokens.onInk,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
