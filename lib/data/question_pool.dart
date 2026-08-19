import 'package:einstellungstest_trainer/data/generators/math_question_factory.dart';
import 'package:einstellungstest_trainer/data/english_questions.dart';
import 'package:einstellungstest_trainer/data/language_questions.dart';
import 'package:einstellungstest_trainer/data/personality_questions.dart';
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
    ...englishQuestions,
    ...personalityQuestions,
  ];

  /// Der Bestand inklusive der Pro-Aufgaben.
  ///
  /// Pro **erweitert** – der kostenlose Bestand ist immer vollstaendig
  /// enthalten. Alle Abfragen hier nehmen deshalb ein [proUnlocked]-Flag
  /// entgegen, statt an zwei Stellen unterschiedliche Listen zu fuehren.
  static const List<Question> allWithPro = [
    ...logicQuestions,
    ...languageQuestions,
    ...englishQuestions,
    ...personalityQuestions,
    ...proQuestions,
  ];

  static List<Question> pool({bool proUnlocked = false}) =>
      proUnlocked ? allWithPro : all;

  /// Wie viele Aufgaben Pro zusaetzlich mitbringt.
  static int get proExtraCount => proQuestions.length;

  /// Ob die Aufgaben dieses Moduls vollstaendig algorithmisch erzeugt werden.
  ///
  /// Bei Logik gilt das nur fuer einzelne Themen (Formen), deshalb steht das
  /// Modul hier nicht: Wer genauer fragen will, nimmt [isGeneratedTopic].
  static bool isGenerated(TrainingModule module) =>
      module == TrainingModule.math ||
      module == TrainingModule.concentration;

  /// Ob dieses Thema algorithmisch erzeugt wird.
  static bool isGeneratedTopic(SubCategory subCategory) =>
      MathQuestionFactory.supports(subCategory);

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
    if (isGenerated(module)) return 'beliebig viele Aufgaben';

    final fixed = countFor(module, proUnlocked: proUnlocked);
    // Gemischte Module – etwa Logik mit den generierten Formen – nennen den
    // festen Bestand und weisen auf den Rest hin, statt eine Zahl zu
    // behaupten, die es so nicht gibt.
    final hasGenerated =
        SubCategory.of(module).any(isGeneratedTopic);

    return hasGenerated
        ? '$fixed Aufgaben und mehr'
        : '$fixed Aufgaben';
  }

  static String describeSubCategorySize(
    SubCategory subCategory, {
    bool proUnlocked = false,
  }) {
    return isGeneratedTopic(subCategory)
        ? 'beliebig viele Aufgaben'
        : '${countForSubCategory(subCategory, proUnlocked: proUnlocked)} '
            'Aufgaben';
  }
}
