import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';

/// Was die App sich über eine einzelne Aufgabe merkt.
///
/// Nur für den **statischen** Bestand sinnvoll: Mathematik-Aufgaben werden
/// erzeugt und tauchen nie zweimal auf, dort wird stattdessen der Aufgabentyp
/// beobachtet – siehe [TopicMastery].
class QuestionMemory {
  const QuestionMemory({
    required this.questionId,
    required this.subCategory,
    this.wrongCount = 0,
    this.streak = 0,
    required this.lastSeen,
    required this.dueAt,
  });

  final String questionId;
  final SubCategory subCategory;

  /// Wie oft diese Aufgabe insgesamt falsch beantwortet wurde.
  final int wrongCount;

  /// Wie oft sie **seit dem letzten Fehler** richtig beantwortet wurde.
  final int streak;

  final DateTime lastSeen;

  /// Wann sie frühestens wieder gestellt werden soll.
  final DateTime dueAt;

  /// Wachsende Abstände nach jeder richtigen Antwort.
  ///
  /// Die Zahlen sind bewusst kurz gehalten: Wer sich auf einen Test in vier
  /// Wochen vorbereitet, hat nichts von einem Intervall über sechs Monate.
  /// Nach dem letzten Schritt gilt die Aufgabe als gekonnt und fällt aus der
  /// Wiederholung heraus.
  static const List<Duration> intervals = [
    Duration(days: 1),
    Duration(days: 3),
    Duration(days: 7),
    Duration(days: 16),
  ];

  /// Ab wie vielen richtigen Antworten in Folge eine Aufgabe als gekonnt gilt.
  static int get masteredStreak => intervals.length;

  bool get isMastered => streak >= masteredStreak;

  bool isDue(DateTime now) => !isMastered && !dueAt.isAfter(now);

