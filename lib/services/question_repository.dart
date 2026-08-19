import 'dart:math';

import 'package:einstellungstest_trainer/data/generators/math_question_factory.dart';
import 'package:einstellungstest_trainer/data/question_pool.dart';
import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/review_book.dart';
import 'package:einstellungstest_trainer/models/simulation.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';

/// Liefert Aufgaben – egal aus welcher Quelle.
///
/// Hier läuft der Unterschied zwischen generiertem und handgeschriebenem
/// Content zusammen: Mathematik kommt aus der [MathQuestionFactory],
/// Logik und Sprache aus dem statischen [QuestionPool]. Screens und Controller
/// merken davon nichts.
///
/// Bei Multiple Choice werden zusätzlich die Antwortoptionen gemischt, damit
/// sich niemand eine Position merken kann. Aufgaben mit Zahleneingabe bleiben
/// unverändert – dort gibt es nichts zu mischen.
///
/// [random] lässt sich in Tests mit einem festen Seed überschreiben; der Seed
/// wird an die Generatoren durchgereicht.
class QuestionRepository {
  QuestionRepository({
    Random? random,
    MathQuestionFactory? mathFactory,
    this.proUnlocked = false,
  })  : _random = random ?? Random(),
        _math = mathFactory ?? MathQuestionFactory(random: random);

  final Random _random;
  final MathQuestionFactory _math;

  /// Ob der Pro-Aufgabenbestand mitgezogen wird.
  ///
  /// Sitzt am Repository und nicht an den Aufrufstellen: So kann kein Screen
  /// vergessen, die Freischaltung zu beruecksichtigen. Mathematik ist davon
  /// unberuehrt – generierte Aufgaben gibt es ohnehin unbegrenzt.
  final bool proUnlocked;

  /// Standardumfang einer Übungsrunde.
  static const int practiceLength = 10;

  /// Länge der Sprint-Warteschlange. 60 Sekunden reichen realistisch für
  /// deutlich weniger Aufgaben – der Puffer verhindert nur, dass sie ausgeht.
  static const int sprintQueueLength = 40;

  List<Question> draw({
    required TrainingModule module,
    required int count,
    List<SubCategory> subCategories = const [],
    Difficulty? difficulty,
  }) {
    if (count <= 0) return const [];

    // Ein Modul kann beides fuehren: Logik hat feste Aufgaben und die
    // generierten Formen. Deshalb wird die Anfrage aufgeteilt und
    // anschliessend zusammengelegt.
    final topics = subCategories.isEmpty
        ? SubCategory.of(module)
        : subCategories;
    final generated = topics.where(QuestionPool.isGeneratedTopic).toList();
    final fixed =
        topics.where((topic) => !QuestionPool.isGeneratedTopic(topic)).toList();

    if (fixed.isEmpty) {
      return _math.generate(
        count: count,
        subCategories: generated,
        difficulty: difficulty,
      );
    }

    // Der generierte Anteil richtet sich nach der Zahl der Themen: Bei einem
    // generierten von vier Themen kommt rund ein Viertel aus der Fabrik.
    final generatedCount = generated.isEmpty
        ? 0
        : (count * generated.length / topics.length).round();

    final pool = _filterByDifficulty(
      QuestionPool.forSubCategories(module, fixed, proUnlocked: proUnlocked),
      difficulty,
    )..shuffle(_random);

    final fromPool = count - generatedCount;
    final take = fromPool < pool.length ? fromPool : pool.length;
    final drawn = [
      for (final question in pool.take(take)) _shuffleOptions(question),
      if (generated.isNotEmpty)
        // Was der feste Bestand nicht hergibt, fuellt die Fabrik auf.
        ..._math.generate(
          count: count - take,
          subCategories: generated,
          difficulty: difficulty,
        ),
    ];

    return drawn..shuffle(_random);
  }

