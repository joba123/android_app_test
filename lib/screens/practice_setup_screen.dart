import 'package:einstellungstest_trainer/data/question_pool.dart';
import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/quiz_session.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/screens/quiz_screen.dart';
import 'package:einstellungstest_trainer/services/quiz_controller.dart';
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
                  _ScopeTile(
                    title: 'Alle Kategorien gemischt',
                    subtitle: 'Mathematik, Logik und Sprache im Wechsel – '
                        'am nächsten am echten Test',
                    icon: Icons.shuffle,
                    color: theme.colorScheme.primary,
                    selected: _scope.isMixed,
                    onTap: () =>
                        setState(() => _scope = const PracticeScope.mixed()),
                  ),
                  for (final module in TrainingModule.values) ...[
                    const SizedBox(height: 18),
                    Text(
                      module.label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: module.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ScopeTile(
                      title: 'Alle Themen',
                      subtitle: QuestionPool.describeSize(module),
                      icon: module.icon,
                      color: module.color,
                      selected: _scope.module == module &&
                          _scope.subCategory == null,
                      onTap: () => setState(
                        () => _scope = PracticeScope.module(module),
                      ),
                    ),
                    for (final subCategory in SubCategory.of(module))
                      _ScopeTile(
                        title: subCategory.label,
                        subtitle:
                            QuestionPool.describeSubCategorySize(subCategory),
                        icon: Icons.subject,
                        color: module.color,
                        indented: true,
                        selected: _scope.subCategory == subCategory,
                        onTap: () => setState(
                          () => _scope = PracticeScope.subCategory(subCategory),
                        ),
                      ),
                  ],
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

/// Auswählbare Zeile für einen Übungsumfang.
class _ScopeTile extends StatelessWidget {
  const _ScopeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
    this.indented = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final bool indented;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(left: indented ? 16 : 0, bottom: 8),
      child: Material(
        color: selected
            ? color.withValues(alpha: 0.10)
            : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? color : theme.colorScheme.outlineVariant,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.radio_button_checked : icon,
                  size: 20,
                  color: selected ? color : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
