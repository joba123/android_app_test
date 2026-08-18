import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';

/// Die Rückmeldung nach einer Antwort – eine Fläche, die von unten hochfährt.
///
/// Sie legt sich nicht über die Aufgabe, sondern schiebt sich darunter: oben
/// bleibt sichtbar, was gefragt war und was angetippt wurde, unten steht das
/// Urteil, der Rechenweg und der Knopf – in dieser Reihenfolge, damit
/// „Weiter" unter dem Daumen liegt.
class FeedbackSheet extends StatelessWidget {
  const FeedbackSheet({
    super.key,
    required this.isCorrect,
    required this.explanation,
    required this.isLast,
    required this.onNext,
  });

  final bool isCorrect;

  /// Der Rechenweg in ein bis zwei Sätzen. Wird länger als die Fläche hoch
  /// ist, lässt er sich in ihr scrollen – die Fläche selbst wächst nicht
  /// weiter, sonst rutscht die Aufgabe aus dem Bild.
  final String explanation;

  /// Steuert nur die Beschriftung des Knopfes.
  final bool isLast;

  final VoidCallback onNext;

  /// Höhe, ab der der Rechenweg gescrollt statt gezeigt wird.
  static const double explanationMaxHeight = 104;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final color = isCorrect ? tokens.correct : tokens.wrong;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1, end: 0),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => FractionalTranslation(
        translation: Offset(0, value),
        child: child,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Radii.surface),
        ),
        child: Container(
          width: double.infinity,
          // Die Fläche ist eingefärbt, aber nicht laut: der Ton entscheidet,
          // die Schrift bleibt lesbar.
          color: Color.alphaBlend(
            color.withValues(alpha: 0.10),
            tokens.raised,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(height: 3, color: color),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Gap.screen,
                  Gap.card,
                  Gap.screen,
                  Gap.card,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        // Häkchen und Kreuz als Symbol, nicht als Zeichen:
                        // der Schriftschnitt der App führt sie nicht.
                        Icon(
                          isCorrect ? Icons.check : Icons.close,
                          size: 26,
                          color: color,
                        ),
                        const SizedBox(width: Gap.sm),
                        Text(
                          isCorrect ? 'Richtig' : 'Falsch',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Gap.sm),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: explanationMaxHeight,
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          explanation,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.45,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Gap.card),
                    FilledButton(
                      onPressed: onNext,
                      child: Text(isLast ? 'Auswertung' : 'Weiter'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
