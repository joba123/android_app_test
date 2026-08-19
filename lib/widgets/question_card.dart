import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';

/// Die Aufgabe selbst: Thema als Beschriftung, darunter die Frage.
///
/// Bewusst ohne Chips für Schwierigkeit und Antwortformat – beides sieht man
/// an der Aufgabe, und beides lenkt vom Lesen ab.
class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key, required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: tokens.raised,
        borderRadius: Radii.cardRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.subCategory.label.toUpperCase(),
            style: NumText.kicker.copyWith(color: theme.colorScheme.outline),
          ),
          if (question.imageAsset != null) ...[
            const SizedBox(height: Gap.card),
            ClipRRect(
              borderRadius: Radii.tileRadius,
              child: Image.asset(
                question.imageAsset!,
                fit: BoxFit.contain,
                // Ein fehlendes Asset darf die laufende Runde nicht abbrechen.
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
          const SizedBox(height: Gap.md),
          Text(
            question.prompt,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 20,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
