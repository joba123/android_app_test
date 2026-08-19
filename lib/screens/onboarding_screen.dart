import 'package:einstellungstest_trainer/models/field_of_study.dart';
import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/quiz_session.dart';
import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/screens/quiz_screen.dart';
import 'package:einstellungstest_trainer/services/exam_plan_controller.dart';
import 'package:einstellungstest_trainer/services/profile_controller.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:einstellungstest_trainer/widgets/field_picker.dart';
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

  /// Für den Eintrag „Einführung erneut ansehen" in den Einstellungen.
  Future<void> replay() async {
    await ref.read(storageServiceProvider).setOnboardingDone(false);
    state = false;
  }
}

/// Ein Schritt der Einführung: ein Zeichen, ein Satz, ein Absatz.
class _Step {
  const _Step({
    required this.glyph,
    required this.module,
    required this.title,
    required this.text,
    this.icon,
  });

  /// Das große Zeichen auf der Kachel. Leer, wenn ein [icon] gesetzt ist.
  final String glyph;
  final IconData? icon;

  /// Woher die Kachel ihre Farbe nimmt.
  final TrainingModule module;

  final String title;
  final String text;
}

const List<_Step> _steps = [
  _Step(
    glyph: '3',
    module: TrainingModule.math,
    title: 'Drei Bereiche, ein Ziel',
    text: 'Mathematik, Logik und Sprache – genau die Aufgabentypen, die in '
        'Einstellungstests wirklich vorkommen.',
  ),
  _Step(
    glyph: '60',
    module: TrainingModule.logic,
    title: 'Üben oder Sprint',
    text: 'In Ruhe lernen mit Lösungsweg – oder im 60-Sekunden-Sprint Tempo '
        'aufbauen.',
  ),
  _Step(
    // Das Häkchen führt keine der beiden Schriften, deshalb als Symbol.
    glyph: '',
    icon: Icons.check_rounded,
    module: TrainingModule.language,
    title: 'Der Ernstfall zum Üben',
    text: 'Die Testsimulation kombiniert alle Bereiche unter echten '
        'Zeitvorgaben – ohne Lösungen, mit laufender Uhr.',
  ),
];

