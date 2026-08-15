import 'package:einstellungstest_trainer/data/question_pool.dart';
import 'package:einstellungstest_trainer/data/simulation_blueprints.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/screens/module_screen.dart';
import 'package:einstellungstest_trainer/screens/simulation_screen.dart';
import 'package:einstellungstest_trainer/screens/stats_screen.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/widgets/module_card.dart';
import 'package:einstellungstest_trainer/widgets/stat_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = ref.watch(statsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungstest Trainer'),
        actions: [
          IconButton(
            tooltip: 'Statistik',
            icon: const Icon(Icons.insights_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const StatsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Text(
              'Bereit für den nächsten Test?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Trainiere gezielt die Aufgabentypen, die in Einstellungs- und '
              'Eignungstests am häufigsten vorkommen.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    value: '${stats.totalAnswered}',
                    label: 'Aufgaben gelöst',
                    icon: Icons.checklist_rtl,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    value: stats.totalAnswered == 0
                        ? '–'
                        : '${(stats.accuracy * 100).round()} %',
                    label: 'Trefferquote',
                    icon: Icons.percent,
                    color: const Color(0xFF0E9F6E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Text(
              'Module',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (final module in TrainingModule.values)
              ModuleCard(
                module: module,
                questionCount: QuestionPool.countFor(module),
                accuracy: stats.forModule(module).accuracy,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ModuleScreen(module: module),
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Text(
              'Ernstfall',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ModeCard(
              title: SimulationBlueprints.full.title,
              subtitle: SimulationBlueprints.full.description,
              meta:
                  '${SimulationBlueprints.full.totalDuration.inMinutes} Min',
              icon: Icons.timer_outlined,
              color: theme.colorScheme.error,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SimulationScreen(
                    blueprint: SimulationBlueprints.full,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
