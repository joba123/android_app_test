import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';

/// Was in einer Übungsrunde trainiert wird.
///
/// Drei Fälle, über die benannten Konstruktoren erzeugt:
///
/// * [PracticeScope.mixed] – alle Kategorien gemischt
/// * [PracticeScope.module] – ein ganzes Modul, alle seine Themen
/// * [PracticeScope.subCategory] – ein einzelnes Thema
///
/// Der Umweg über die Konstruktoren stellt sicher, dass Modul und
/// Unterkategorie nicht auseinanderlaufen können: Wer ein Thema wählt, bekommt
/// dessen Modul automatisch mitgesetzt.
class PracticeScope {
  const PracticeScope.mixed()
      : module = null,
        subCategory = null;

  const PracticeScope.module(TrainingModule this.module) : subCategory = null;

  PracticeScope.subCategory(SubCategory this.subCategory)
      : module = subCategory.module;

  /// `null` bedeutet: modulübergreifend gemischt.
  final TrainingModule? module;

  /// `null` bedeutet: keine Einschränkung auf ein einzelnes Thema.
  final SubCategory? subCategory;

  bool get isMixed => module == null;

  /// Ausführliche Bezeichnung für Auswahl und Auswertung.
  String get label {
    final topic = subCategory;
    if (topic != null) return '${topic.module.label} · ${topic.label}';

    final currentModule = module;
    if (currentModule != null) return '${currentModule.label} · alle Themen';

    return 'Alle Kategorien gemischt';
  }

  /// Kurzform für Kopfzeilen.
  String get shortLabel =>
      subCategory?.label ?? module?.shortLabel ?? 'Gemischt';

  /// Überschrift einer Sprint-Runde, z. B. "Grundrechenarten Sprint".
  String get sprintTitle => '$shortLabel Sprint';

  /// Stabiler Schlüssel für die Persistenz, etwa von Sprint-Bestwerten.
  /// Bewusst unabhängig von Enum-Namen, damit Umbenennungen im Code keine
  /// gespeicherten Werte entwerten.
  String get storageKey {
    final topic = subCategory;
    if (topic != null) return 'topic:${topic.id}';

    final currentModule = module;
    if (currentModule != null) return 'module:${currentModule.id}';

    return 'mixed';
  }

  /// Themenfilter für die QuestionRepository. Leer heißt: keine Einschränkung.
  List<SubCategory> get subCategories {
    final topic = subCategory;
    return topic == null ? const [] : [topic];
  }

  @override
  bool operator ==(Object other) {
    return other is PracticeScope &&
        other.module == module &&
        other.subCategory == subCategory;
  }

  @override
  int get hashCode => Object.hash(module, subCategory);

  @override
  String toString() => 'PracticeScope($label)';
}
