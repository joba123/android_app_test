import 'package:einstellungstest_trainer/models/question.dart';
import 'package:flutter/material.dart';

/// Zeigt Thema, Schwierigkeit und Aufgabenstellung.
class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key, required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _Chip(
                text: question.subCategory.label,
                color: question.module.color,
              ),
              _Chip(
                text: question.difficulty.label,
                color: theme.colorScheme.outline,
              ),
              if (question.isNumericInput)
                _Chip(
                  text: 'Zahleneingabe',
                  color: theme.colorScheme.tertiary,
                ),
            ],
          ),
          if (question.imageAsset != null) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                question.imageAsset!,
                fit: BoxFit.contain,
                // Ein fehlendes Asset darf die laufende Runde nicht abbrechen.
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            question.prompt,
            style: theme.textTheme.titleMedium?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

/// Erklaerung zur Loesung - nur im Uebungsmodus und in der Auswertung.
class ExplanationBox extends StatelessWidget {
  const ExplanationBox({
    super.key,
    required this.explanation,
    required this.isCorrect,
  });

  final String explanation;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCorrect ? const Color(0xFF0E9F6E) : theme.colorScheme.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_outline : Icons.info_outline,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                isCorrect ? 'Richtig' : 'Erklärung',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}
