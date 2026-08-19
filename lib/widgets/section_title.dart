import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';

/// Beschriftung über einem Abschnitt: gesperrt, klein, in Versalien.
///
/// Sie ist eine Marke, kein Satz – deshalb keine Überschrift in Lesegröße,
/// sondern eine Zeile, die man überliest, bis man sie sucht.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;

  /// Optional rechts daneben, etwa „alle" als Verweis auf die volle Liste.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.sm, 0, Gap.sm, Gap.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: NumText.kicker.copyWith(color: theme.colorScheme.outline),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
