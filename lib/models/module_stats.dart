import 'package:einstellungstest_trainer/models/training_module.dart';

/// Dauerhaft gespeicherter Lernfortschritt pro Modul.
class ModuleStats {
  const ModuleStats({
    required this.module,
    this.answered = 0,
    this.correct = 0,
    this.bestSprintScore = 0,
    this.sessionsCompleted = 0,
  });

  final TrainingModule module;
  final int answered;
  final int correct;

  /// Bestleistung im 60-Sekunden-Sprint: Anzahl richtiger Antworten.
  final int bestSprintScore;

  final int sessionsCompleted;

  double get accuracy => answered == 0 ? 0 : correct / answered;

  ModuleStats merge({
    int addedAnswered = 0,
    int addedCorrect = 0,
    int? sprintScore,
    bool completedSession = false,
  }) {
    return ModuleStats(
      module: module,
      answered: answered + addedAnswered,
      correct: correct + addedCorrect,
      bestSprintScore: sprintScore != null && sprintScore > bestSprintScore
          ? sprintScore
          : bestSprintScore,
      sessionsCompleted: sessionsCompleted + (completedSession ? 1 : 0),
    );
  }

  Map<String, dynamic> toJson() => {
        'module': module.id,
        'answered': answered,
        'correct': correct,
        'bestSprintScore': bestSprintScore,
        'sessionsCompleted': sessionsCompleted,
      };

  factory ModuleStats.fromJson(Map<String, dynamic> json) {
    return ModuleStats(
      module: TrainingModule.fromId(json['module'] as String? ?? 'math'),
      answered: json['answered'] as int? ?? 0,
      correct: json['correct'] as int? ?? 0,
      bestSprintScore: json['bestSprintScore'] as int? ?? 0,
      sessionsCompleted: json['sessionsCompleted'] as int? ?? 0,
    );
  }
}

/// Gesamtfortschritt ueber alle Module.
class TrainingStats {
  const TrainingStats({required this.perModule});

  final Map<TrainingModule, ModuleStats> perModule;

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

  TrainingStats withModule(ModuleStats stats) {
    return TrainingStats(
      perModule: {...perModule, stats.module: stats},
    );
  }
}
