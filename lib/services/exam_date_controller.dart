import 'package:einstellungstest_trainer/models/exam_date.dart';
import 'package:einstellungstest_trainer/services/notifications/reminder_controller.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/services/sync/sync_merge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Der hinterlegte Testtermin.
///
/// Steht bewusst eigenständig und nicht beim Cloud-Abgleich: Der Termin wird
/// von zwei Seiten gebraucht – er wandert mit in die Cloud **und** er bestimmt,
/// wann erinnert wird. Läge er bei einem der beiden, müsste der andere ihn von
/// dort importieren.
class ExamDateController extends Notifier<ExamDate?> {
  @override
  ExamDate? build() => ref.watch(storageServiceProvider).loadExamDate();

  Future<void> set(DateTime date, {String? label}) async {
    final entry = ExamDate(
      date: date,
      updatedAt: DateTime.now(),
      label: (label != null && label.trim().isEmpty) ? null : label?.trim(),
    );

    state = entry;
    await ref.read(storageServiceProvider).saveExamDate(entry);
    await _rescheduleReminders();
  }

  Future<void> clear() async {
    state = null;
    await ref.read(storageServiceProvider).saveExamDate(null);
    await _rescheduleReminders();
  }

  /// Übernimmt das Ergebnis eines Abgleichs, ohne erneut zu schreiben, was
  /// ohnehin schon lokal stand.
  Future<void> applyFromSync(SyncOutcome outcome) async {
    final date = outcome.examDate;
    if (date == null) return;

    final entry = ExamDate(
      date: date,
      updatedAt: outcome.examUpdatedAt ?? DateTime.now(),
      label: outcome.examLabel,
    );

    if (entry == state) return;

    state = entry;
    await ref.read(storageServiceProvider).saveExamDate(entry);
    await _rescheduleReminders();
  }

  /// Ein von einem anderen Gerät übernommener Termin muss dieselben
  /// Erinnerungen auslösen wie ein hier gesetzter.
  Future<void> _rescheduleReminders() {
    return ref.read(reminderControllerProvider.notifier).reschedule();
  }
}

final examDateProvider =
    NotifierProvider<ExamDateController, ExamDate?>(ExamDateController.new);
