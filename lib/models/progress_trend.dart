import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';

/// Ein Zeitabschnitt im Verlauf – ein Tag oder eine Woche.
class TrendPoint {
  const TrendPoint({
    required this.start,
    required this.answered,
    required this.correct,
    required this.timeSpent,
    required this.sessions,
  });

  /// Beginn des Abschnitts (Tag bzw. Wochenmontag), auf Mitternacht gesetzt.
  final DateTime start;

  final int answered;
  final int correct;
  final Duration timeSpent;
  final int sessions;

  bool get isEmpty => answered == 0;

  double get accuracy => answered == 0 ? 0 : correct / answered;

  Duration get averageTimePerQuestion => answered == 0
      ? Duration.zero
      : Duration(milliseconds: timeSpent.inMilliseconds ~/ answered);
}

/// Wie sich zwei gleich lange Zeiträume zueinander verhalten.
///
/// Das ist die Frage, die vor einer Prüfung zählt: nicht „wie gut bin ich",
/// sondern „bin ich besser geworden".
class TrendComparison {
  const TrendComparison({required this.current, required this.previous});

  final TrendPoint current;
  final TrendPoint previous;

  /// Ob überhaupt ein Vergleich möglich ist. Ohne Daten in **beiden**
  /// Zeiträumen wäre jede Aussage über eine Entwicklung erfunden.
  bool get isComparable => !current.isEmpty && !previous.isEmpty;

  /// Unterschied in Prozentpunkten, positiv heißt besser geworden.
  double get accuracyDelta => current.accuracy - previous.accuracy;

  /// Ab wann eine Veränderung als solche gilt. Darunter ist es Rauschen –
  /// eine Runde mit drei Aufgaben mehr richtig soll keinen Trend behaupten.
  static const double meaningfulDelta = 0.03;

  bool get improved => isComparable && accuracyDelta >= meaningfulDelta;
  bool get declined => isComparable && accuracyDelta <= -meaningfulDelta;
  bool get steady => isComparable && !improved && !declined;

  /// Unterschied im Tempo. Negativ heißt schneller geworden.
  Duration get timeDelta =>
      current.averageTimePerQuestion - previous.averageTimePerQuestion;
}

/// Der Verlauf über die Zeit, berechnet aus dem Sitzungsverlauf.
///
/// Bewusst eine reine Auswertung ohne eigenen Speicher: Die Sitzungen liegen
/// ohnehin vor, und was daraus abgeleitet wird, kann sich ändern, ohne dass
/// gespeicherte Daten ungültig werden.
class ProgressTrend {
  const ProgressTrend._(this._sessions);

  factory ProgressTrend(List<TrainingSession> sessions) =>
      ProgressTrend._(sessions);

  final List<TrainingSession> _sessions;

  bool get isEmpty => _sessions.isEmpty;

  /// Wie viele Wochen die Übersicht zeigt.
  static const int weeksShown = 8;

  /// Ohne diese Mindestzahl an Antworten wird ein Abschnitt nicht als
  /// aussagekräftig behandelt – eine einzelne Aufgabe ergibt keine Quote.
  static const int minimumAnswersPerPeriod = 5;

