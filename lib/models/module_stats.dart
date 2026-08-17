import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';

/// Dauerhaft gespeicherter Lernfortschritt pro Modul.
class ModuleStats {
  const ModuleStats({
    required this.module,
    this.answered = 0,
    this.correct = 0,
    this.sessionsCompleted = 0,
  });

  final TrainingModule module;
  final int answered;
  final int correct;
  final int sessionsCompleted;

  double get accuracy => answered == 0 ? 0 : correct / answered;

  ModuleStats merge({
    int addedAnswered = 0,
    int addedCorrect = 0,
    bool completedSession = false,
  }) {
    return ModuleStats(
      module: module,
      answered: answered + addedAnswered,
      correct: correct + addedCorrect,
      sessionsCompleted: sessionsCompleted + (completedSession ? 1 : 0),
    );
  }

  Map<String, dynamic> toJson() => {
        'module': module.id,
        'answered': answered,
        'correct': correct,
        'sessionsCompleted': sessionsCompleted,
      };

  factory ModuleStats.fromJson(Map<String, dynamic> json) {
    return ModuleStats(
      module: TrainingModule.fromId(json['module'] as String? ?? 'math'),
      answered: json['answered'] as int? ?? 0,
      correct: json['correct'] as int? ?? 0,
      sessionsCompleted: json['sessionsCompleted'] as int? ?? 0,
    );
  }
}

/// Gesamtfortschritt über alle Module.
class TrainingStats {
  const TrainingStats({
    required this.perModule,
    this.sprintBests = const {},
  });

  final Map<TrainingModule, ModuleStats> perModule;

  /// Beste Sprint-Ergebnisse, je Aufgabentyp bzw. Modul.
  ///
  /// Schlüssel ist [PracticeScope.storageKey]. Bewusst nicht in [ModuleStats]:
  /// Ein Sprint über "Grundrechenarten" und einer über das ganze Modul
  /// Mathematik sind nicht dieselbe Disziplin und dürfen sich keinen Bestwert
  /// teilen.
  final Map<String, int> sprintBests;

  factory TrainingStats.empty() {
    return TrainingStats(
      perModule: {
        for (final module in TrainingModule.values) module: ModuleStats(module: module),
      },
    );
  }

  ModuleStats forModule(TrainingModule module) =>
      perModule[module] ?? ModuleStats(module: module);

  int get totalAnswered =>
      perModule.values.fold(0, (sum, stats) => sum + stats.answered);

  int get totalCorrect =>
      perModule.values.fold(0, (sum, stats) => sum + stats.correct);

  double get accuracy => totalAnswered == 0 ? 0 : totalCorrect / totalAnswered;

  /// Bestwert für genau diesen Umfang.
  int bestSprint(PracticeScope scope) => sprintBests[scope.storageKey] ?? 0;

  /// Bester Sprint innerhalb eines Moduls – über das ganze Modul und über
  /// jeden seiner Aufgabentypen hinweg.
  int bestSprintInModule(TrainingModule module) {
    var best = bestSprint(PracticeScope.module(module));
    for (final subCategory in SubCategory.of(module)) {
      final value = bestSprint(PracticeScope.subCategory(subCategory));
      if (value > best) best = value;
    }
    return best;
  }

  TrainingStats withModule(ModuleStats stats) {
    return TrainingStats(
      perModule: {...perModule, stats.module: stats},
      sprintBests: sprintBests,
    );
  }

  /// Übernimmt ein Sprint-Ergebnis, wenn es den bisherigen Bestwert übertrifft.
  TrainingStats withSprintResult(PracticeScope scope, int score) {
    if (score <= bestSprint(scope)) return this;

    return TrainingStats(
      perModule: perModule,
      sprintBests: {...sprintBests, scope.storageKey: score},
    );
  }
}
