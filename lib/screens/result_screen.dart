import 'package:einstellungstest_trainer/models/answer_record.dart';
import 'package:einstellungstest_trainer/models/quiz_session.dart';
import 'package:einstellungstest_trainer/models/simulation.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';
import 'package:einstellungstest_trainer/services/quiz_controller.dart';
import 'package:einstellungstest_trainer/widgets/stat_tile.dart';
import 'package:einstellungstest_trainer/widgets/timer_bar.dart';
import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:einstellungstest_trainer/widgets/section_title.dart';
import 'package:einstellungstest_trainer/widgets/time_chart.dart';
import 'package:flutter/material.dart';

/// Auswertung einer Übungs- oder Sprint-Runde.
///
/// Die Kennzahlen kommen aus der [TrainingSession], die der Controller beim
/// Abschluss gebaut hat. Für die Aufgabendurchsicht braucht es zusätzlich die
/// [AnswerRecord]s, weil nur sie die vollständigen Aufgaben kennen.
class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    super.key,
    required this.mode,
    required this.scopeLabel,
    required this.summary,
    required this.answers,
    required this.onRetry,
    this.previousSprintBest = 0,
  });

  final SessionMode mode;
  final String scopeLabel;
  final TrainingSession summary;
  final List<AnswerRecord> answers;
  final VoidCallback onRetry;

  /// Bestwert für diesen Aufgabentyp vor der Runde – nur im Sprint relevant.
  final int previousSprintBest;

  bool get _isSprint => mode == SessionMode.sprint;

  bool get _isNewBest =>
      _isSprint && summary.correctCount > previousSprintBest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final byTopic = summary.resultsBySubCategory;
    final side = Gap.screenPadding(MediaQuery.sizeOf(context).width);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(side, 0, side, 0),
              child: SizedBox(
                height: 60,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Zurück',
                    ),
                    const SizedBox(width: Gap.sm),
                    Expanded(
                      child: Text(
                        '${mode.label} abgeschlossen',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(side, Gap.sm, side, Gap.header),
                children: [
                  // Die Trefferquote ist die eine Zahl, auf die alle
                  // schauen – deshalb steht sie allein und gross.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Gap.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${(summary.accuracy * 100).round()} %',
                          style: NumText.display.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: Gap.xs),
                        Text(
                          _isSprint
                              ? '${summary.correctCount} richtig in '
                                  '${QuizController.sprintSeconds} Sekunden · '
                                  '$scopeLabel'
                              : '${summary.correctCount} von ${summary.total} '
                                  'richtig · $scopeLabel',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (_isSprint) ...[
                    const SizedBox(height: Gap.card),
                    _SprintRecordBanner(
                      score: summary.correctCount,
                      previousBest: previousSprintBest,
                      isNewBest: _isNewBest,
                    ),
                  ],
                  const SizedBox(height: Gap.cardWide),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Gap.card,
                      vertical: Gap.card,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.sunk,
                      borderRadius: Radii.bandRadius,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _Fact(
                            value: '${((1 - summary.accuracy) * 100).round()} %',
                            label: 'Fehlerquote',
                          ),
                        ),
                        Expanded(
                          child: _Fact(
                            value: formatShortDuration(
                              summary.averageTimePerQuestion,
                            ),
                            label: 'Ø pro Aufgabe',
                          ),
                        ),
                        Expanded(
                          child: _Fact(
                            value: formatShortDuration(summary.duration),
                            label: 'Gesamtzeit',
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (answers.isNotEmpty) ...[
                    const SizedBox(height: Gap.section),
                    const SectionTitle('Zeit pro Aufgabe'),
                    TimePerQuestionChart(
                      bars: [
                        for (final record in answers)
                          TimeBar(
                            seconds: record.timeSpent.inSeconds,
                            correct: record.isCorrect,
                          ),
                      ],
                    ),
                  ],
                  if (byTopic.length > 1) ...[
                    const SizedBox(height: Gap.section),
                    const SectionTitle('Nach Thema'),
                    for (final entry in byTopic.entries)
                      _TopicRow(subCategory: entry.key, results: entry.value),
                  ],
                  const SizedBox(height: Gap.section),
                  const SectionTitle('Aufgaben im Überblick'),
                  for (var index = 0; index < answers.length; index++)
                    _AnswerReviewTile(number: index + 1, record: answers[index]),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(side, Gap.sm, side, Gap.md),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Zum Menü'),
                    ),
                  ),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: onRetry,
                      child: const Text('Nochmal'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Eine Kennzahl in der Rille unter der Trefferquote.
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
          style: NumText.metric.copyWith(
            fontSize: 19,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

/// Auswertung einer kompletten Testsimulation.
///
/// Erst hier bekommt der Nutzer überhaupt Zahlen zu sehen – während des Laufs
/// gibt es bewusst keinerlei Rückmeldung.
class SimulationResultScreen extends StatelessWidget {
  const SimulationResultScreen({
    super.key,
    required this.session,
    required this.summary,
    required this.onRetry,
  });

  final SimulationSession session;
  final TrainingSession summary;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final byModule = summary.resultsByModule;
    final byTopic = summary.resultsBySubCategory;

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
              title: '${summary.correctCount} von ${summary.total} richtig',
              subtitle: session.blueprint.title,
              accuracy: summary.accuracy,
            ),
            if (session.wasPaused) ...[
              const SizedBox(height: 12),
              _PauseNotice(
                pauseCount: session.pauseCount,
                pausedDuration: session.pausedDuration,
              ),
            ],
            const SizedBox(height: 18),

            // --- Gesamtergebnis ---
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    value: '${((1 - summary.accuracy) * 100).round()} %',
                    label: 'Fehlerquote',
                    icon: Icons.percent,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    value: formatShortDuration(summary.averageTimePerQuestion),
                    label: 'Ø pro Aufgabe',
                    icon: Icons.speed_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    value: '${summary.skippedCount}',
                    label: 'nicht bearbeitet',
                    icon: Icons.remove_circle_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Nicht bearbeitete Aufgaben zählen als Fehler – im echten Test '
              'ist das nicht anders.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            // --- Fehlerquote pro Kategorie ---
            const SizedBox(height: 26),
            Text(
              'Fehlerquote nach Kategorie',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (final entry in byModule.entries)
              _CategoryRow(module: entry.key, results: entry.value),

            // --- Aufschlüsselung nach Thema ---
            if (byTopic.length > 1) ...[
              const SizedBox(height: 22),
              Text(
                'Im Detail nach Thema',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              for (final entry in byTopic.entries)
                _TopicRow(subCategory: entry.key, results: entry.value),
            ],

            // --- Ergebnis je Testteil ---
            const SizedBox(height: 22),
            Text(
              'Ergebnis nach Testteilen',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (final result in session.partResults)
              _PartResultCard(result: result),

            // --- Aufgabendurchsicht ---
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

/// Vermerk über Unterbrechungen – ohne den wäre das Ergebnis nicht mit einem
/// durchgezogenen Durchlauf vergleichbar.
class _PauseNotice extends StatelessWidget {
  const _PauseNotice({
    required this.pauseCount,
    required this.pausedDuration,
  });

  final int pauseCount;
  final Duration pausedDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.error;
    final times = pauseCount == 1 ? 'einmal' : '$pauseCount-mal';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: Radii.bandRadius,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Dieser Durchlauf wurde $times unterbrochen '
              '(${formatShortDuration(pausedDuration)} Pause). '
              'Im echten Test ist das nicht möglich – das Ergebnis ist '
              'entsprechend nur eingeschränkt vergleichbar.',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fehlerquote einer Kategorie (Modul).
class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.module, required this.results});

  final TrainingModule module;
  final List<QuestionResult> results;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final correct = results.where((result) => result.correct).length;
    final errorRate = results.isEmpty ? 0.0 : 1 - correct / results.length;

    final answered = results.where((result) => result.answered).toList();
    final averageMs = answered.isEmpty
        ? 0
        : answered.fold<int>(
              0,
              (sum, result) => sum + result.timeSpent.inMilliseconds,
            ) ~/
            answered.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: Radii.bandRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(module.icon, size: 18, color: module.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  module.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${(errorRate * 100).round()} % Fehler',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: errorRate > 0.5
                      ? theme.colorScheme.error
                      : module.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.pill),
            child: LinearProgressIndicator(
              value: results.isEmpty ? 0 : correct / results.length,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(module.color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$correct von ${results.length} richtig · '
            'Ø ${formatShortDuration(Duration(milliseconds: averageMs))} '
            'pro Aufgabe',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Zeigt nach einem Sprint, wie das Ergebnis zum bisherigen Bestwert steht.
class _SprintRecordBanner extends StatelessWidget {
  const _SprintRecordBanner({
    required this.score,
    required this.previousBest,
    required this.isNewBest,
  });

  final int score;
  final int previousBest;
  final bool isNewBest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const gold = Color(0xFFD97706);

    final (Color color, IconData icon, String text) = switch ((
      isNewBest,
      previousBest,
    )) {
      (true, 0) => (gold, Icons.emoji_events, 'Erster Bestwert: $score richtig'),
      (true, _) => (
          gold,
          Icons.emoji_events,
          'Neuer Bestwert! Vorher waren es $previousBest.',
        ),
      (false, _) => (
          theme.colorScheme.outline,
          Icons.flag_outlined,
          'Bestwert für diesen Aufgabentyp: $previousBest richtig',
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: Radii.bandRadius,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isNewBest ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
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

  /// Kurze Einordnung des Ergebnisses – bewusst sachlich, ohne Übertreibung.
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
        borderRadius: Radii.bandRadius,
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
            borderRadius: BorderRadius.circular(Radii.pill),
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

/// Eine Zeile der Themen-Aufschlüsselung nach einer gemischten Runde.
class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.subCategory, required this.results});

  final SubCategory subCategory;
  final List<QuestionResult> results;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final correct = results.where((result) => result.correct).length;
    final ratio = results.isEmpty ? 0.0 : correct / results.length;
    final color = subCategory.module.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${subCategory.module.shortLabel} · ${subCategory.label}',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Text(
                '$correct/${results.length}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.pill),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 5,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
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
    // Ein Teil kann mehrere Module umfassen – dann gibt es keine Modulfarbe.
    final color = result.part.primaryModule?.color ?? theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: Radii.bandRadius,
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
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.pill),
            child: LinearProgressIndicator(
              value: result.accuracy,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(result.errorRate * 100).round()} % Fehler · '
            'Ø ${formatShortDuration(result.averageTimePerQuestion)} '
            'pro Aufgabe · ${result.part.duration.inMinutes} Min Limit',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Aufklappbare Zeile mit Aufgabe, gegebener Antwort und Erklärung.
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
          context.tokens.correct,
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
        borderRadius: Radii.bandRadius,
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
          '${question.subCategory.label} · $status · '
          '${formatShortDuration(record.timeSpent)}',
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
            value: record.responseText,
            color: record.isCorrect ? context.tokens.correct : color,
          ),
          const SizedBox(height: 4),
          _ReviewLine(
            label: 'Richtige Antwort',
            value: question.correctAnswerText,
            color: context.tokens.correct,
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