  static DateTime _startOfDay(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  /// Montag der Woche, in der [value] liegt.
  static DateTime startOfWeek(DateTime value) {
    final day = _startOfDay(value);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  /// Fasst Sitzungen zu einem Punkt zusammen.
  static TrendPoint _pointOf(
    DateTime start,
    Iterable<TrainingSession> sessions, {
    TrainingModule? module,
  }) {
    var answered = 0;
    var correct = 0;
    var time = Duration.zero;
    var count = 0;

    for (final session in sessions) {
      final results = module == null
          ? session.results
          : session.results.where((result) => result.module == module);

      var touched = false;
      for (final result in results) {
        if (!result.answered) continue;

        answered++;
        if (result.correct) correct++;
        time += result.timeSpent;
        touched = true;
      }

      if (touched) count++;
    }

    return TrendPoint(
      start: start,
      answered: answered,
      correct: correct,
      timeSpent: time,
      sessions: count,
    );
  }

  /// Die letzten [weeksShown] Wochen, älteste zuerst.
  ///
  /// Wochen ohne Übung bleiben als leere Punkte enthalten – eine Lücke ist
  /// eine Aussage, und sie zu verschweigen würde den Verlauf schönen.
  List<TrendPoint> weeklyPoints({DateTime? now, TrainingModule? module}) {
    final reference = startOfWeek(now ?? DateTime.now());

    final buckets = <DateTime, List<TrainingSession>>{};
    for (final session in _sessions) {
      buckets
          .putIfAbsent(startOfWeek(session.finishedAt), () => [])
          .add(session);
    }

    return [
      for (var index = weeksShown - 1; index >= 0; index--)
        () {
          final start = reference.subtract(Duration(days: 7 * index));
          return _pointOf(start, buckets[start] ?? const [], module: module);
        }(),
    ];
  }

  /// Vergleicht die letzten [days] Tage mit den [days] davor.
  TrendComparison compareWindows({int days = 7, DateTime? now}) {
    final reference = now ?? DateTime.now();
    final currentStart = _startOfDay(reference).subtract(
      Duration(days: days - 1),
    );
    final previousStart = currentStart.subtract(Duration(days: days));

    bool inRange(TrainingSession session, DateTime from, DateTime to) {
      final finished = session.finishedAt;
      return !finished.isBefore(from) && finished.isBefore(to);
    }

    return TrendComparison(
      current: _pointOf(
        currentStart,
        _sessions.where(
          (session) => inRange(
            session,
            currentStart,
            _startOfDay(reference).add(const Duration(days: 1)),
          ),
        ),
      ),
      previous: _pointOf(
        previousStart,
        _sessions.where(
          (session) => inRange(session, previousStart, currentStart),
        ),
      ),
    );
  }

  /// Wie viele Tage in Folge geübt wurde, heute oder gestern endend.
  ///
  /// Gestern zählt noch mit: Wer abends übt und morgens nachsieht, hat seine
  /// Serie nicht verloren, nur weil der neue Tag angebrochen ist.
  int streak({DateTime? now}) {
    if (_sessions.isEmpty) return 0;

    final days = {
      for (final session in _sessions) _startOfDay(session.finishedAt),
    };

    final today = _startOfDay(now ?? DateTime.now());
    var cursor = today;

    if (!days.contains(cursor)) {
      cursor = today.subtract(const Duration(days: 1));
      if (!days.contains(cursor)) return 0;
    }

    var length = 0;
    while (days.contains(cursor)) {
      length++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return length;
  }

  /// An wie vielen verschiedenen Tagen insgesamt geübt wurde.
  int get activeDays => {
        for (final session in _sessions) _startOfDay(session.finishedAt),
      }.length;

  /// Die höchste Trefferquote unter den aussagekräftigen Wochen – der
  /// Bezugswert für die Höhe der Balken.
  double bestWeeklyAccuracy({DateTime? now}) {
    final meaningful = weeklyPoints(now: now).where(
      (point) => point.answered >= minimumAnswersPerPeriod,
    );

    if (meaningful.isEmpty) return 0;
    return meaningful.map((point) => point.accuracy).reduce(
          (a, b) => a > b ? a : b,
        );
  }

  /// Ob sich eine Verlaufsdarstellung überhaupt lohnt.
  ///
  /// Ein einzelner Balken ist kein Verlauf – dann bleibt der Abschnitt aus,
  /// statt eine Entwicklung zu behaupten, die es noch nicht gibt.
  bool hasEnoughHistory({DateTime? now}) {
    final meaningful = weeklyPoints(now: now).where(
      (point) => point.answered >= minimumAnswersPerPeriod,
    );

    return meaningful.length >= 2;
  }
}
