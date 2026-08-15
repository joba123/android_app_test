import 'package:einstellungstest_trainer/data/language_questions.dart';
import 'package:einstellungstest_trainer/data/logic_questions.dart';
import 'package:einstellungstest_trainer/data/math_questions.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';

/// Zentraler Zugriff auf alle statisch hinterlegten Aufgaben.
///
/// Aktuell liegt der Content fest im Code. Sobald ein Backend oder eine lokale
/// Datenbank dazukommt, wird nur die QuestionRepository ausgetauscht – die
/// Screens bleiben unverändert.
abstract final class QuestionPool {
  static const List<Question> all = [
    ...mathQuestions,
    ...logicQuestions,
    ...languageQuestions,
  ];

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
}
