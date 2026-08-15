import 'package:einstellungstest_trainer/models/answer_record.dart';
import 'package:einstellungstest_trainer/models/quiz_session.dart';
import 'package:einstellungstest_trainer/models/simulation.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/widgets/stat_tile.dart';
import 'package:flutter/material.dart';

/// Auswertung einer Uebungs- oder Sprint-Runde.
class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    super.key,
    required this.mode,
    required this.module,
    required this.answers,
    required this.onRetry,
  });

  final SessionMode mode;
  final TrainingModule module;
  final List<AnswerRecord> answers;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final correct = answers.where((answer) => answer.isCorrect).length;
    final answered = answers.where((answer) => answer.isAnswered).length;
    final accuracy = answered == 0 ? 0.0 : correct / answered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auswertung'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _ResultHeadline(
              title: mode == SessionMode.sprint
                  ? '$correct richtig in 60 Sekunden'
                  : 'Runde abgeschlossen',
              subtitle: '${module.label} · ${mode.label}',
              accuracy: accuracy,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    value: '$correct',
                    label: 'richtig',
                    icon: Icons.check_circle_outline,
                    color: const Color(0xFF0E9F6E),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    value: '${answered - correct}',
                    label: 'falsch',
                    icon: Icons.cancel_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    value: '${answers.length - answered}',
                    label: 'offen',
                    icon: Icons.remove_circle_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Text(
              'Aufgaben im Überblick',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            for (var index = 0; index < answers.length; index++)
              _AnswerReviewTile(number: index + 1, record: answers[index]),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Noch eine Runde'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zurück zum Modul'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Auswertung einer kompletten Testsimulation, aufgeschluesselt nach Teilen.
class SimulationResultScreen extends StatelessWidget {
  const SimulationResultScreen({
    super.key,
    required this.session,
    required this.onRetry,
  });

  final SimulationSession session;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = session.partResults;
    final total = session.answers.length;
    final correct = session.correctCount;
    final accuracy = total == 0 ? 0.0 : correct / total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Testergebnis'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _ResultHeadline(
              title: '$correct von $total richtig',
              subtitle: session.blueprint.title,
              accuracy: accuracy,
            ),
            const SizedBox(height: 22),
            Text(
              'Ergebnis nach Testteilen',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (final result in results) _PartResultCard(result: result),
            const SizedBox(height: 22),
            Text(
              'Alle Aufgaben',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            for (var index = 0; index < session.answers.length; index++)
              _AnswerReviewTile(
                number: index + 1,
                record: session.answers[index],
              ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Simulation wiederholen'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zurück'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultHeadline extends StatelessWidget {
  const _ResultHeadline({
    required this.title,
    required this.subtitle,
    required this.accuracy,
  });

  final String title;
  final String subtitle;
  final double accuracy;

  /// Kurze Einordnung des Ergebnisses - bewusst sachlich, ohne Übertreibung.
  String get _verdict {
    if (accuracy >= 0.9) return 'Sehr starkes Ergebnis. Weiter so.';
    if (accuracy >= 0.75) return 'Solide Leistung – der Kurs stimmt.';
    if (accuracy >= 0.5) return 'Grundlagen sitzen, die Feinheiten fehlen noch.';
    return 'Hier lohnt sich der Übungsmodus mit Erklärungen.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: accuracy,
              minHeight: 8,
              backgroundColor:
                  theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(accuracy * 100).round()} % Trefferquote · $_verdict',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _PartResultCard extends StatelessWidget {
  const _PartResultCard({required this.result});

  final PartResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  result.part.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${result.correctCount}/${result.total}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: result.part.module.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: result.accuracy,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor:
                  AlwaysStoppedAnimation<Color>(result.part.module.color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Aufklappbare Zeile mit Aufgabe, gegebener Antwort und Erklaerung.
class _AnswerReviewTile extends StatelessWidget {
  const _AnswerReviewTile({required this.number, required this.record});

  final int number;
  final AnswerRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = record.question;

    final (Color color, IconData icon, String status) = switch (record) {
      _ when record.isCorrect => (
          const Color(0xFF0E9F6E),
          Icons.check_circle,
          'Richtig',
        ),
      _ when !record.isAnswered => (
          theme.colorScheme.outline,
          Icons.remove_circle,
          'Nicht bearbeitet',
        ),
      _ => (theme.colorScheme.error, Icons.cancel, 'Falsch'),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 14),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        leading: Icon(icon, color: color),
        title: Text(
          'Aufgabe $number',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '${question.topic} · $status',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              question.prompt,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ),
          const SizedBox(height: 10),
          _ReviewLine(
            label: 'Deine Antwort',
            value: record.isAnswered
                ? question.options[record.selectedIndex!]
                : '—',
            color: record.isCorrect ? const Color(0xFF0E9F6E) : color,
          ),
          const SizedBox(height: 4),
          _ReviewLine(
            label: 'Richtige Antwort',
            value: question.correctAnswer,
            color: const Color(0xFF0E9F6E),
          ),
          const SizedBox(height: 10),
          Text(
            question.explanation,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewLine extends StatelessWidget {
  const _ReviewLine({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
