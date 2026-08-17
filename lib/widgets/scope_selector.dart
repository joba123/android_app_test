import 'package:einstellungstest_trainer/data/question_pool.dart';
import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:flutter/material.dart';

/// Auswahlliste für einen Übungs- bzw. Sprint-Umfang.
///
/// Wird von Übungs- und Sprint-Einstieg geteilt. Die beiden unterscheiden sich
/// nur darin, ob der Misch-Modus angeboten wird und was in der Unterzeile
/// steht – deshalb [allowMixed] und [subtitleBuilder] statt zweier fast
/// gleicher Listen.
class ScopeSelector extends StatelessWidget {
  const ScopeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.allowMixed = true,
    this.mixedSubtitle = 'Mathematik, Logik und Sprache im Wechsel',
    this.subtitleBuilder,
  });

  final PracticeScope selected;
  final ValueChanged<PracticeScope> onChanged;
  final bool allowMixed;
  final String mixedSubtitle;

  /// Unterzeile je Eintrag. Ohne Angabe wird der Umfang des Pools gezeigt.
  final String Function(PracticeScope scope)? subtitleBuilder;

  String _subtitleFor(PracticeScope scope) {
    final builder = subtitleBuilder;
    if (builder != null) return builder(scope);

    final topic = scope.subCategory;
    if (topic != null) return QuestionPool.describeSubCategorySize(topic);

    final module = scope.module;
    if (module != null) return QuestionPool.describeSize(module);

    return mixedSubtitle;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (allowMixed)
          _ScopeTile(
            title: 'Alle Kategorien gemischt',
            subtitle: _subtitleFor(const PracticeScope.mixed()),
            icon: Icons.shuffle,
            color: theme.colorScheme.primary,
            selected: selected.isMixed,
            onTap: () => onChanged(const PracticeScope.mixed()),
          ),
        for (final module in TrainingModule.values) ...[
          const SizedBox(height: 18),
          Text(
            module.label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: module.color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _ScopeTile(
            title: 'Alle Themen',
            subtitle: _subtitleFor(PracticeScope.module(module)),
            icon: module.icon,
            color: module.color,
            selected:
                selected.module == module && selected.subCategory == null,
            onTap: () => onChanged(PracticeScope.module(module)),
          ),
          for (final subCategory in SubCategory.of(module))
            _ScopeTile(
              title: subCategory.label,
              subtitle: _subtitleFor(PracticeScope.subCategory(subCategory)),
              icon: Icons.subject,
              color: module.color,
              indented: true,
              selected: selected.subCategory == subCategory,
              onTap: () => onChanged(PracticeScope.subCategory(subCategory)),
            ),
        ],
      ],
    );
  }
}

/// Auswählbare Zeile für einen Umfang.
class _ScopeTile extends StatelessWidget {
  const _ScopeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
    this.indented = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final bool indented;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(left: indented ? 16 : 0, bottom: 8),
      child: Material(
        color: selected
            ? color.withValues(alpha: 0.10)
            : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? color : theme.colorScheme.outlineVariant,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.radio_button_checked : icon,
                  size: 20,
                  color: selected ? color : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
