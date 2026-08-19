import 'package:einstellungstest_trainer/models/field_of_study.dart';
import 'package:einstellungstest_trainer/models/review_book.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';

/// Der Stand eines einzelnen Themas im Leitfaden.
class TopicStep {
  const TopicStep({
    required this.subCategory,
    required this.weight,
    required this.answered,
    required this.accuracy,
  });

  final SubCategory subCategory;
  final TopicWeight weight;

  /// Beantwortete Aufgaben in diesem Thema.
  final int answered;

  /// Trefferquote, 0 bis 1.
  final double accuracy;

  int get required => weight.requiredAnswers;

  bool get hasEnough => answered >= required;

  bool get hitsTarget => accuracy >= Readiness.targetAccuracy;

  bool get isDone => hasEnough && hitsTarget;

  /// Wie viele Aufgaben noch fehlen, bis die Menge stimmt.
  int get missing => hasEnough ? 0 : required - answered;

  /// Fortschritt dieses Schrittes, 0 bis 1.
  ///
  /// Zwei Bedingungen, je zur Hälfte gewichtet: genug Aufgaben und gute
  /// Quote. So bewegt sich der Balken auch dann, wenn erst eine der beiden
  /// erfüllt ist.
  double get progress {
    final volume = required == 0 ? 1.0 : (answered / required).clamp(0.0, 1.0);
    final quality = (accuracy / Readiness.targetAccuracy).clamp(0.0, 1.0);
    return (volume + quality) / 2;
  }

  /// Was als Nächstes zu tun ist – ein Satz, keine Liste.
  String get advice {
    if (isDone) return 'Erledigt';
    if (!hasEnough && answered == 0) return 'Noch nicht begonnen';
    if (!hasEnough) return 'Noch $missing Aufgaben';
    return 'Quote bei ${(accuracy * 100).round()} %, nötig sind '
        '${(Readiness.targetAccuracy * 100).round()} %';
  }
}

/// Wie weit die Vorbereitung auf eine Fachrichtung gediehen ist.
///
/// Drei Bedingungen, wie abgestimmt: genug Aufgaben je Thema, eine
/// Trefferquote von mindestens 80 Prozent – und eine bestandene
/// Testsimulation. Die Simulation zählt als eigener Schritt, weil sie das
/// Einzige ist, was den Ernstfall abbildet: alle Bereiche am Stück, unter
/// Zeitdruck, ohne Rückmeldung zwischendurch.
class Readiness {
  const Readiness({
    required this.field,
    required this.steps,
    required this.simulationScore,
  });

  final FieldOfStudy field;

  /// Alle geforderten Themen, Kernthemen zuerst.
  final List<TopicStep> steps;

  /// Beste Trefferquote einer abgeschlossenen Gesamtsimulation, `null` wenn
  /// noch keine gelaufen ist.
  final double? simulationScore;

  /// Ab dieser Quote gilt ein Thema als sitzend.
  static const double targetAccuracy = 0.8;

  /// So gut muss die Testsimulation ausfallen.
  static const double simulationTarget = 0.7;

  bool get simulationPassed =>
      simulationScore != null && simulationScore! >= simulationTarget;

  List<TopicStep> get openSteps =>
      steps.where((step) => !step.isDone).toList();

  List<TopicStep> get doneSteps => steps.where((step) => step.isDone).toList();

  /// Das Thema, das als Nächstes dran ist: erst Kernthemen, davon das am
  /// weitesten zurückliegende.
  TopicStep? get nextStep {
    final open = openSteps;
    if (open.isEmpty) return null;

    final core =
        open.where((step) => step.weight == TopicWeight.core).toList();
    final pool = core.isEmpty ? open : core;

    return pool.reduce(
      (best, step) => step.progress < best.progress ? step : best,
    );
  }

  /// Wie viele Aufgaben insgesamt noch fehlen.
  int get missingAnswers =>
      openSteps.fold(0, (sum, step) => sum + step.missing);

  /// Gesamtfortschritt, 0 bis 1 – die Themen und die Simulation zusammen.
  double get progress {
    if (steps.isEmpty) return simulationPassed ? 1 : 0;

    final topicProgress =
        steps.fold<double>(0, (sum, step) => sum + step.progress);
    // Die Simulation zählt wie ein weiteres Thema.
    final total = topicProgress + (simulationPassed ? 1 : 0);
    return (total / (steps.length + 1)).clamp(0.0, 1.0);
  }

  bool get isReady => openSteps.isEmpty && simulationPassed;

  /// Ein Satz zum Stand – ohne Zahlenwust und ohne Lob auf Vorrat.
  String get summary {
    if (isReady) return 'Alle Themen sitzen. Du bist vorbereitet.';
    if (steps.isEmpty) return 'Für diese Fachrichtung ist nichts hinterlegt.';

    final open = openSteps.length;
    if (!simulationPassed && open == 0) {
      return 'Die Themen sitzen. Es fehlt nur noch eine bestandene '
          'Testsimulation.';
    }
    return open == 1
        ? 'Noch ein Thema offen.'
        : 'Noch $open Themen offen.';
  }

  /// Baut den Stand aus dem Fehlerbuch.
  ///
  /// Das Fehlerbuch führt je Thema mit, wie viele Aufgaben beantwortet und
  /// wie viele davon richtig waren – genau die zwei Zahlen, die der Leitfaden
  /// braucht. Ein eigener Zähler daneben könnte auseinanderlaufen.
  factory Readiness.from({
    required FieldOfStudy field,
    required ReviewBook book,
    double? simulationScore,
  }) {
    return Readiness(
      field: field,
      simulationScore: simulationScore,
      steps: [
        for (final topic in field.topics)
          () {
            final mastery = book.masteryOf(topic);
            return TopicStep(
              subCategory: topic,
              weight: field.weights[topic]!,
              answered: mastery.answered,
              accuracy: mastery.accuracy,
            );
          }(),
      ],
    );
  }
}
