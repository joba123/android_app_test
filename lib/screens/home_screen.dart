import 'package:einstellungstest_trainer/data/question_pool.dart';
import 'package:einstellungstest_trainer/data/simulation_blueprints.dart';
import 'package:einstellungstest_trainer/models/module_stats.dart';
import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/quiz_session.dart';
import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/screens/categories_screen.dart';
import 'package:einstellungstest_trainer/screens/quiz_screen.dart';
import 'package:einstellungstest_trainer/screens/settings_screen.dart';
import 'package:einstellungstest_trainer/screens/simulation_screen.dart';
import 'package:einstellungstest_trainer/services/exam_date_controller.dart';
import 'package:einstellungstest_trainer/services/profile_controller.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/services/purchase/entitlement_controller.dart';
import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:einstellungstest_trainer/widgets/domain_card.dart';
import 'package:einstellungstest_trainer/widgets/section_title.dart';
import 'package:einstellungstest_trainer/widgets/simulation_card.dart';
import 'package:einstellungstest_trainer/widgets/today_band.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Das Hauptmenü.
///
/// Begrüßung, das Band mit Termin und Tagesziel, drei Bereiche zum
/// Ausklappen, darunter der Ernstfall. Der Modus wird in der Karte des
/// Bereichs gewählt, nicht auf einem eigenen Bildschirm – dadurch braucht
/// der Weg von „App auf" bis „erste Aufgabe" zwei Tipper.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Höchstens ein Bereich ist offen: Zwei ausgeklappte Karten passen nicht
  /// mehr auf den Bildschirm, und die Wahl ist ohnehin eine.
  TrainingModule? _open;

  void _openScreen(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  void _start(SessionMode mode, PracticeScope scope) {
    _openScreen(QuizScreen(mode: mode, scope: scope));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = ref.watch(statsControllerProvider);
    final examDate = ref.watch(examDateProvider);
    final profile = ref.watch(profileProvider);
    final answeredToday = ref.watch(answeredTodayProvider);
    final isPro = ref.watch(isProProvider);
    final lastSimulation = ref.watch(lastSimulationScoreProvider);
    final dueErrors = ref.watch(dueReviewCountProvider);
    final side = Gap.screenPadding(MediaQuery.sizeOf(context).width);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(side, 0, side, Gap.header),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Gap.sm, 14, Gap.sm, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.greeting(DateTime.now()),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: Gap.xs),
                  Text(profile.headline, style: theme.textTheme.headlineLarge),
                ],
              ),
            ),
            TodayBand(
              examDate: examDate,
              answeredToday: answeredToday,
              goal: profile.dailyGoal,
              onTap: () => _openScreen(const SettingsScreen()),
            ),
            // Die Wiederholung steht nur da, wenn es etwas zu wiederholen
            // gibt – eine Zeile „0 Fehler" waere Fuellmaterial.
            if (dueErrors > 0) ...[
              const SizedBox(height: Gap.sm),
              _ReviewRow(
                count: dueErrors,
                onTap: () => _start(
                  SessionMode.practice,
                  const PracticeScope.review(),
                ),
              ),
            ],
            const SizedBox(height: Gap.card),
            for (final module in TrainingModule.values) ...[
              DomainCard(
                module: module,
                subtitle: _subtitle(module, stats.forModule(module), isPro),
                accuracy: stats.forModule(module).accuracy,
                topicCount: SubCategory.of(module).length,
                expanded: _open == module,
                onToggle: () => setState(
                  () => _open = _open == module ? null : module,
                ),
                onPractice: () => _start(
                  SessionMode.practice,
                  PracticeScope.module(module),
                ),
                onSprint: () => _start(
                  SessionMode.sprint,
                  PracticeScope.module(module),
                ),
                onTopics: () => _openScreen(CategoriesScreen(module: module)),
              ),
              const SizedBox(height: Gap.md),
            ],
            const SizedBox(height: Gap.md),
            const SectionTitle('Testsimulation'),
            SimulationCard(
              blueprint: SimulationBlueprints.full,
              lastScore: lastSimulation,
              onStart: () => _openScreen(
                const SimulationScreen(blueprint: SimulationBlueprints.full),
              ),
            ),
            const SizedBox(height: Gap.sm),
            TryoutRow(
              blueprint: SimulationBlueprints.tryout,
              onTap: () => _openScreen(
                const SimulationScreen(blueprint: SimulationBlueprints.tryout),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// „142 Aufgaben · 64 % gemeistert" – und solange nichts geübt wurde, die
  /// halbe Zeile statt einer Null.
  String _subtitle(TrainingModule module, ModuleStats stats, bool isPro) {
    final size = QuestionPool.describeSize(module, proUnlocked: isPro);

    if (stats.answered == 0) return '$size · noch nicht geübt';
    return '$size · ${(stats.accuracy * 100).round()} % gemeistert';
  }
}

/// „Fehler wiederholen" – der Weg zurück zu dem, was schiefging.
///
/// Sitzt direkt unter dem Band, weil Wiederholen vor Neuem kommt, sobald es
/// etwas zu wiederholen gibt.
class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return Material(
      color: tokens.wrongSoft,
      borderRadius: Radii.bandRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.bandRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Gap.card,
            vertical: 14,
          ),
          child: Row(
            children: [
              Icon(Icons.replay_rounded, size: 20, color: tokens.wrong),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Text(
                  'Deine Fehler wiederholen',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Text(
                '$count',
                style: NumText.inline.copyWith(color: tokens.wrong),
              ),
              const SizedBox(width: Gap.sm),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
