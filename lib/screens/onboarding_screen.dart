import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/quiz_session.dart';
import 'package:einstellungstest_trainer/models/todays_plan.dart';
import 'package:einstellungstest_trainer/screens/quiz_screen.dart';
import 'package:einstellungstest_trainer/services/exam_date_controller.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ob die Einführung noch aussteht.
final onboardingDoneProvider = NotifierProvider<OnboardingController, bool>(
  OnboardingController.new,
);

class OnboardingController extends Notifier<bool> {
  @override
  bool build() => ref.watch(storageServiceProvider).onboardingDone;

  Future<void> complete() async {
    state = true;
    await ref.read(storageServiceProvider).setOnboardingDone(true);
  }

  /// Für den Eintrag „So funktioniert die App" unter „Mehr": Die Einführung
  /// lässt sich noch einmal ansehen, ohne den Fortschritt anzufassen.
  Future<void> replay() async {
    await ref.read(storageServiceProvider).setOnboardingDone(false);
    state = false;
  }
}

/// Die Einführung: drei Schritte, dann direkt in die erste Runde.
///
/// Bewusst kein vierter Bildschirm mit „Los geht's" – man versteht die App
/// beim Tun, nicht beim Lesen. Deshalb endet die Einführung nicht auf der
/// Startseite, sondern in einer echten Übungsrunde.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.replayOnly = false});

  /// Beim Wiederansehen aus „Mehr" wird am Ende nichts gestartet.
  final bool replayOnly;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  int _step = 0;
  bool? _hasExam;
  DateTime? _pickedDate;

  static const int _steps = 3;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    setState(() => _step = step);
    _pages.animateToPage(
      step,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  Future<void> _finish() async {
    final date = _pickedDate;
    if (date != null) {
      await ref.read(examDateProvider.notifier).set(date);
    }
    await ref.read(onboardingDoneProvider.notifier).complete();

    if (!mounted) return;

    if (widget.replayOnly) {
      Navigator.of(context).pop();
      return;
    }

    // Direkt in die erste Runde statt auf die Startseite.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const QuizScreen(
          mode: SessionMode.practice,
          scope: PracticeScope.mixed(),
          length: TodaysPlan.firstRoundLength,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.ink,
      body: SafeArea(
        child: Column(
          children: [
            _StepBar(step: _step, steps: _steps),
            Expanded(
              child: PageView(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const _WhatItDoes(),
                  _GoalStep(
                    selected: _hasExam,
                    onSelect: (value) {
                      setState(() => _hasExam = value);
                      _goTo(2);
                    },
                  ),
                  _DateStep(
                    hasExam: _hasExam ?? false,
                    picked: _pickedDate,
                    onPick: (value) => setState(() => _pickedDate = value),
                  ),
                ],
              ),
            ),
            _Actions(
              step: _step,
              canContinue: _step != 1 || _hasExam != null,
              onBack: _step == 0 ? null : () => _goTo(_step - 1),
              onNext: _step == _steps - 1 ? _finish : () => _goTo(_step + 1),
              lastLabel: widget.replayOnly
                  ? 'Fertig'
                  : 'Erste Runde starten',
              isLast: _step == _steps - 1,
            ),
          ],
        ),
      ),
    );
  }
}

/// Fortschritt der Einführung – drei Striche, kein Text.
class _StepBar extends StatelessWidget {
  const _StepBar({required this.step, required this.steps});

