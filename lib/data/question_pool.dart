import 'package:einstellungstest_trainer/data/generators/math_question_factory.dart';
import 'package:einstellungstest_trainer/data/language_questions.dart';
import 'package:einstellungstest_trainer/data/logic_questions.dart';
import 'package:einstellungstest_trainer/data/pro_questions.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';

/// Zugriff auf den handgeschriebenen Aufgabenbestand.
///
/// Die App bezieht ihre Aufgaben aus zwei Quellen:
///
/// * **Mathematik** wird zur Laufzeit generiert ([MathQuestionFactory]) und
///   taucht deshalb hier nicht auf – der Pool ist dort unbegrenzt.
/// * **Logik und Sprache** kommen aus den statischen Listen in diesem Paket.
///
/// Wer Aufgaben ziehen will, geht über die QuestionRepository; sie kennt beide
/// Quellen und ist der einzige Ort, an dem der Unterschied eine Rolle spielt.
abstract final class QuestionPool {
  /// Der kostenlose Bestand.
  static const List<Question> all = [
    ...logicQuestions,
    ...languageQuestions,
  ];

  /// Der Bestand inklusive der Pro-Aufgaben.
  ///
  /// Pro **erweitert** – der kostenlose Bestand ist immer vollstaendig
  /// enthalten. Alle Abfragen hier nehmen deshalb ein [proUnlocked]-Flag
  /// entgegen, statt an zwei Stellen unterschiedliche Listen zu fuehren.
  static const List<Question> allWithPro = [
    ...logicQuestions,
    ...languageQuestions,
    ...proQuestions,
  ];

  static List<Question> pool({bool proUnlocked = false}) =>
      proUnlocked ? allWithPro : all;

  /// Wie viele Aufgaben Pro zusaetzlich mitbringt.
  static int get proExtraCount => proQuestions.length;

  /// Ob die Aufgaben dieses Moduls algorithmisch erzeugt werden.
  static bool isGenerated(TrainingModule module) =>
      module == TrainingModule.math;

  static List<Question> forModule(
    TrainingModule module, {
    bool proUnlocked = false,
  }) {
    return pool(proUnlocked: proUnlocked)
        .where((question) => question.module == module)
        .toList();
  }

  static List<Question> forSubCategory(
    SubCategory subCategory, {
    bool proUnlocked = false,
  }) {
    return pool(proUnlocked: proUnlocked)
        .where((question) => question.subCategory == subCategory)
        .toList();
  }

  /// Aufgaben eines Moduls, optional auf bestimmte Unterkategorien begrenzt.
  /// Eine leere Liste bedeutet: keine Einschränkung.
  static List<Question> forSubCategories(
    TrainingModule module,
    List<SubCategory> subCategories, {
    bool proUnlocked = false,
  }) {
    if (subCategories.isEmpty) {
      return forModule(module, proUnlocked: proUnlocked);
    }
    return pool(proUnlocked: proUnlocked)
        .where((question) =>
            question.module == module &&
            subCategories.contains(question.subCategory))
        .toList();
  }

  static int countFor(TrainingModule module, {bool proUnlocked = false}) =>
      forModule(module, proUnlocked: proUnlocked).length;

  static int countForSubCategory(
    SubCategory subCategory, {
    bool proUnlocked = false,
  }) =>
      forSubCategory(subCategory, proUnlocked: proUnlocked).length;

  /// Beschreibung des Umfangs für die Oberfläche. Bei generierten Modulen
  /// wäre eine Zahl irreführend.
  static String describeSize(TrainingModule module, {bool proUnlocked = false}) {
    return isGenerated(module)
        ? 'beliebig viele Aufgaben'
        : '${countFor(module, proUnlocked: proUnlocked)} Aufgaben';
  }

  static String describeSubCategorySize(
    SubCategory subCategory, {
    bool proUnlocked = false,
  }) {
    return isGenerated(subCategory.module)
        ? 'beliebig viele Aufgaben'
        : '${countForSubCategory(subCategory, proUnlocked: proUnlocked)} '
            'Aufgaben';
  }
}
