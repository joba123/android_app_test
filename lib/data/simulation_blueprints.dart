import 'package:einstellungstest_trainer/models/simulation.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';

/// Baupläne der Testsimulationen.
///
/// Jede Simulation dauert mindestens 30 Minuten und besteht aus mehreren
/// Testteilen mit fest vorgegebener Bearbeitungszeit. Zwischen den Teilen gibt
/// es ein kurzes Briefing – danach läuft die Zeit unerbittlich.
abstract final class SimulationBlueprints {
  static const math = SimulationBlueprint(
    id: 'sim_math',
    title: 'Testsimulation Mathematik',
    description:
        'Drei Testteile unter Zeitdruck – wie im echten Auswahlverfahren.',
    module: TrainingModule.math,
    parts: [
      SimulationPart(
        title: 'Teil 1: Grundrechenarten',
        module: TrainingModule.math,
        subCategories: [SubCategory.arithmetic],
        questionCount: 8,
        duration: Duration(minutes: 8),
        instructions: 'Rechnen ohne Taschenrechner. Arbeiten Sie zügig – '
            'nicht beantwortete Aufgaben zählen als falsch.',
      ),
      SimulationPart(
        title: 'Teil 2: Dreisatz & Prozentrechnung',
        module: TrainingModule.math,
        subCategories: [SubCategory.ruleOfThree, SubCategory.percentage],
        questionCount: 8,
        duration: Duration(minutes: 10),
        instructions: 'Achten Sie auf Grundwert und Prozentwert. '
            'Bei mehrstufigen Rabatten darf nicht einfach addiert werden.',
      ),
      SimulationPart(
        title: 'Teil 3: Textaufgaben',
        module: TrainingModule.math,
        subCategories: [SubCategory.wordProblems],
        questionCount: 6,
        duration: Duration(minutes: 12),
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
        module: TrainingModule.logic,
        subCategories: [SubCategory.numberSequences],
        questionCount: 10,
        duration: Duration(minutes: 10),
        instructions: 'Suchen Sie zuerst die Abstände zwischen den Gliedern. '
            'Nicht jede Reihe wächst gleichmäßig.',
      ),
      SimulationPart(
        title: 'Teil 2: Figurenanalogien',
        module: TrainingModule.logic,
        subCategories: [SubCategory.figureAnalogies],
        questionCount: 8,
        duration: Duration(minutes: 8),
        instructions: 'Klären Sie erst, was sich von Figur zu Figur ändert – '
            'Form, Anzahl oder Lage.',
      ),
      SimulationPart(
        title: 'Teil 3: Schlussfolgerungen',
        module: TrainingModule.logic,
        subCategories: [SubCategory.conclusions],
        questionCount: 5,
        duration: Duration(minutes: 14),
        instructions: 'Prüfen Sie streng, was aus den Aussagen zwingend folgt – '
            'nicht, was plausibel klingt.',
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
        module: TrainingModule.language,
        subCategories: [SubCategory.spelling],
        questionCount: 10,
        duration: Duration(minutes: 8),
        instructions: 'Vertrauen Sie auf den ersten Eindruck – '
            'langes Grübeln kostet hier meist nur Zeit.',
      ),
      SimulationPart(
        title: 'Teil 2: Wortanalogien',
        module: TrainingModule.language,
        subCategories: [SubCategory.wordAnalogies],
        questionCount: 8,
        duration: Duration(minutes: 8),
        instructions: 'Formulieren Sie das Verhältnis des ersten Paares in '
            'Worten, bevor Sie die Lösung suchen.',
      ),
      SimulationPart(
        title: 'Teil 3: Grammatik & Textverständnis',
        module: TrainingModule.language,
        subCategories: [SubCategory.grammar, SubCategory.vocabulary],
        questionCount: 10,
        duration: Duration(minutes: 16),
        instructions: 'Bei Textaufgaben zählt ausschließlich, was im Text '
            'steht.',
      ),
    ],
  );

  /// Modulübergreifende Gesamtsimulation – kommt einem realen
  /// Einstellungstest am nächsten.
  static const full = SimulationBlueprint(
    id: 'sim_full',
    title: 'Gesamtsimulation',
    description: 'Alle drei Module hintereinander – 42 Minuten am Stück.',
    parts: [
      SimulationPart(
        title: 'Teil 1: Mathematik',
        module: TrainingModule.math,
        subCategories: [],
        questionCount: 10,
        duration: Duration(minutes: 14),
        instructions: 'Gemischte Rechenaufgaben aus allen Themen des Moduls.',
      ),
      SimulationPart(
        title: 'Teil 2: Logisches Denken',
        module: TrainingModule.logic,
        subCategories: [],
        questionCount: 10,
        duration: Duration(minutes: 14),
        instructions: 'Reihen, Figuren und Schlussfolgerungen gemischt.',
      ),
      SimulationPart(
        title: 'Teil 3: Sprache',
        module: TrainingModule.language,
        subCategories: [],
        questionCount: 10,
        duration: Duration(minutes: 14),
        instructions: 'Rechtschreibung, Analogien und Textverständnis gemischt.',
      ),
    ],
  );

  static const all = [math, logic, language, full];

  static SimulationBlueprint forModule(TrainingModule module) {
    return switch (module) {
      TrainingModule.math => math,
      TrainingModule.logic => logic,
      TrainingModule.language => language,
    };
  }
}
