import 'package:einstellungstest_trainer/models/training_module.dart';

/// Feinthema einer Aufgabe innerhalb eines Moduls.
///
/// Jede Unterkategorie kennt ihr Modul. Dadurch ist die Zuordnung
/// "Kategorie -> Unterkategorie" im Typsystem festgeschrieben: Es kann keine
/// Aufgabe geben, die im Modul Mathematik liegt und "Rechtschreibung" als
/// Unterkategorie trägt. [Question] leitet seine Kategorie deshalb aus der
/// Unterkategorie ab, statt sie ein zweites Mal zu speichern.
enum SubCategory {
  // --- Mathematik ---
  arithmetic(
    id: 'arithmetic',
    module: TrainingModule.math,
    label: 'Grundrechenarten',
  ),
  ruleOfThree(
    id: 'rule_of_three',
    module: TrainingModule.math,
    label: 'Dreisatz',
  ),
  percentage(
    id: 'percentage',
    module: TrainingModule.math,
    label: 'Prozentrechnung',
  ),
  wordProblems(
    id: 'word_problems',
    module: TrainingModule.math,
    label: 'Textaufgaben',
  ),

  // --- Logisches Denken ---
  numberSequences(
    id: 'number_sequences',
    module: TrainingModule.logic,
    label: 'Zahlenreihen',
  ),
  wordAnalogies(
    id: 'word_analogies',
    module: TrainingModule.logic,
    label: 'Wortanalogien',
  ),
  figureAnalogies(
    id: 'figure_analogies',
    module: TrainingModule.logic,
    label: 'Figurenanalogien',
  ),
  conclusions(
    id: 'conclusions',
    module: TrainingModule.logic,
    label: 'Schlussfolgerungen',
  ),

  // --- Sprache ---
  spelling(
    id: 'spelling',
    module: TrainingModule.language,
    label: 'Rechtschreibung',
  ),
  grammar(
    id: 'grammar',
    module: TrainingModule.language,
    label: 'Grammatik',
  ),
  vocabulary(
    id: 'vocabulary',
    module: TrainingModule.language,
    label: 'Wortschatz & Textverständnis',
  );

  const SubCategory({
    required this.id,
    required this.module,
    required this.label,
  });

  /// Stabiler Schlüssel für die Persistenz. Bewusst getrennt vom Enum-Namen,
  /// damit ein Umbenennen im Code keine gespeicherten Daten entwertet.
  final String id;

  final TrainingModule module;
  final String label;

  /// Alle Unterkategorien eines Moduls in Deklarationsreihenfolge.
  static List<SubCategory> of(TrainingModule module) {
    return values.where((category) => category.module == module).toList();
  }

  static SubCategory? tryFromId(String id) {
    for (final category in values) {
      if (category.id == id) return category;
    }
    return null;
  }
}