  /// Verbucht eine Antwort und berechnet den nächsten Termin.
  ///
  /// Ein Fehler setzt den Fortschritt zurück – die Aufgabe steht danach
  /// sofort wieder an. Das ist der Kern der Sache: Falsches kommt schnell
  /// wieder, Gekonntes verschwindet.
  QuestionMemory record({required bool correct, required DateTime now}) {
    if (!correct) {
      return QuestionMemory(
        questionId: questionId,
        subCategory: subCategory,
        wrongCount: wrongCount + 1,
        streak: 0,
        lastSeen: now,
        dueAt: now,
      );
    }

    final nextStreak = streak + 1;
    final interval = nextStreak > intervals.length
        ? intervals.last
        : intervals[nextStreak - 1];

    return QuestionMemory(
      questionId: questionId,
      subCategory: subCategory,
      wrongCount: wrongCount,
      streak: nextStreak,
      lastSeen: now,
      dueAt: now.add(interval),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': questionId,
        'topic': subCategory.id,
        'wrong': wrongCount,
        'streak': streak,
        'seen': lastSeen.toUtc().toIso8601String(),
        'due': dueAt.toUtc().toIso8601String(),
      };

  static QuestionMemory? fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final subCategory = SubCategory.tryFromId(json['topic'] as String? ?? '');
    final lastSeen = DateTime.tryParse(json['seen'] as String? ?? '');
    final dueAt = DateTime.tryParse(json['due'] as String? ?? '');

    if (id == null || id.isEmpty || subCategory == null) return null;
    if (lastSeen == null || dueAt == null) return null;

    final wrong = json['wrong'];
    final streak = json['streak'];

    return QuestionMemory(
      questionId: id,
      subCategory: subCategory,
      wrongCount: wrong is int && wrong >= 0 ? wrong : 0,
      streak: streak is int && streak >= 0 ? streak : 0,
      lastSeen: lastSeen.toLocal(),
      dueAt: dueAt.toLocal(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is QuestionMemory &&
      other.questionId == questionId &&
      other.streak == streak &&
      other.wrongCount == wrongCount &&
      other.dueAt == dueAt;

  @override
  int get hashCode => Object.hash(questionId, streak, wrongCount, dueAt);
}

/// Wie sicher ein Thema sitzt.
///
/// Gilt für **alle** Module, auch Mathematik: Dort ist der Aufgabentyp das,
/// was man üben kann – die einzelne Aufgabe gibt es kein zweites Mal.
class TopicMastery {
  const TopicMastery({
    required this.subCategory,
    this.answered = 0,
    this.correct = 0,
    this.lastPracticed,
  });

  final SubCategory subCategory;
  final int answered;
  final int correct;
  final DateTime? lastPracticed;

  TrainingModule get module => subCategory.module;

  double get accuracy => answered == 0 ? 0 : correct / answered;

  /// Unter dieser Trefferquote gilt ein Thema als Schwachstelle.
  static const double weakThreshold = 0.7;

  /// So viele Antworten braucht es, bevor eine Aussage belastbar ist.
  /// Zwei Fehlversuche machen noch keine Schwäche.
  static const int minimumSample = 8;

  bool get hasEnoughData => answered >= minimumSample;

  bool get isWeak => hasEnoughData && accuracy < weakThreshold;

  TopicMastery record({
    required int addedAnswered,
    required int addedCorrect,
    required DateTime now,
  }) {
    return TopicMastery(
      subCategory: subCategory,
      answered: answered + addedAnswered,
      correct: correct + addedCorrect,
      lastPracticed: now,
    );
  }

  Map<String, dynamic> toJson() => {
        'topic': subCategory.id,
        'answered': answered,
        'correct': correct,
        'last': lastPracticed?.toUtc().toIso8601String(),
      };

  static TopicMastery? fromJson(Map<String, dynamic> json) {
    final subCategory = SubCategory.tryFromId(json['topic'] as String? ?? '');
    if (subCategory == null) return null;

    final answered = json['answered'];
    final correct = json['correct'];

    return TopicMastery(
      subCategory: subCategory,
      answered: answered is int && answered >= 0 ? answered : 0,
      correct: correct is int && correct >= 0 ? correct : 0,
      lastPracticed:
          DateTime.tryParse(json['last'] as String? ?? '')?.toLocal(),
    );
  }
}

/// Alles, was die App über die eigenen Schwachstellen weiß.
///
/// Zwei Ebenen, weil die beiden Aufgabenquellen verschieden funktionieren:
///
/// * [memories] merkt sich **einzelne** Aufgaben aus dem statischen Bestand.
/// * [topics] beobachtet **Aufgabentypen** und deckt damit auch die
///   generierte Mathematik ab.
class ReviewBook {
  const ReviewBook({this.memories = const {}, this.topics = const {}});

  final Map<String, QuestionMemory> memories;
  final Map<SubCategory, TopicMastery> topics;

  const ReviewBook.empty() : memories = const {}, topics = const {};

  TopicMastery masteryOf(SubCategory subCategory) =>
      topics[subCategory] ?? TopicMastery(subCategory: subCategory);

  /// Fällige Aufgaben, dringendste zuerst.
  ///
  /// Sortiert nach Fehlerzahl, dann nach Fälligkeit: Was oft falsch war und
  /// lange liegt, kommt zuerst.
  List<QuestionMemory> dueMemories(DateTime now) {
    final due = memories.values.where((entry) => entry.isDue(now)).toList()
      ..sort((a, b) {
        final byWrong = b.wrongCount.compareTo(a.wrongCount);
        return byWrong != 0 ? byWrong : a.dueAt.compareTo(b.dueAt);
      });

    return due;
  }

  /// Themen mit zu niedriger Trefferquote, schwächstes zuerst.
  List<TopicMastery> weakTopics() {
    final weak = topics.values.where((entry) => entry.isWeak).toList()
      ..sort((a, b) => a.accuracy.compareTo(b.accuracy));

    return weak;
  }

  /// Das eine Thema, das die Startseite vorschlägt – oder `null`, wenn es
  /// noch keine belastbare Schwachstelle gibt.
  TopicMastery? get weakestTopic {
    final weak = weakTopics();
    return weak.isEmpty ? null : weak.first;
  }

  /// Wie viele Aufgaben gerade zur Wiederholung anstehen.
  int dueCount(DateTime now) => dueMemories(now).length;

  /// Ob sich ein Wiederholungs-Training überhaupt lohnt.
  bool hasWork(DateTime now) =>
      dueMemories(now).isNotEmpty || weakTopics().isNotEmpty;

  /// Verbucht eine abgeschlossene Sitzung.
  ///
  /// Übersprungene Aufgaben werden ignoriert: Wer nicht geantwortet hat, hat
  /// nichts gezeigt – weder Können noch Nichtkönnen.
  ///
  /// Aufgaben ohne Kennung (aus dem Cloud-Abgleich rekonstruiert) zahlen nur
  /// auf die Themen-Ebene ein.
  ReviewBook applySession(TrainingSession session, {DateTime? at}) {
    final now = at ?? DateTime.now();

    final nextMemories = Map<String, QuestionMemory>.from(memories);
    final nextTopics = Map<SubCategory, TopicMastery>.from(topics);

    for (final result in session.results) {
      if (!result.answered) continue;

      final subCategory = result.subCategory;

      nextTopics[subCategory] = (nextTopics[subCategory] ??
              TopicMastery(subCategory: subCategory))
          .record(
        addedAnswered: 1,
        addedCorrect: result.correct ? 1 : 0,
        now: now,
      );

      // Generierte Mathematik-Aufgaben tragen zwar eine Kennung, aber jede
      // nur ein einziges Mal – sie zu merken brächte nichts.
      if (result.questionId.isEmpty || _isGeneratedId(result.questionId)) {
        continue;
      }

      final existing = nextMemories[result.questionId] ??
          QuestionMemory(
            questionId: result.questionId,
            subCategory: subCategory,
            lastSeen: now,
            dueAt: now,
          );

      nextMemories[result.questionId] =
          existing.record(correct: result.correct, now: now);
    }

    return ReviewBook(memories: nextMemories, topics: nextTopics);
  }

  /// Kennungen der Aufgabenfabrik, Muster `gen_<thema>_g<n>`.
  ///
  /// Generierte Aufgaben gibt es kein zweites Mal – sie zu merken waere
  /// sinnlos, die Wiederholung fände die Aufgabe nie wieder. Das alte
  /// Praefix `math_` bleibt erkannt, damit gespeicherte Buecher aus
  /// frueheren Versionen weiter stimmen.
  static bool _isGeneratedId(String id) =>
      id.startsWith('gen_') || id.startsWith('math_');

  Map<String, dynamic> toJson() => {
        'memories': [for (final entry in memories.values) entry.toJson()],
        'topics': [for (final entry in topics.values) entry.toJson()],
      };

  factory ReviewBook.fromJson(Map<String, dynamic> json) {
    final memories = <String, QuestionMemory>{};
    final rawMemories = json['memories'];
    if (rawMemories is List) {
      for (final entry in rawMemories) {
        if (entry is Map<String, dynamic>) {
          final memory = QuestionMemory.fromJson(entry);
          if (memory != null) memories[memory.questionId] = memory;
        }
      }
    }

    final topics = <SubCategory, TopicMastery>{};
    final rawTopics = json['topics'];
    if (rawTopics is List) {
      for (final entry in rawTopics) {
        if (entry is Map<String, dynamic>) {
          final mastery = TopicMastery.fromJson(entry);
          if (mastery != null) topics[mastery.subCategory] = mastery;
        }
      }
    }

    return ReviewBook(memories: memories, topics: topics);
  }
}
