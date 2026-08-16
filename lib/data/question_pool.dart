import 'package:einstellungstest_trainer/data/generators/math_question_factory.dart';
import 'package:einstellungstest_trainer/data/language_questions.dart';
import 'package:einstellungstest_trainer/data/logic_questions.dart';
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
  static const List<Question> all = [
    ...logicQuestions,
    ...languageQuestions,
  ];

  /// Ob die Aufgaben dieses Moduls algorithmisch erzeugt werden.
  static bool isGenerated(TrainingModule module) =>
      module == TrainingModule.math;

  static List<Question> forModule(TrainingModule module) {
    return all.where((question) => question.module == module).toList();
  }

  static List<Question> forSubCategory(SubCategory subCategory) {
    return all
        .where((question) => question.subCategory == subCategory)
        .toList();
  }

  /// Aufgaben eines Moduls, optional auf bestimmte Unterkategorien begrenzt.
  /// Eine leere Liste bedeutet: keine Einschränkung.
  static List<Question> forSubCategories(
    TrainingModule module,
    List<SubCategory> subCategories,
  ) {
    if (subCategories.isEmpty) return forModule(module);
    return all
        .where((question) =>
            question.module == module &&
            subCategories.contains(question.subCategory))
        .toList();
  }

  static int countFor(TrainingModule module) => forModule(module).length;

  static int countForSubCategory(SubCategory subCategory) =>
      forSubCategory(subCategory).length;

  /// Beschreibung des Umfangs für die Oberfläche. Bei generierten Modulen
  /// wäre eine Zahl irreführend.
  static String describeSize(TrainingModule module) {
    return isGenerated(module)
        ? 'beliebig viele Aufgaben'
        : '${countFor(module)} Aufgaben';
  }

  static String describeSubCategorySize(SubCategory subCategory) {
    return isGenerated(subCategory.module)
        ? 'beliebig viele Aufgaben'
        : '${countForSubCategory(subCategory)} Aufgaben';
  }
}
