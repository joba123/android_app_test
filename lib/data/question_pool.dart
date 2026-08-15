import 'package:einstellungstest_trainer/data/language_questions.dart';
import 'package:einstellungstest_trainer/data/logic_questions.dart';
import 'package:einstellungstest_trainer/data/math_questions.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';

/// Zentraler Zugriff auf alle statisch hinterlegten Aufgaben.
///
/// Aktuell liegt der Content fest im Code. Sobald ein Backend oder eine
/// lokale Datenbank dazukommt, wird nur die QuestionRepository ausgetauscht -
/// die Screens bleiben unveraendert.
abstract final class QuestionPool {
  static const List<Question> all = [
    ...mathQuestions,
    ...logicQuestions,
    ...languageQuestions,
  ];

  static List<Question> forModule(TrainingModule module) {
    return all.where((question) => question.module == module).toList();
  }

  static List<Question> forTopics(TrainingModule module, List<String> topics) {
    if (topics.isEmpty) return forModule(module);
    return all
        .where((question) =>
            question.module == module && topics.contains(question.topic))
        .toList();
  }

  /// Alle Feinthemen eines Moduls in der Reihenfolge ihres ersten Auftretens.
  static List<String> topicsOf(TrainingModule module) {
    final topics = <String>[];
    for (final question in forModule(module)) {
      if (!topics.contains(question.topic)) topics.add(question.topic);
    }
    return topics;
  }

  static int countFor(TrainingModule module) => forModule(module).length;
}
