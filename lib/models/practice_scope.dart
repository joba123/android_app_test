import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';

/// Was in einer Übungsrunde trainiert wird.
///
/// Drei Fälle, über die benannten Konstruktoren erzeugt:
///
/// * [PracticeScope.mixed] – alle Kategorien gemischt
/// * [PracticeScope.module] – ein ganzes Modul, alle seine Themen
/// * [PracticeScope.subCategory] – ein einzelnes Thema
/// * [PracticeScope.review] – gezielte Wiederholung der eigenen Fehler
///
/// Der Umweg über die Konstruktoren stellt sicher, dass Modul und
/// Unterkategorie nicht auseinanderlaufen können: Wer ein Thema wählt, bekommt
/// dessen Modul automatisch mitgesetzt.
class PracticeScope {
  const PracticeScope.mixed()
      : module = null,
        subCategory = null,
        isReview = false;

  const PracticeScope.module(TrainingModule this.module)
      : subCategory = null,
        isReview = false;

  PracticeScope.subCategory(SubCategory this.subCategory)
      : module = subCategory.module,
        isReview = false;

  /// Wiederholung: Die Aufgaben kommen nicht aus einem Thema, sondern aus
  /// dem, was zuletzt schiefging.
  const PracticeScope.review()
      : module = null,
        subCategory = null,
        isReview = true;

  /// `null` bedeutet: modulübergreifend gemischt.
  final TrainingModule? module;

  /// `null` bedeutet: keine Einschränkung auf ein einzelnes Thema.
  final SubCategory? subCategory;

  /// Ob die Aufgaben aus dem Wiederholungsbestand gezogen werden.
  final bool isReview;

  bool get isMixed => module == null && !isReview;

  /// Ausführliche Bezeichnung für Auswahl und Auswertung.
  String get label {
    if (isReview) return 'Deine Fehler';

    final topic = subCategory;
    if (topic != null) return '${topic.module.label} · ${topic.label}';

    final currentModule = module;
    if (currentModule != null) return '${currentModule.label} · alle Themen';

    return 'Alle Kategorien gemischt';
  }

  /// Kurzform für Kopfzeilen.
  String get shortLabel => isReview
      ? 'Deine Fehler'
      : subCategory?.label ?? module?.shortLabel ?? 'Gemischt';

  /// Überschrift einer Sprint-Runde, z. B. "Grundrechenarten Sprint".
  String get sprintTitle => '$shortLabel Sprint';

  /// Stabiler Schlüssel für die Persistenz, etwa von Sprint-Bestwerten.
  /// Bewusst unabhängig von Enum-Namen, damit Umbenennungen im Code keine
  /// gespeicherten Werte entwerten.
  String get storageKey {
    if (isReview) return 'review';

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
        other.subCategory == subCategory &&
        other.isReview == isReview;
  }

  @override
  int get hashCode => Object.hash(module, subCategory, isReview);

  @override
  String toString() => 'PracticeScope($label)';
}
