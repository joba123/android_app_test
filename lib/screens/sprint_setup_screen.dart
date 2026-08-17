import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/quiz_session.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/screens/quiz_screen.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/services/quiz_controller.dart';
import 'package:einstellungstest_trainer/widgets/scope_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Einstieg in den Sprint: Auswahl des Aufgabentyps.
///
/// Anders als im Übungsmodus gibt es hier keinen Umfang zu wählen – die Runde
/// dauert immer 60 Sekunden. Der Misch-Modus fehlt bewusst: Ein Sprint misst
/// das Tempo in **einer** Disziplin, ein Durcheinander aus Kopfrechnen und
/// Textverständnis wäre nicht vergleichbar.
class SprintSetupScreen extends ConsumerStatefulWidget {
  const SprintSetupScreen({super.key, this.initialScope});

  final PracticeScope? initialScope;

  @override
  ConsumerState<SprintSetupScreen> createState() => _SprintSetupScreenState();
}

class _SprintSetupScreenState extends ConsumerState<SprintSetupScreen> {
  late PracticeScope _scope = widget.initialScope ??
      const PracticeScope.module(TrainingModule.math);

  void _start() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuizScreen(mode: SessionMode.sprint, scope: _scope),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = ref.watch(statsControllerProvider);
    final best = stats.bestSprint(_scope);

    return Scaffold(
      appBar: AppBar(title: const Text('Sprint-Modus')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.bolt,
                          color: Color(0xFFD97706),
                          size: 26,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${QuizController.sprintSeconds} Sekunden, so viele '
                            'richtige Antworten wie möglich. Keine Erklärungen '
                            'zwischendurch – die Auswertung kommt am Ende.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welchen Aufgabentyp?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jeder Typ hat seinen eigenen Bestwert.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ScopeSelector(
                    selected: _scope,
                    allowMixed: false,
                    onChanged: (scope) => setState(() => _scope = scope),
                    subtitleBuilder: (scope) {
                      final record = stats.bestSprint(scope);
                      return record == 0
                          ? 'noch kein Bestwert'
                          : 'Bestwert: $record richtig';
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    best == 0
                        ? _scope.sprintTitle
                        : '${_scope.sprintTitle} · Bestwert $best',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _start,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                    ),
                    child: const Text('Sprint starten'),
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
