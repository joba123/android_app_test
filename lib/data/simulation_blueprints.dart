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
        questionCount: 6,
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
        questionCount: 5,
        duration: Duration(minutes: 12),
        instructions: 'Lesen Sie die Aufgabe vollständig, bevor Sie rechnen. '
            'Notieren Sie sich die gesuchte Größe.',
      ),
    ],
  );

  static const logic = SimulationBlueprint(
    id: 'sim_logic',
    title: 'Testsimulation Logisches Denken',
    description: 'Reihen, Analogien und Schlussfolgerungen unter Zeitvorgabe.',
    module: TrainingModule.logic,
    parts: [
      SimulationPart(
        title: 'Teil 1: Zahlen- und Buchstabenreihen',
        module: TrainingModule.logic,
        subCategories: [SubCategory.numberSequences],
        questionCount: 7,
        duration: Duration(minutes: 10),
        instructions: 'Suchen Sie zuerst die Abstände zwischen den Gliedern. '
            'Nicht jede Reihe wächst gleichmäßig.',
      ),
      SimulationPart(
        title: 'Teil 2: Wort- und Figurenanalogien',
        module: TrainingModule.logic,
        subCategories: [SubCategory.wordAnalogies, SubCategory.figureAnalogies],
        questionCount: 8,
        duration: Duration(minutes: 8),
        instructions: 'Formulieren Sie das Verhältnis des ersten Paares in '
            'Worten, bevor Sie die Lösung suchen.',
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
    description: 'Rechtschreibung, Grammatik und Textverständnis am Stück.',
    module: TrainingModule.language,
    parts: [
      SimulationPart(
        title: 'Teil 1: Rechtschreibung',
        module: TrainingModule.language,
        subCategories: [SubCategory.spelling],
        questionCount: 7,
        duration: Duration(minutes: 8),
        instructions: 'Vertrauen Sie auf den ersten Eindruck – '
            'langes Grübeln kostet hier meist nur Zeit.',
      ),
      SimulationPart(
        title: 'Teil 2: Grammatik',
        module: TrainingModule.language,
        subCategories: [SubCategory.grammar],
        questionCount: 6,
        duration: Duration(minutes: 10),
        instructions: 'Achten Sie auf Fälle, Präpositionen und Kommasetzung.',
      ),
      SimulationPart(
        title: 'Teil 3: Wortschatz & Textverständnis',
        module: TrainingModule.language,
        subCategories: [SubCategory.vocabulary],
        questionCount: 8,
        duration: Duration(minutes: 14),
        instructions: 'Bei Textaufgaben zählt ausschließlich, was im Text steht.',
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
        instructions: 'Reihen, Analogien und Schlussfolgerungen gemischt.',
      ),
      SimulationPart(
        title: 'Teil 3: Sprache',
        module: TrainingModule.language,
        subCategories: [],
        questionCount: 10,
        duration: Duration(minutes: 14),
        instructions: 'Rechtschreibung, Grammatik und Textverständnis gemischt.',
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