  final int step;
  final int steps;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Gap.screen,
        Gap.card,
        Gap.screen,
        Gap.sm,
      ),
      child: Row(
        children: [
          for (var index = 0; index < steps; index++) ...[
            if (index > 0) const SizedBox(width: Gap.xs),
            Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: index <= step
                      ? tokens.onInk
                      : tokens.onInk.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Schritt 1: Was die App macht. Ein Satz je Zeile, keine Absätze.
class _WhatItDoes extends StatelessWidget {
  const _WhatItDoes();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    const points = [
      (Icons.school_outlined, 'Üben', 'Mit Lösung und Rechenweg nach jeder '
          'Antwort.'),
      (Icons.bolt_outlined, 'Sprint', '60 Sekunden Tempo auf einen '
          'Aufgabentyp.'),
      (Icons.timer_outlined, 'Ernstfall', 'Ein kompletter Test unter Zeit – '
          'ohne Lösungen zwischendurch.'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Gap.header),
          Text(
            'Drei Wege zum Test',
            style: theme.textTheme.headlineSmall?.copyWith(color: tokens.onInk),
          ),
          const SizedBox(height: Gap.section),
          for (final (icon, title, text) in points)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.section),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: tokens.onInk, size: 22),
                  const SizedBox(width: Gap.card),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: tokens.onInk,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          text,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: tokens.onInk.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Schritt 2: Prüfungstermin oder freies Üben.
class _GoalStep extends StatelessWidget {
  const _GoalStep({required this.selected, required this.onSelect});

  final bool? selected;
  final ValueChanged<bool> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Gap.header),
          Text(
            'Hast du schon einen Termin?',
            style: theme.textTheme.headlineSmall?.copyWith(color: tokens.onInk),
          ),
          const SizedBox(height: Gap.section),
          _Choice(
            title: 'Ja, ich habe einen Prüfungstermin',
            subtitle: 'Du siehst dann einen Countdown und wirst erinnert.',
            selected: selected == true,
            onTap: () => onSelect(true),
          ),
          const SizedBox(height: Gap.md),
          _Choice(
            title: 'Nein, ich übe erst mal',
            subtitle: 'Geht genauso – du kannst den Termin später eintragen.',
            selected: selected == false,
            onTap: () => onSelect(false),
          ),
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return Material(
      color: selected
          ? tokens.onInk.withValues(alpha: 0.14)
          : Colors.transparent,
      borderRadius: Radii.cardRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.cardRadius,
        child: Container(
          padding: const EdgeInsets.all(Gap.card),
          decoration: BoxDecoration(
            borderRadius: Radii.cardRadius,
            border: Border.all(
              color: tokens.onInk.withValues(alpha: selected ? 0.9 : 0.3),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: tokens.onInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tokens.onInk.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check, color: tokens.onInk, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Schritt 3: Datum wählen – oder überspringen, wenn kein Termin ansteht.
class _DateStep extends StatelessWidget {
  const _DateStep({
    required this.hasExam,
    required this.picked,
    required this.onPick,
  });

  final bool hasExam;
  final DateTime? picked;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    if (!hasExam) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Gap.header),
            Text(
              'Dann legen wir los',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: tokens.onInk,
              ),
            ),
            const SizedBox(height: Gap.md),
            Text(
              'Die erste Runde ist kurz und geht quer durch alle Bereiche. '
              'Danach schlägt dir die App vor, woran du arbeiten solltest.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: tokens.onInk.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Gap.header),
          Text(
            'Wann ist es so weit?',
            style: theme.textTheme.headlineSmall?.copyWith(color: tokens.onInk),
          ),
          const SizedBox(height: Gap.section),
          if (picked != null) ...[
            Text(
              '${picked!.day.toString().padLeft(2, '0')}.'
              '${picked!.month.toString().padLeft(2, '0')}.${picked!.year}',
              style: MonoText.display.copyWith(color: tokens.onInk),
            ),
            const SizedBox(height: Gap.sm),
          ],
          OutlinedButton(
            onPressed: () async {
              final now = DateTime.now();
              final result = await showDatePicker(
                context: context,
                initialDate: picked ?? now.add(const Duration(days: 30)),
                firstDate: now,
                lastDate: now.add(const Duration(days: 730)),
                helpText: 'Wann ist dein Einstellungstest?',
              );
              if (result != null) onPick(result);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: tokens.onInk,
              side: BorderSide(color: tokens.onInk.withValues(alpha: 0.4)),
            ),
            child: Text(picked == null ? 'Datum wählen' : 'Datum ändern'),
          ),
          const SizedBox(height: Gap.md),
          Text(
            'Ohne Datum geht es auch – du kannst es später eintragen.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: tokens.onInk.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.step,
    required this.canContinue,
    required this.onBack,
    required this.onNext,
    required this.lastLabel,
    required this.isLast,
  });

  final int step;
  final bool canContinue;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final String lastLabel;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Gap.screen,
        Gap.md,
        Gap.screen,
        Gap.screen,
      ),
      child: Row(
        children: [
          if (onBack != null)
            TextButton(
              onPressed: onBack,
              style: TextButton.styleFrom(
                foregroundColor: tokens.onInk.withValues(alpha: 0.7),
              ),
              child: const Text('Zurück'),
            ),
          const Spacer(),
          FilledButton(
            onPressed: canContinue ? onNext : null,
            style: FilledButton.styleFrom(
              backgroundColor: tokens.onInk,
              foregroundColor: tokens.ink,
              minimumSize: const Size(160, 52),
            ),
            child: Text(isLast ? lastLabel : 'Weiter'),
          ),
        ],
      ),
    );
  }
}