  /// Schränkt einen statischen Bestand auf eine Schwierigkeit ein.
  ///
  /// Gibt der Bestand die gewünschte Stufe kaum her, wird die Einschränkung
  /// fallen gelassen: Eine Runde aus drei Aufgaben wäre nutzloser als eine
  /// gemischte. Bei generierten Aufgaben stellt sich die Frage nicht – dort
  /// entsteht jede Stufe in beliebiger Menge.
  static const int _minimumFilteredPool = 5;

  List<Question> _filterByDifficulty(
    List<Question> pool,
    Difficulty? difficulty,
  ) {
    if (difficulty == null) return pool;

    final filtered = pool
        .where((question) => question.difficulty == difficulty)
        .toList();

    return filtered.length >= _minimumFilteredPool ? filtered : pool;
  }

  /// Übungsmodus: begrenzte Runde ohne Zeitdruck.
  ///
  /// Bei statischem Content kann das Ergebnis kürzer ausfallen als [count],
  /// wenn das gewählte Thema weniger Aufgaben hergibt.
  List<Question> drawForScope(
    PracticeScope scope, {
    int count = practiceLength,
    Difficulty? difficulty,
    ReviewBook? reviewBook,
  }) {
    if (scope.isReview) {
      return drawReview(reviewBook ?? const ReviewBook.empty(), count: count);
    }

    final module = scope.module;
    if (module == null) {
      return drawMixed(count: count, difficulty: difficulty);
    }

    return draw(
      module: module,
      count: count,
      subCategories: scope.subCategories,
      difficulty: difficulty,
    );
  }

  /// Wiederholung: die eigenen Fehler, nicht der Zufall.
  ///
  /// Zwei Quellen, in dieser Reihenfolge:
  ///
  /// 1. **Fällige Einzelaufgaben** aus dem statischen Bestand – dringendste
  ///    zuerst, also was oft falsch war und lange liegt.
  /// 2. **Schwache Themen**, aufgefüllt mit frisch gezogenen Aufgaben. Nur so
  ///    kommt auch Mathematik vor: Dort gibt es die alte Aufgabe nicht mehr,
  ///    wohl aber beliebig viele neue desselben Typs.
  ///
  /// Bleibt danach Platz, wird mit den schwächsten Themen weiter aufgefüllt.
  /// Ist gar nichts bekannt, kommt eine gemischte Runde zurück – eine leere
  /// Runde waere die schlechtere Antwort.
  List<Question> drawReview(
    ReviewBook book, {
    int count = practiceLength,
  }) {
    if (count <= 0) return const [];

    final byId = {
      for (final question in QuestionPool.pool(proUnlocked: proUnlocked))
        question.id: question,
    };

    final questions = <Question>[];
    final usedIds = <String>{};

    // 1. Fällige Einzelaufgaben.
    for (final memory in book.dueMemories(DateTime.now())) {
      if (questions.length >= count) break;

      final question = byId[memory.questionId];
      // Eine Aufgabe kann inzwischen entfernt oder hinter Pro gewandert sein.
      if (question == null || !usedIds.add(question.id)) continue;

      questions.add(_shuffleOptions(question));
    }

    // 2. Schwache Themen auffüllen.
    final weak = book.weakTopics();
    for (final topic in weak) {
      if (questions.length >= count) break;

      final remaining = count - questions.length;
      // Nicht alles auf ein Thema setzen, solange weitere Schwachstellen
      // warten: Die Runde soll die Schwächen abbilden, nicht nur die groesste.
      final share = weak.length == 1
          ? remaining
          : (remaining / weak.length).ceil().clamp(1, remaining);

      for (final question in draw(
        module: topic.module,
        count: share,
        subCategories: [topic.subCategory],
      )) {
        if (questions.length >= count) break;
        if (!usedIds.add(question.id)) continue;

        questions.add(question);
      }
    }

    if (questions.isEmpty) return drawMixed(count: count);

    return questions..shuffle(_random);
  }

