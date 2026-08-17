import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/quiz_session.dart';
import 'package:einstellungstest_trainer/screens/quiz_screen.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Der Einstieg in die Wiederholung – auf der Startseite, direkt unter dem
/// Countdown.
///
/// Erscheint nur, wenn es tatsächlich etwas zu wiederholen gibt. Eine Karte,
/// die „0 Aufgaben warten" meldet, wäre nur Platzverbrauch; und wer noch nie
/// geübt hat, soll nicht auf seine Fehler hingewiesen werden.
class ReviewCard extends ConsumerWidget {
  const ReviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final book = ref.watch(reviewBookProvider);
    final due = ref.watch(dueReviewCountProvider);
    final weakest = book.weakestTopic;

    if (due == 0 && weakest == null) return const SizedBox.shrink();

    final subtitle = _subtitle(due: due, weakestLabel: weakest?.subCategory
        .label, accuracy: weakest?.accuracy);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const QuizScreen(
                mode: SessionMode.practice,
                scope: PracticeScope.review(),
                length: 10,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.refresh,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deine Fehler wiederholen',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer
                              .withValues(alpha: 0.85),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Nennt konkret, was ansteht – eine Zahl und ein Thema sagen mehr als
  /// „Zeit zum Wiederholen".
  String _subtitle({
    required int due,
    required String? weakestLabel,
    required double? accuracy,
  }) {
    final parts = <String>[];

    if (due == 1) {
      parts.add('1 Aufgabe steht an');
    } else if (due > 1) {
      parts.add('$due Aufgaben stehen an');
    }

    if (weakestLabel != null && accuracy != null) {
      parts.add('$weakestLabel liegt bei ${(accuracy * 100).round()} %');
    }

    return parts.join(' · ');
  }
}
