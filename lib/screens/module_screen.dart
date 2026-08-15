import 'package:einstellungstest_trainer/data/simulation_blueprints.dart';
import 'package:einstellungstest_trainer/models/quiz_session.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/screens/quiz_screen.dart';
import 'package:einstellungstest_trainer/screens/simulation_screen.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/services/question_repository.dart';
import 'package:einstellungstest_trainer/services/quiz_controller.dart';
import 'package:einstellungstest_trainer/widgets/module_card.dart';
import 'package:einstellungstest_trainer/widgets/stat_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Auswahl der drei Trainingsmodi innerhalb eines Moduls.
class ModuleScreen extends ConsumerWidget {
  const ModuleScreen({super.key, required this.module});

  final TrainingModule module;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = ref.watch(statsControllerProvider).forModule(module);
    final simulation = SimulationBlueprints.forModule(module);
    final subCategories = SubCategory.of(module);

    return Scaffold(
      appBar: AppBar(title: Text(module.label)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Text(
              module.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final subCategory in subCategories)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: module.color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      subCategory.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: module.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    value: stats.answered == 0
                        ? '–'
                        : '${(stats.accuracy * 100).round()} %',
                    label: 'Trefferquote',
                    icon: Icons.percent,
                    color: module.color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    value: '${stats.bestSprintScore}',
                    label: 'Sprint-Bestwert',
                    icon: Icons.bolt_outlined,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Text(
              'Trainingsmodi',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ModeCard(
              title: 'Übungsmodus',
              subtitle: 'Ohne Zeitdruck lernen. Nach jeder Antwort siehst du '
                  'sofort die Lösung mit Erklärung.',
              meta: '${QuestionRepository.practiceLength} Aufgaben',
              icon: Icons.school_outlined,
              color: module.color,
              onTap: () => _openQuiz(context, SessionMode.practice),
            ),
            ModeCard(
              title: 'Sprint-Modus',
              subtitle: 'So viele Aufgaben wie möglich in 60 Sekunden. '
                  'Kein Feedback zwischendurch – nur Tempo.',
              meta: '${QuizController.sprintSeconds} Sek',
              icon: Icons.bolt_outlined,
              color: const Color(0xFFD97706),
              onTap: () => _openQuiz(context, SessionMode.sprint),
            ),
            ModeCard(
              title: 'Testsimulation',
              subtitle: '${simulation.parts.length} Testteile mit fester '
                  'Bearbeitungszeit. Abgelaufene Zeit bedeutet: Aufgabe verloren.',
              meta: '${simulation.totalDuration.inMinutes} Min',
              icon: Icons.timer_outlined,
              color: theme.colorScheme.error,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SimulationScreen(blueprint: simulation),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openQuiz(BuildContext context, SessionMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuizScreen(mode: mode, module: module),
      ),
    );
  }
}
