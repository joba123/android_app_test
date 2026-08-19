import 'package:einstellungstest_trainer/models/exam_plan.dart';
import 'package:einstellungstest_trainer/models/field_of_study.dart';
import 'package:einstellungstest_trainer/models/readiness.dart';
import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/services/exam_date_controller.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Alle hinterlegten Prüfungen und die gerade gewählte.
class ExamPlans {
  const ExamPlans({required this.plans, required this.activeId});

  final List<ExamPlan> plans;
  final String activeId;

  ExamPlan? get active {
    for (final plan in plans) {
      if (plan.id == activeId) return plan;
    }
    return plans.isEmpty ? null : plans.first;
  }

  static const ExamPlans empty = ExamPlans(plans: [], activeId: '');
}

/// Verwaltet die Prüfungen.
///
/// Der Termin der **aktiven** Prüfung wird zusätzlich in den bestehenden
/// Testtermin geschrieben. Dadurch bleiben Erinnerungen und Cloud-Abgleich
/// unverändert: Beide kennen weiterhin genau ein Datum, nämlich das der
/// Prüfung, auf die man gerade hinarbeitet.
class ExamPlanController extends Notifier<ExamPlans> {
  @override
  ExamPlans build() {
    final storage = ref.watch(storageServiceProvider);
    final stored = storage.loadExamPlans();

    if (stored.isNotEmpty) {
      final activeId = storage.activeExamPlanId ?? stored.first.id;
      return ExamPlans(plans: stored, activeId: activeId);
    }

    // Erststart oder Aufstieg von einer Version ohne Prüfungen: Ein bereits
    // hinterlegter Testtermin wird zur ersten Prüfung, damit niemand seinen
    // Countdown verliert.
    final existingDate = storage.loadExamDate();
    final plan = ExamPlan(
      id: 'plan_1',
      title: existingDate == null ? 'Meine Vorbereitung' : 'Meine Prüfung',
      field: FieldOfStudy.general,
      date: existingDate?.date,
      createdAt: DateTime.now(),
    );

    return ExamPlans(plans: [plan], activeId: plan.id);
  }

  Future<void> _persist(ExamPlans next) async {
    state = next;
    final storage = ref.read(storageServiceProvider);
    await storage.saveExamPlans(next.plans);
    await storage.saveActiveExamPlanId(next.activeId);
    await _syncExamDate();
  }

  /// Schreibt den Termin der aktiven Prüfung in den Testtermin durch.
  Future<void> _syncExamDate() async {
    final plan = state.active;
    final controller = ref.read(examDateProvider.notifier);

    if (plan?.date == null) {
      await controller.clear();
    } else {
      await controller.set(plan!.date!, label: plan.title);
    }
  }

  Future<void> add({
    required String title,
    required FieldOfStudy field,
    DateTime? date,
  }) async {
    final plan = ExamPlan(
      id: 'plan_${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim().isEmpty ? field.label : title.trim(),
      field: field,
      date: date,
      createdAt: DateTime.now(),
    );

    await _persist(
      ExamPlans(plans: [...state.plans, plan], activeId: plan.id),
    );
  }

  Future<void> update(
    String id, {
    String? title,
    FieldOfStudy? field,
    DateTime? date,
    bool clearDate = false,
  }) async {
    await _persist(
      ExamPlans(
        plans: [
          for (final plan in state.plans)
            if (plan.id == id)
              plan.copyWith(
                title: title,
                field: field,
                date: date,
                clearDate: clearDate,
              )
            else
              plan,
        ],
        activeId: state.activeId,
      ),
    );
  }

  Future<void> select(String id) async {
    if (state.activeId == id) return;

    await _persist(ExamPlans(plans: state.plans, activeId: id));
  }

  /// Entfernt eine Prüfung. Die letzte bleibt stehen – ohne Prüfung hätte der
  /// Leitfaden keinen Bezugspunkt mehr.
  Future<void> remove(String id) async {
    if (state.plans.length <= 1) return;

    final remaining = [
      for (final plan in state.plans)
        if (plan.id != id) plan,
    ];

    await _persist(
      ExamPlans(
        plans: remaining,
        activeId: state.activeId == id ? remaining.first.id : state.activeId,
      ),
    );
  }
}

final examPlansProvider =
    NotifierProvider<ExamPlanController, ExamPlans>(ExamPlanController.new);

/// Die gerade gewählte Prüfung.
final activeExamPlanProvider = Provider<ExamPlan?>((ref) {
  return ref.watch(examPlansProvider).active;
});

/// Der Leitfaden zur aktiven Prüfung.
final readinessProvider = Provider<Readiness>((ref) {
  final plan = ref.watch(activeExamPlanProvider);
  final book = ref.watch(reviewBookProvider);

  // Die beste abgeschlossene Gesamtsimulation zählt – nicht die letzte. Wer
  // einmal bestanden hat, hat gezeigt, dass er es kann.
  double? best;
  for (final session in ref.watch(sessionHistoryProvider)) {
    if (session.mode != SessionMode.simulation) continue;
    if (best == null || session.accuracy > best) best = session.accuracy;
  }

  return Readiness.from(
    field: plan?.field ?? FieldOfStudy.general,
    book: book,
    simulationScore: best,
  );
});
