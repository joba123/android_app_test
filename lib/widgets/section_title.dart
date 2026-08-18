import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';

/// Abschnittsüberschrift: gesperrte Versalien in Mono.
///
/// Kein fetter Fließtext mehr – die Überschrift soll als Beschriftung
/// erkennbar sein und nicht mit dem Inhalt konkurrieren.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});

  final String title;

  /// Kleiner Zusatz rechts, etwa „alle Themen".
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            title.toUpperCase(),
            style: MonoText.kicker.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (trailing != null) ...[
            const Spacer(),
            Text(
              trailing!,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ],
      ),
    );
  }
}
