import 'package:einstellungstest_trainer/models/simulation.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';

/// Baupläne der Testsimulationen.
///
/// Die Taktung orientiert sich an realen Auswahlverfahren (Polizei,
/// Verwaltung, Bahn): Die Testteile sind kurz und scharf gestellt. Als
/// Faustwerte pro Aufgabe:
///
/// * Rechnen: 30–45 Sekunden
/// * Rechtschreibung und Wortanalogien: 20–30 Sekunden (schnelle Erkennung)
/// * Zahlenreihen und Figuren: 40–60 Sekunden
/// * Textverständnis und Schlussfolgerungen: 60–90 Sekunden
///
/// Jede Simulation dauert mindestens 30 Minuten. Zwischen den Teilen gibt es
/// ein kurzes Briefing – danach läuft die Zeit unerbittlich.
abstract final class SimulationBlueprints {
  /// Modulübergreifende Gesamtsimulation – das Kernstück der App und einem
  /// echten Einstellungstest am nächsten.
  static const full = SimulationBlueprint(
    id: 'sim_full',
    title: 'Gesamtsimulation',
    description: 'Vier Testteile, 45 Minuten am Stück – wie im echten '
        'Auswahlverfahren.',
    parts: [
      SimulationPart(
        title: 'Teil 1: Mathematik',
        subCategories: [
          SubCategory.arithmetic,
          SubCategory.ruleOfThree,
          SubCategory.percentage,
        ],
        questionCount: 20,
        duration: Duration(minutes: 15),
        instructions: 'Rechnen ohne Taschenrechner, rund 45 Sekunden pro '
            'Aufgabe. Wer bei einer Aufgabe hängt, geht weiter – '
            'nicht beantwortete Aufgaben zählen als falsch.',
      ),
      SimulationPart(
        title: 'Teil 2: Sprache',
        subCategories: [SubCategory.spelling, SubCategory.wordAnalogies],
        questionCount: 26,
        duration: Duration(minutes: 9),
        instructions: 'Hier zählt Tempo: gut 20 Sekunden pro Aufgabe. '
            'Vertrauen Sie auf den ersten Eindruck, langes Grübeln kostet '
            'mehr, als es bringt.',
      ),
      SimulationPart(
        title: 'Teil 3: Logisches Denken',
        subCategories: [
          SubCategory.numberSequences,
          SubCategory.figureAnalogies,
        ],
        questionCount: 20,
        duration: Duration(minutes: 15),
        instructions: 'Suchen Sie zuerst die Regel: Abstände zwischen den '
            'Gliedern, Änderung von Form, Anzahl oder Lage.',
      ),
      SimulationPart(
        title: 'Teil 4: Textverständnis',
        subCategories: [SubCategory.conclusions, SubCategory.vocabulary],
        questionCount: 8,
        duration: Duration(minutes: 6),
        instructions: 'Zum Abschluss die längeren Aufgaben. Prüfen Sie streng, '
            'was aus dem Text zwingend folgt – nicht, was plausibel klingt.',
      ),
    ],
  );

  static const math = SimulationBlueprint(
    id: 'sim_math',
    title: 'Testsimulation Mathematik',
    description: 'Drei Testteile unter Zeitdruck – nur Rechnen.',
    module: TrainingModule.math,
    parts: [
      SimulationPart(
        title: 'Teil 1: Grundrechenarten',
        subCategories: [SubCategory.arithmetic],
        questionCount: 20,
        duration: Duration(minutes: 10),
        instructions: 'Kopfrechnen im Sekundentakt: 30 Sekunden pro Aufgabe. '
            'Kein Taschenrechner.',
      ),
      SimulationPart(
        title: 'Teil 2: Dreisatz & Prozentrechnung',
        subCategories: [SubCategory.ruleOfThree, SubCategory.percentage],
        questionCount: 16,
        duration: Duration(minutes: 12),
        instructions: 'Achten Sie auf Grundwert und Prozentwert. '
            'Bei mehrstufigen Rabatten darf nicht einfach addiert werden.',
      ),
      SimulationPart(
        title: 'Teil 3: Textaufgaben',
        subCategories: [SubCategory.wordProblems],
        questionCount: 10,
        duration: Duration(minutes: 8),
        instructions: 'Lesen Sie die Aufgabe vollständig, bevor Sie rechnen. '
            'Notieren Sie sich die gesuchte Größe.',
      ),
    ],
  );

  static const logic = SimulationBlueprint(
    id: 'sim_logic',
    title: 'Testsimulation Logisches Denken',
    description: 'Reihen, Figuren und Schlussfolgerungen unter Zeitvorgabe.',
    module: TrainingModule.logic,
    parts: [
      SimulationPart(
        title: 'Teil 1: Zahlen- und Buchstabenreihen',
        subCategories: [SubCategory.numberSequences],
        questionCount: 18,
        duration: Duration(minutes: 13),
        instructions: 'Suchen Sie zuerst die Abstände zwischen den Gliedern. '
            'Nicht jede Reihe wächst gleichmäßig.',
      ),
      SimulationPart(
        title: 'Teil 2: Figurenanalogien',
        subCategories: [SubCategory.figureAnalogies],
        questionCount: 12,
        duration: Duration(minutes: 9),
        instructions: 'Klären Sie erst, was sich von Figur zu Figur ändert – '
            'Form, Anzahl oder Lage.',
      ),
      SimulationPart(
        title: 'Teil 3: Schlussfolgerungen',
        subCategories: [SubCategory.conclusions],
        questionCount: 6,
        duration: Duration(minutes: 8),
        instructions: 'Die längsten Aufgaben zum Schluss. Prüfen Sie streng, '
            'was aus den Aussagen zwingend folgt.',
      ),
    ],
  );

  static const language = SimulationBlueprint(
    id: 'sim_language',
    title: 'Testsimulation Sprache',
    description: 'Rechtschreibung, Analogien und Textverständnis am Stück.',
    module: TrainingModule.language,
    parts: [
      SimulationPart(
        title: 'Teil 1: Rechtschreibung',
        subCategories: [SubCategory.spelling],
        questionCount: 16,
        duration: Duration(minutes: 8),
        instructions: 'Vertrauen Sie auf den ersten Eindruck – '
            'langes Grübeln kostet hier meist nur Zeit.',
      ),
      SimulationPart(
        title: 'Teil 2: Wortanalogien',
        subCategories: [SubCategory.wordAnalogies],
        questionCount: 11,
        duration: Duration(minutes: 7),
        instructions: 'Formulieren Sie das Verhältnis des ersten Paares in '
            'Worten, bevor Sie die Lösung suchen.',
      ),
      SimulationPart(
        title: 'Teil 3: Grammatik & Textverständnis',
        subCategories: [SubCategory.grammar, SubCategory.vocabulary],
        questionCount: 12,
        duration: Duration(minutes: 15),
        instructions: 'Bei Textaufgaben zählt ausschließlich, was im Text '
            'steht – nicht das eigene Vorwissen.',
      ),
    ],
  );

  static const all = [full, math, logic, language];

  static SimulationBlueprint forModule(TrainingModule module) {
    return switch (module) {
      TrainingModule.math => math,
      TrainingModule.logic => logic,
      TrainingModule.language => language,
    };
  }
}