  /// Misch-Modus: Aufgaben aus allen Modulen, möglichst gleichmäßig verteilt
  /// und anschließend durchgemischt.
  List<Question> drawMixed({
    required int count,
    Difficulty? difficulty,
  }) {
    if (count <= 0) return const [];

    const modules = TrainingModule.values;
    final shares = {for (final module in modules) module: 0};
    for (var index = 0; index < count; index++) {
      final module = modules[index % modules.length];
      shares[module] = shares[module]! + 1;
    }

    final drawn = [
      for (final entry in shares.entries)
        ...draw(
          module: entry.key,
          count: entry.value,
          difficulty: difficulty,
        ),
    ];

    return drawn..shuffle(_random);
  }

  /// Sprint-Modus: eine Warteschlange fester Länge für den gewählten
  /// Aufgabentyp.
  ///
  /// Die Länge ist großzügig bemessen, damit in 60 Sekunden garantiert nicht
  /// die Aufgaben ausgehen. Bei statischem Content mit wenigen Aufgaben wird
  /// der Pool dafür mehrfach – jeweils neu gemischt – angehängt; einzelne
  /// Aufgaben können in einer Runde dann wiederkehren.
  List<Question> drawSprintQueue(PracticeScope scope) {
    final module = scope.module;
    if (module == null) return drawMixed(count: sprintQueueLength);

    if (QuestionPool.isGenerated(module)) {
      return _math.generate(
        count: sprintQueueLength,
        // Ohne Themenangabe die generierten Themen **dieses** Moduls: Die
        // Fabrik bedient inzwischen mehrere Module, eine leere Liste hiesse
        // dort „alles" und wuerde einen Mathe-Sprint mit Formen fuellen.
        subCategories: scope.subCategories.isEmpty
            ? SubCategory.of(module)
                .where(QuestionPool.isGeneratedTopic)
                .toList()
            : scope.subCategories,
      );
    }

    final pool = QuestionPool.forSubCategories(
      module,
      scope.subCategories,
      proUnlocked: proUnlocked,
    );
    if (pool.isEmpty) return const [];

    final queue = <Question>[];
    while (queue.length < sprintQueueLength) {
      final round = [...pool]..shuffle(_random);
      queue.addAll(round.map(_shuffleOptions));
    }

    return queue.take(sprintQueueLength).toList();
  }

  /// Testsimulation: Aufgaben für genau einen Testteil.
  ///
  /// Ein Teil kann mehrere Module berühren (etwa "Schlussfolgerungen &
  /// Wortschatz"). In dem Fall wird die Aufgabenzahl gleichmäßig auf die
  /// beteiligten Module verteilt und anschließend gemischt.
  List<Question> drawForPart(SimulationPart part) {
    final byModule = <TrainingModule, List<SubCategory>>{};
    for (final subCategory in part.subCategories) {
      byModule.putIfAbsent(subCategory.module, () => []).add(subCategory);
    }

    if (byModule.length == 1) {
      final entry = byModule.entries.first;
      return draw(
        module: entry.key,
        count: part.questionCount,
        subCategories: entry.value,
      );
    }

    final modules = byModule.keys.toList();
    final shares = {for (final module in modules) module: 0};
    for (var index = 0; index < part.questionCount; index++) {
      final module = modules[index % modules.length];
      shares[module] = shares[module]! + 1;
    }

    final drawn = [
      for (final entry in byModule.entries)
        ...draw(
          module: entry.key,
          count: shares[entry.key]!,
          subCategories: entry.value,
        ),
    ];

    return drawn..shuffle(_random);
  }

  Question _shuffleOptions(Question question) {
    final format = question.answer;
    if (format is! MultipleChoice) return question;

    final order = List<int>.generate(format.options.length, (index) => index)
      ..shuffle(_random);
    return question.copyWith(answer: format.reordered(order));
  }
}
