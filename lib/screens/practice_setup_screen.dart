import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/quiz_session.dart';
import 'package:einstellungstest_trainer/screens/quiz_screen.dart';
import 'package:einstellungstest_trainer/services/quiz_controller.dart';
import 'package:einstellungstest_trainer/widgets/scope_selector.dart';
import 'package:flutter/material.dart';

/// Einstieg in den Übungsmodus: Was soll geübt werden und wie viel?
///
/// Die Auswahl ist reiner Bildschirmzustand und lebt deshalb lokal – erst beim
/// Start entsteht über den [quizControllerProvider] eine Sitzung.
class PracticeSetupScreen extends StatefulWidget {
  const PracticeSetupScreen({super.key, this.initialScope});

  /// Vorauswahl, z. B. wenn vom Modul-Screen aus gestartet wird.
  final PracticeScope? initialScope;

  @override
  State<PracticeSetupScreen> createState() => _PracticeSetupScreenState();
}

class _PracticeSetupScreenState extends State<PracticeSetupScreen> {
  late PracticeScope _scope =
      widget.initialScope ?? const PracticeScope.mixed();
  int _length = QuizController.defaultPracticeLength;

  void _start() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuizScreen(
          mode: SessionMode.practice,
          scope: _scope,
          length: _length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Übungsmodus')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  Text(
                    'Was möchtest du üben?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nach jeder Antwort siehst du sofort die Lösung mit '
                    'Rechenweg. Ohne Zeitdruck.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ScopeSelector(
                    selected: _scope,
                    onChanged: (scope) => setState(() => _scope = scope),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Wie viele Aufgaben?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [
                      for (final length in QuizController.practiceLengths)
                        ChoiceChip(
                          label: Text('$length Aufgaben'),
                          selected: _length == length,
                          onSelected: (_) => setState(() => _length = length),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Stehen für das gewählte Thema weniger Aufgaben zur '
                    'Verfügung, wird die Runde entsprechend kürzer.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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
                    'Auswahl: ${_scope.label}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _start,
                    child: const Text('Übung starten'),
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
