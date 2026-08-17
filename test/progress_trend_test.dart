import 'package:einstellungstest_trainer/models/progress_trend.dart';
import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Ein Donnerstag – so lässt sich der Wochenanfang gut prüfen.
  final now = DateTime(2026, 5, 14, 18);

  TrainingSession sessionOn(
    DateTime finishedAt, {
    int total = 10,
    int correct = 7,
    SubCategory subCategory = SubCategory.numberSequences,
    Duration perQuestion = const Duration(seconds: 10),
  }) {
    return TrainingSession(
      id: 'session_${finishedAt.millisecondsSinceEpoch}_${subCategory.id}',
      mode: SessionMode.practice,
      module: subCategory.module,
      startedAt: finishedAt.subtract(const Duration(minutes: 5)),
      finishedAt: finishedAt,
      results: [
        for (var index = 0; index < total; index++)
          QuestionResult(
            questionId: 'q$index',
            subCategory: subCategory,
            answered: true,
            correct: index < correct,
            timeSpent: perQuestion,
          ),
      ],
    );
  }

  group('Wochenraster', () {
    test('der Wochenanfang ist der Montag', () {
      expect(ProgressTrend.startOfWeek(now), DateTime(2026, 5, 11));
      // Ein Montag bleibt sein eigener Wochenanfang.
      expect(
        ProgressTrend.startOfWeek(DateTime(2026, 5, 11, 23, 59)),
        DateTime(2026, 5, 11),
      );
      // Ein Sonntag gehoert noch zur davorliegenden Woche.
      expect(
        ProgressTrend.startOfWeek(DateTime(2026, 5, 17)),
        DateTime(2026, 5, 11),
      );
    });

    test('liefert immer genau so viele Wochen wie vorgesehen', () {
      final trend = ProgressTrend([sessionOn(now)]);

      expect(trend.weeklyPoints(now: now), hasLength(ProgressTrend.weeksShown));
    });

    test('die jüngste Woche steht hinten', () {
      final trend = ProgressTrend([sessionOn(now)]);
      final points = trend.weeklyPoints(now: now);

      expect(points.last.start, DateTime(2026, 5, 11));
      expect(points.last.answered, 10);
      expect(points.first.start, DateTime(2026, 5, 11).subtract(
        const Duration(days: 49),
      ));
    });

    test('Wochen ohne Übung bleiben als Lücke stehen', () {
      // Eine Luecke ist eine Aussage – sie zu ueberspringen wuerde den
      // Verlauf schoener aussehen lassen, als er war.
      final trend = ProgressTrend([
        sessionOn(now),
        sessionOn(now.subtract(const Duration(days: 21))),
      ]);

      final points = trend.weeklyPoints(now: now);
      expect(points.where((point) => point.isEmpty), hasLength(6));
      expect(points.where((point) => !point.isEmpty), hasLength(2));
    });

    test('rechnet Quote und Tempo je Woche', () {
      final trend = ProgressTrend([
        sessionOn(now, total: 10, correct: 8,
            perQuestion: const Duration(seconds: 12)),
        sessionOn(now.subtract(const Duration(days: 1)), total: 10, correct: 4,
            perQuestion: const Duration(seconds: 8)),
      ]);

      final week = trend.weeklyPoints(now: now).last;

      expect(week.answered, 20);
      expect(week.correct, 12);
      expect(week.accuracy, 0.6);
      expect(week.averageTimePerQuestion, const Duration(seconds: 10));
      expect(week.sessions, 2);
    });

    test('lässt sich auf ein Modul einschränken', () {
      final trend = ProgressTrend([
        sessionOn(now, total: 10, correct: 9),
        sessionOn(now, total: 10, correct: 2,
            subCategory: SubCategory.arithmetic),
      ]);

      final logic = trend
          .weeklyPoints(now: now, module: TrainingModule.logic)
          .last;
      final math = trend
          .weeklyPoints(now: now, module: TrainingModule.math)
          .last;

      expect(logic.correct, 9);
      expect(math.correct, 2);
    });

    test('sehr alte Sitzungen fallen aus dem Fenster', () {
      final trend = ProgressTrend([
        sessionOn(now.subtract(const Duration(days: 200))),
      ]);

      expect(
        trend.weeklyPoints(now: now).every((point) => point.isEmpty),
        isTrue,
      );
    });
  });

  group('Vergleich zweier Zeiträume', () {
    test('erkennt eine Verbesserung', () {
      final trend = ProgressTrend([
        sessionOn(now.subtract(const Duration(days: 1)), total: 10, correct: 8),
        sessionOn(now.subtract(const Duration(days: 9)), total: 10, correct: 5),
      ]);

      final comparison = trend.compareWindows(now: now);

      expect(comparison.isComparable, isTrue);
      expect(comparison.improved, isTrue);
      expect(comparison.declined, isFalse);
      expect(comparison.accuracyDelta, closeTo(0.3, 0.001));
    });

    test('erkennt eine Verschlechterung', () {
      final trend = ProgressTrend([
        sessionOn(now.subtract(const Duration(days: 1)), total: 10, correct: 4),
        sessionOn(now.subtract(const Duration(days: 9)), total: 10, correct: 9),
      ]);

      expect(trend.compareWindows(now: now).declined, isTrue);
    });

    test('kleine Schwankungen gelten als unverändert', () {
      // Eine Aufgabe mehr richtig ist kein Trend.
      final trend = ProgressTrend([
        sessionOn(now.subtract(const Duration(days: 1)), total: 100,
            correct: 71),
        sessionOn(now.subtract(const Duration(days: 9)), total: 100,
            correct: 70),
      ]);

      final comparison = trend.compareWindows(now: now);
      expect(comparison.steady, isTrue);
      expect(comparison.improved, isFalse);
    });

    test('ohne Daten im Vorzeitraum gibt es keinen Vergleich', () {
      // Sonst wuerde aus dem Nichts eine Verbesserung behauptet.
      final trend = ProgressTrend([
        sessionOn(now.subtract(const Duration(days: 1))),
      ]);

      expect(trend.compareWindows(now: now).isComparable, isFalse);
      expect(trend.compareWindows(now: now).improved, isFalse);
    });

    test('die Fenster überschneiden sich nicht', () {
      // Genau 7 Tage zurueck gehoert bereits in den Vorzeitraum.
      final trend = ProgressTrend([
        sessionOn(now, total: 10, correct: 10),
        sessionOn(now.subtract(const Duration(days: 7)), total: 10, correct: 0),
      ]);

      final comparison = trend.compareWindows(now: now);

      expect(comparison.current.answered, 10);
      expect(comparison.previous.answered, 10);
      expect(comparison.current.accuracy, 1.0);
      expect(comparison.previous.accuracy, 0.0);
    });

    test('misst auch die Veränderung im Tempo', () {
      final trend = ProgressTrend([
        sessionOn(now.subtract(const Duration(days: 1)),
            perQuestion: const Duration(seconds: 8)),
        sessionOn(now.subtract(const Duration(days: 9)),
            perQuestion: const Duration(seconds: 14)),
      ]);

      // Negativ heisst schneller geworden.
      expect(
        trend.compareWindows(now: now).timeDelta,
        const Duration(seconds: -6),
      );
    });
  });

  group('Serie', () {
    test('zählt aufeinanderfolgende Übungstage', () {
      final trend = ProgressTrend([
        for (var back = 0; back < 4; back++)
          sessionOn(now.subtract(Duration(days: back))),
      ]);

      expect(trend.streak(now: now), 4);
    });

    test('eine Lücke beendet die Serie', () {
      final trend = ProgressTrend([
        sessionOn(now),
        sessionOn(now.subtract(const Duration(days: 1))),
        // Tag 2 fehlt.
        sessionOn(now.subtract(const Duration(days: 3))),
      ]);

      expect(trend.streak(now: now), 2);
    });

    test('gestern zählt noch mit', () {
      // Wer abends uebt und morgens nachsieht, hat seine Serie nicht
      // verloren, nur weil ein neuer Tag angebrochen ist.
      final trend = ProgressTrend([
        sessionOn(now.subtract(const Duration(days: 1))),
        sessionOn(now.subtract(const Duration(days: 2))),
      ]);

      expect(trend.streak(now: now), 2);
    });

    test('nach zwei Tagen Pause ist die Serie vorbei', () {
      final trend = ProgressTrend([
        sessionOn(now.subtract(const Duration(days: 2))),
        sessionOn(now.subtract(const Duration(days: 3))),
      ]);

      expect(trend.streak(now: now), 0);
    });

    test('mehrere Runden am selben Tag zählen einmal', () {
      final trend = ProgressTrend([
        sessionOn(now),
        sessionOn(now.subtract(const Duration(hours: 3))),
        sessionOn(now.subtract(const Duration(hours: 6))),
      ]);

      expect(trend.streak(now: now), 1);
      expect(trend.activeDays, 1);
    });

    test('ohne Sitzungen gibt es keine Serie', () {
      expect(ProgressTrend(const []).streak(now: now), 0);
      expect(ProgressTrend(const []).activeDays, 0);
    });
  });

  group('Ob sich eine Darstellung lohnt', () {
    test('eine einzelne Woche ist noch kein Verlauf', () {
      final trend = ProgressTrend([sessionOn(now)]);

      expect(trend.hasEnoughHistory(now: now), isFalse);
    });

    test('zwei Wochen mit genug Aufgaben genügen', () {
      final trend = ProgressTrend([
        sessionOn(now),
        sessionOn(now.subtract(const Duration(days: 7))),
      ]);

      expect(trend.hasEnoughHistory(now: now), isTrue);
    });

    test('Wochen mit sehr wenigen Aufgaben zählen nicht mit', () {
      // Eine Quote aus zwei Aufgaben ist Zufall, kein Messwert.
      final trend = ProgressTrend([
        sessionOn(now, total: 2, correct: 2),
        sessionOn(now.subtract(const Duration(days: 7)), total: 2, correct: 0),
      ]);

      expect(trend.hasEnoughHistory(now: now), isFalse);
      expect(trend.bestWeeklyAccuracy(now: now), 0);
    });

    test('ohne Sitzungen ist der Verlauf leer', () {
      expect(ProgressTrend(const []).isEmpty, isTrue);
      expect(ProgressTrend(const []).hasEnoughHistory(now: now), isFalse);
    });

    test('der Bezugswert ist die beste aussagekräftige Woche', () {
      final trend = ProgressTrend([
        sessionOn(now, total: 10, correct: 6),
        sessionOn(now.subtract(const Duration(days: 7)), total: 10, correct: 9),
      ]);

      expect(trend.bestWeeklyAccuracy(now: now), 0.9);
    });
  });
}
