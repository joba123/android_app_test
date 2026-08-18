import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/review_book.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';

/// Woraus der Tagesvorschlag entstanden ist.
///
/// Bestimmt, wie der Vorschlag begründet wird – und die Begründung ist der
/// Grund, warum man ihm folgt.
enum PlanReason {
  /// Noch nichts geübt: eine kurze Runde quer durch alles.
  firstRound,

  /// Fehler warten auf Wiederholung.
  reviewDue,

  /// Ein Thema liegt unter der Schwelle.
  weakTopic,

  /// Nichts Auffälliges – gemischt weiterüben.
  keepGoing,
}

/// Der eine Vorschlag, den die Startseite macht.
///
/// Die Startseite beantwortet die Frage „was soll ich heute tun?" mit **einem**
/// Vorschlag statt mit einer Liste von Möglichkeiten. Alles, was der Nutzer
/// dafür wissen muss, steckt hier drin – Titel, Begründung und die zwei, drei
/// Zahlen, die den Aufwand einschätzbar machen.
class TodaysPlan {
  const TodaysPlan({
    required this.scope,
    required this.length,
    required this.reason,
    this.topicAccuracy,
    this.dueErrors = 0,
    this.estimatedMinutes = 0,
  });

  final PracticeScope scope;
  final int length;
  final PlanReason reason;

  /// Aktuelle Trefferquote des vorgeschlagenen Themas, falls es eines gibt.
  final double? topicAccuracy;

  /// Wie viele Fehler auf Wiederholung warten.
  final int dueErrors;

  final int estimatedMinutes;

  /// Umfang der allerersten Runde. Kurz genug, dass niemand abbricht, lang
  /// genug, dass die App danach etwas über den Nutzer weiß.
  static const int firstRoundLength = 10;

  /// Umfang einer normalen Empfehlung.
  static const int regularLength = 20;

  /// Angenommene Zeit je Aufgabe, solange nichts Gemessenes vorliegt.
  static const Duration assumedPace = Duration(seconds: 25);

  /// Die Überschrift der Karte – kurz, ohne Beiwerk.
  String get title => switch (reason) {
        PlanReason.firstRound => '$length Aufgaben zum Einstieg',
        PlanReason.reviewDue => '$length Aufgaben – deine Fehler',
        PlanReason.weakTopic => '$length Aufgaben ${scope.shortLabel}',
        PlanReason.keepGoing => '$length Aufgaben gemischt',
      };

  /// Die Begründung in einem Halbsatz. Kein ganzer Satz, kein Punkt.
  String get reasonLabel => switch (reason) {
        PlanReason.firstRound => 'quer durch alle drei Bereiche',
        PlanReason.reviewDue => 'was zuletzt schiefging',
        PlanReason.weakTopic => 'dein schwächstes Thema',
        PlanReason.keepGoing => 'aus allen Bereichen',
      };

  /// Baut den Vorschlag aus dem, was über den Nutzer bekannt ist.
  ///
  /// Die Reihenfolge ist die Rangfolge: Wer noch nie geübt hat, bekommt die
  /// Einstiegsrunde. Danach gehen Fehler vor Schwachstellen, und Schwachstellen
  /// vor „irgendwas".
  factory TodaysPlan.from({
    required ReviewBook book,
    required int totalAnswered,
    required DateTime now,
    Duration? measuredPace,
  }) {
    final pace = measuredPace == null || measuredPace == Duration.zero
        ? assumedPace
        : measuredPace;

    int minutesFor(int count) {
      final seconds = pace.inSeconds * count;
      return seconds < 60 ? 1 : (seconds / 60).round();
    }

    if (totalAnswered == 0) {
      return TodaysPlan(
        scope: const PracticeScope.mixed(),
        length: firstRoundLength,
        reason: PlanReason.firstRound,
        estimatedMinutes: minutesFor(firstRoundLength),
      );
    }

    final due = book.dueCount(now);
    if (due >= _reviewThreshold) {
      final length = due < regularLength ? due : regularLength;
      return TodaysPlan(
        scope: const PracticeScope.review(),
        length: length,
        reason: PlanReason.reviewDue,
        dueErrors: due,
        estimatedMinutes: minutesFor(length),
      );
    }

    final weakest = book.weakestTopic;
    if (weakest != null) {
      return TodaysPlan(
        scope: PracticeScope.subCategory(weakest.subCategory),
        length: regularLength,
        reason: PlanReason.weakTopic,
        topicAccuracy: weakest.accuracy,
        dueErrors: due,
        estimatedMinutes: minutesFor(regularLength),
      );
    }

    return TodaysPlan(
      scope: const PracticeScope.mixed(),
      length: regularLength,
      reason: PlanReason.keepGoing,
      dueErrors: due,
      estimatedMinutes: minutesFor(regularLength),
    );
  }

  /// Ab so vielen fälligen Fehlern lohnt eine eigene Wiederholungsrunde.
  /// Darunter reicht es, sie beiläufig mitlaufen zu lassen.
  static const int _reviewThreshold = 5;

  /// Nur für Themen sinnvoll: Wie sicher das Thema aktuell sitzt.
  String? get accuracyLabel {
    final accuracy = topicAccuracy;
    return accuracy == null ? null : '${(accuracy * 100).round()} %';
  }
}

/// Die Kennzahlen, die unter dem Vorschlag stehen.
///
/// Höchstens drei, und nur solche, die tatsächlich etwas aussagen – eine
/// Kachel mit „0 offene Fehler" wäre kein Wert, sondern Füllmaterial.
class PlanFacts {
  const PlanFacts(this.entries);

  final List<(String value, String label)> entries;

  factory PlanFacts.of(TodaysPlan plan) {
    final entries = <(String, String)>[];

    final accuracy = plan.accuracyLabel;
    if (accuracy != null) entries.add((accuracy, 'aktuell'));

    if (plan.dueErrors > 0) {
      entries.add(('${plan.dueErrors}', 'offene Fehler'));
    }

    entries.add(('~${plan.estimatedMinutes}', 'Minuten'));

    return PlanFacts(entries);
  }
}

/// Kurzform eines Themas für die Modulzeilen.
extension SubCategoryShort on SubCategory {
  String get shortLabel => label;
}