/// Die Einführung: drei Schritte, die die App erklären, ein vierter, der
/// nach Namen und Termin fragt – und danach sofort die erste Runde.
///
/// Der vierte Schritt steht bewusst am Ende: Wer noch nicht weiß, was die
/// App tut, kann mit der Frage nach einem Prüfungstermin nichts anfangen.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.replayOnly = false});

  /// Beim Wiederansehen aus den Einstellungen wird am Ende nichts gestartet.
  final bool replayOnly;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _name = TextEditingController();
  int _step = 0;
  DateTime? _pickedDate;
  FieldOfStudy _field = FieldOfStudy.general;

  /// Wie viele Aufgaben die erste Runde hat. Kurz genug, um sie zu Ende zu
  /// bringen, lang genug, um alle drei Bereiche zu zeigen.
  static const int firstRoundLength = 10;

  /// Nach den erklärenden Schritten kommen zwei eigene: die Fachrichtung
  /// und danach Name und Termin.
  int get _fieldStep => _steps.length;
  int get _lastStep => _steps.length + 1;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      helpText: 'Testtermin wählen',
    );

    if (picked != null) setState(() => _pickedDate = picked);
  }

  Future<void> _finish() async {
    final plans = ref.read(examPlansProvider);
    final active = plans.active;

    // Die erste Prüfung entsteht beim ersten Start automatisch; hier bekommt
    // sie ihre Fachrichtung und – wenn vorhanden – ihren Termin.
    if (active != null) {
      await ref.read(examPlansProvider.notifier).update(
            active.id,
            title: _field == FieldOfStudy.general ? active.title : _field.label,
            field: _field,
            date: _pickedDate,
            clearDate: _pickedDate == null,
          );
    }
    await ref.read(profileProvider.notifier).setName(_name.text);
    await ref.read(onboardingDoneProvider.notifier).complete();

    if (!mounted) return;

    if (widget.replayOnly) {
      Navigator.of(context).pop();
      return;
    }

    // Direkt in die erste Runde statt ins Hauptmenü: Man versteht die App
    // beim Tun, nicht beim Lesen. Aufgesetzt und nicht ersetzt – darunter
    // liegt der Rahmen, der jetzt das Hauptmenü zeigt, und dorthin führt der
    // Weg nach der Runde zurück.
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const QuizScreen(
          mode: SessionMode.practice,
          scope: PracticeScope.mixed(),
          length: firstRoundLength,
        ),
      ),
    );
  }

  void _next() {
    if (_step == _lastStep) {
      _finish();
      return;
    }
    setState(() => _step += 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onLast = _step == _lastStep;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Gap.section,
            0,
            Gap.section,
            Gap.section,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 64,
                child: Row(
                  children: [
                    for (var index = 0; index <= _lastStep; index++)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 4,
                          decoration: BoxDecoration(
                            color: index <= _step
                                ? theme.colorScheme.onSurface
                                : context.tokens.sunk,
                            borderRadius: BorderRadius.circular(Radii.pill),
                          ),
                        ),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: _finish,
                      child: const Text('Überspringen'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: switch (_step) {
                  final step when step == _lastStep => _AboutYou(
                      name: _name,
                      pickedDate: _pickedDate,
                      onPickDate: _pickDate,
                      onClearDate: () => setState(() => _pickedDate = null),
                    ),
                  final step when step == _fieldStep => _FieldStep(
                      selected: _field,
                      onSelect: (field) => setState(() => _field = field),
                    ),
                  _ => _Explainer(step: _steps[_step]),
                },
              ),
              FilledButton(
                onPressed: _next,
                child: Text(
                  onLast
                      ? (widget.replayOnly ? 'Fertig' : 'Erste Runde starten')
                      : 'Weiter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Einer der drei erklärenden Schritte.
class _Explainer extends StatelessWidget {
  const _Explainer({required this.step});

  final _Step step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = step.module.palette(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 148,
          height: 148,
          decoration: BoxDecoration(
            color: palette.soft,
            borderRadius: BorderRadius.circular(40),
          ),
          alignment: Alignment.center,
          child: step.icon != null
              ? Icon(step.icon, size: 62, color: palette.deep)
              : Text(
                  step.glyph,
                  style: TextStyle(
                    fontFamily: AppFonts.display,
                    fontFamilyFallback: AppFonts.displayFallback,
                    fontSize: 58,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: palette.deep,
                  ),
                ),
        ),
        const SizedBox(height: Gap.header),
        Text(step.title, style: theme.textTheme.displayLarge),
        const SizedBox(height: Gap.card),
        Text(step.text, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

/// Der letzte Schritt: Name und Termin, beides freiwillig.
class _AboutYou extends StatelessWidget {
  const _AboutYou({
    required this.name,
    required this.pickedDate,
    required this.onPickDate,
    required this.onClearDate,
  });

  final TextEditingController name;
  final DateTime? pickedDate;
  final VoidCallback onPickDate;
  final VoidCallback onClearDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final date = pickedDate;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Gap.section),
          Text('Damit wir uns kennen', style: theme.textTheme.displayLarge),
          const SizedBox(height: Gap.card),
          Text(
            'Beides ist freiwillig und bleibt auf deinem Gerät.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: Gap.header),
          TextField(
            controller: name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Vorname',
              hintText: 'für die Begrüßung',
            ),
          ),
          const SizedBox(height: Gap.section),
          Text('Hast du schon einen Testtermin?',
              style: theme.textTheme.titleLarge),
          const SizedBox(height: Gap.md),
          if (date == null)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPickDate,
                    child: const Text('Ja, Datum wählen'),
                  ),
                ),
              ],
            )
          else
            Material(
              color: tokens.band,
              borderRadius: Radii.bandRadius,
              child: InkWell(
                onTap: onPickDate,
                borderRadius: Radii.bandRadius,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Gap.card,
                    vertical: Gap.card,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${date.day.toString().padLeft(2, '0')}.'
                          '${date.month.toString().padLeft(2, '0')}.'
                          '${date.year}',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: onClearDate,
                        child: const Text('Entfernen'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: Gap.md),
          Text(
            'Ohne Termin zählt die App stattdessen dein Tagesziel mit.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Die Wahl der Fachrichtung – der Schritt, aus dem der Leitfaden entsteht.
class _FieldStep extends StatelessWidget {
  const _FieldStep({required this.selected, required this.onSelect});

  final FieldOfStudy selected;
  final ValueChanged<FieldOfStudy> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: Gap.card),
        Text('Worauf übst du hin?', style: theme.textTheme.displayLarge),
        const SizedBox(height: Gap.card),
        Text(
          'Daraus baut die App deinen Leitfaden: welche Themen du brauchst '
          'und wie viel davon. Üben kannst du trotzdem alles.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: Gap.section),
        FieldPicker(selected: selected, onSelect: onSelect),
      ],
    );
  }
}
