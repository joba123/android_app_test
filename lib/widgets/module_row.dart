import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';

/// Ein Modul als Datenzeile: Name, Quote, fertig.
///
/// Aus der früheren Karte mit Beschreibung, Umfang und Icon ist eine Zeile
/// geworden. Die Beschreibung stand ohnehin nur da, weil Platz war – wer die
/// Module kennt, braucht sie nicht, und wer sie nicht kennt, lernt sie beim
/// Üben kennen.
class ModuleRow extends StatelessWidget {
  const ModuleRow({
    super.key,
    required this.module,
    required this.accuracy,
    required this.onTap,
  });

  final TrainingModule module;

  /// Trefferquote von 0.0 bis 1.0; 0 heißt "noch nicht geübt".
  final double accuracy;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = module.resolveColor(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: Radii.inputRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Gap.md),
            child: Row(
              children: [
                // Die Modulfarbe als schmale Marke, nicht als Fläche.
                Container(
                  width: 3,
                  height: 22,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Text(
                    module.shortLabel,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                Text(
                  accuracy > 0 ? '${(accuracy * 100).round()} %' : '–',
                  style: MonoText.inline.copyWith(
                    fontSize: 15,
                    color: accuracy > 0
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(width: Gap.md),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
