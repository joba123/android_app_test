import 'package:einstellungstest_trainer/models/todays_plan.dart';
import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';

/// Der Tagesvorschlag: Titel, Begründung, höchstens drei Zahlen, ein Knopf.
///
/// Das ist die einzige Stelle der Startseite, die etwas vorschlägt. Sie darf
/// deshalb Platz beanspruchen – alles darunter sind nur noch Zeilen.
class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.plan,
    required this.onStart,
    required this.onOther,
  });

  final TodaysPlan plan;
  final VoidCallback onStart;
  final VoidCallback onOther;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final facts = PlanFacts.of(plan);

    return Container(
      padding: const EdgeInsets.all(Gap.card),
      decoration: BoxDecoration(
        color: tokens.raised,
        borderRadius: Radii.cardRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(plan.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(plan.reasonLabel, style: theme.textTheme.bodySmall),
          const SizedBox(height: Gap.card),
          // Die Zahlen sitzen in einer eingelassenen Rille – sie sind
          // Messwerte, keine Handlung.
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Gap.md,
              vertical: Gap.md,
            ),
            decoration: BoxDecoration(
              color: tokens.sunk,
              borderRadius: Radii.inputRadius,
            ),
            child: Row(
              children: [
                for (var index = 0; index < facts.entries.length; index++) ...[
                  if (index > 0)
                    Container(
                      width: 1,
                      height: 28,
                      color: theme.colorScheme.outlineVariant,
                      margin: const EdgeInsets.symmetric(horizontal: Gap.md),
                    ),
                  Expanded(
                    child: _Fact(
                      value: facts.entries[index].$1,
                      label: facts.entries[index].$2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: Gap.card),
          FilledButton(onPressed: onStart, child: const Text('Los')),
          const SizedBox(height: Gap.xs),
          TextButton(
            onPressed: onOther,
            style: TextButton.styleFrom(minimumSize: const Size.fromHeight(44)),
            child: const Text('anderes Thema'),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: MonoText.inline.copyWith(
            fontSize: 18,
            height: 22 / 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
